import Foundation
import UIKit
import Photos
import CoreGraphics
import ImageIO
import UniformTypeIdentifiers

@MainActor
class CompressionService: ObservableObject {
    static let shared = CompressionService()
    
    private init() {}
    
    // MARK: - Public Methods
    
    /// Compress a single image
    func compressImage(from asset: PHAsset) async throws -> CompressedImageResult {
        // Load the original image
        let originalImage = try await loadImage(from: asset)
        let originalData = try await loadImageData(from: asset)
        let originalSize = originalData.count
        
        // Extract metadata
        let metadata = extractMetadata(from: originalData)
        
        // Resize if needed
        let resizedImage = resizeImageIfNeeded(originalImage)
        
        // Compress with metadata
        guard let compressedData = compressImage(resizedImage, withMetadata: metadata) else {
            throw CompressionError.compressionFailed
        }
        
        let compressedSize = compressedData.count
        let compressionRatio = Double(compressedSize) / Double(originalSize)
        
        return CompressedImageResult(
            asset: asset,
            originalSize: originalSize,
            compressedSize: compressedSize,
            compressionRatio: compressionRatio,
            compressedData: compressedData,
            metadata: metadata
        )
    }
    
    /// Compress multiple images in batch
    func compressBatch(_ assets: [PHAsset], progress: @escaping (CompressionProgress) -> Void) async throws -> [CompressedImageResult] {
        var results: [CompressedImageResult] = []
        var errors: [CompressionError] = []
        
        for (index, asset) in assets.enumerated() {
            let currentProgress = CompressionProgress(
                totalPhotos: assets.count,
                processedPhotos: index,
                currentProgress: Float(index) / Float(assets.count),
                errors: errors.count
            )
            progress(currentProgress)
            
            do {
                let result = try await compressImage(from: asset)
                results.append(result)
            } catch {
                errors.append(.assetCompressionFailed(asset: asset, error: error))
            }
        }
        
        // Final progress update
        let finalProgress = CompressionProgress(
            totalPhotos: assets.count,
            processedPhotos: assets.count,
            currentProgress: 1.0,
            errors: errors.count
        )
        progress(finalProgress)
        
        if !errors.isEmpty && results.isEmpty {
            throw CompressionError.batchFailed(errors: errors)
        }
        
        return results
    }
    
    /// Save compressed image to photo library
    func saveCompressedImage(_ result: CompressedImageResult, to album: PHAssetCollection?) async throws -> PHAsset {
        var localIdentifier: String?
        
        // First, perform the changes to create the asset
        try await PHPhotoLibrary.shared().performChanges {
            // Create the asset
            let creationRequest = PHAssetCreationRequest.forAsset()
            
            // Add image data
            creationRequest.addResource(with: .photo, data: result.compressedData, options: nil)
            
            // Add to album if provided
            if let album = album,
               let placeholder = creationRequest.placeholderForCreatedAsset {
                let albumChangeRequest = PHAssetCollectionChangeRequest(for: album)
                albumChangeRequest?.addAssets([placeholder] as NSArray)
            }
            
            // Store the placeholder identifier
            localIdentifier = creationRequest.placeholderForCreatedAsset?.localIdentifier
        }
        
        // Fetch the created asset
        guard let identifier = localIdentifier else {
            throw CompressionError.saveFailed
        }
        
        let fetchResult = PHAsset.fetchAssets(withLocalIdentifiers: [identifier], options: nil)
        guard let asset = fetchResult.firstObject else {
            throw CompressionError.saveFailed
        }
        
        return asset
    }
    
    /// Replace original image with compressed version and mark original as deletable
    func replaceOriginalWithCompressed(_ result: CompressedImageResult) async throws -> PHAsset {
        let photoLibraryService = PhotoLibraryService.shared
        
        // Get all albums containing the original asset
        let albums = photoLibraryService.getAlbumsContaining(asset: result.asset)
        
        var localIdentifier: String?
        
        // Get or create "Can Delete" album
        let canDeleteAlbum = await getOrCreateCanDeleteAlbum()
        
        // Perform all changes in a single transaction for atomicity
        try await PHPhotoLibrary.shared().performChanges {
            // Create the new compressed asset
            let creationRequest = PHAssetCreationRequest.forAsset()
            
            // Add image data with original metadata
            let resourceOptions = PHAssetResourceCreationOptions()
            if let creationDate = result.asset.creationDate {
                resourceOptions.uniformTypeIdentifier = UTType.jpeg.identifier
                resourceOptions.originalFilename = "IMG_\(Int(creationDate.timeIntervalSince1970)).jpg"
            }
            
            creationRequest.addResource(with: .photo, data: result.compressedData, options: resourceOptions)
            
            // Copy important properties from original
            creationRequest.creationDate = result.asset.creationDate
            creationRequest.location = result.asset.location
            creationRequest.isFavorite = result.asset.isFavorite
            
            // Add to all albums that contained the original
            if let placeholder = creationRequest.placeholderForCreatedAsset {
                for album in albums {
                    if let albumChangeRequest = PHAssetCollectionChangeRequest(for: album) {
                        albumChangeRequest.addAssets([placeholder] as NSArray)
                    }
                }
                
                localIdentifier = placeholder.localIdentifier
            }
            
            // Add original to "Can Delete" album if not already there
            if let canDeleteAlbum = canDeleteAlbum {
                // Check if asset is already in the album
                let fetchOptions = PHFetchOptions()
                let assetsInAlbum = PHAsset.fetchAssets(in: canDeleteAlbum, options: fetchOptions)
                var isAlreadyInAlbum = false
                
                assetsInAlbum.enumerateObjects { existingAsset, _, stop in
                    if existingAsset.localIdentifier == result.asset.localIdentifier {
                        isAlreadyInAlbum = true
                        stop.pointee = true
                    }
                }
                
                if !isAlreadyInAlbum {
                    if let albumChangeRequest = PHAssetCollectionChangeRequest(for: canDeleteAlbum) {
                        albumChangeRequest.addAssets([result.asset] as NSArray)
                    }
                }
            }
        }
        
        // Fetch the created asset
        guard let identifier = localIdentifier else {
            throw CompressionError.saveFailed
        }
        
        let fetchResult = PHAsset.fetchAssets(withLocalIdentifiers: [identifier], options: nil)
        guard let newAsset = fetchResult.firstObject else {
            throw CompressionError.saveFailed
        }
        
        return newAsset
    }
    
    private func getOrCreateCanDeleteAlbum() async -> PHAssetCollection? {
        let albumName = Constants.Albums.canDeleteAlbumName
        
        // Try to find existing album
        let fetchOptions = PHFetchOptions()
        fetchOptions.predicate = NSPredicate(format: "title = %@", albumName)
        let collections = PHAssetCollection.fetchAssetCollections(with: .album, subtype: .any, options: fetchOptions)
        
        if let existingAlbum = collections.firstObject {
            return existingAlbum
        }
        
        // Create new album
        return await PhotoLibraryService.shared.createAlbum(name: albumName)
    }
    
    
    // MARK: - Private Methods
    
    private func loadImage(from asset: PHAsset) async throws -> UIImage {
        return try await withCheckedThrowingContinuation { continuation in
            let options = PHImageRequestOptions()
            options.deliveryMode = .highQualityFormat
            options.isNetworkAccessAllowed = true
            options.isSynchronous = false
            
            PHImageManager.default().requestImage(
                for: asset,
                targetSize: PHImageManagerMaximumSize,
                contentMode: .aspectFit,
                options: options
            ) { image, info in
                if let error = info?[PHImageErrorKey] as? Error {
                    continuation.resume(throwing: error)
                } else if let image = image {
                    continuation.resume(returning: image)
                } else {
                    continuation.resume(throwing: CompressionError.imageLoadFailed)
                }
            }
        }
    }
    
    private func loadImageData(from asset: PHAsset) async throws -> Data {
        return try await withCheckedThrowingContinuation { continuation in
            let options = PHImageRequestOptions()
            options.deliveryMode = .highQualityFormat
            options.isNetworkAccessAllowed = true
            options.isSynchronous = false
            
            PHImageManager.default().requestImageDataAndOrientation(
                for: asset,
                options: options
            ) { data, _, _, info in
                if let error = info?[PHImageErrorKey] as? Error {
                    continuation.resume(throwing: error)
                } else if let data = data {
                    continuation.resume(returning: data)
                } else {
                    continuation.resume(throwing: CompressionError.imageLoadFailed)
                }
            }
        }
    }
    
    private func resizeImageIfNeeded(_ image: UIImage) -> UIImage {
        let size = image.size
        
        // Check if resize is needed
        if size.width <= Constants.Compression.maxDimension && size.height <= Constants.Compression.maxDimension {
            return image
        }
        
        // Calculate new size maintaining aspect ratio
        let aspectRatio = size.width / size.height
        var newSize: CGSize
        
        if size.width > size.height {
            newSize = CGSize(width: Constants.Compression.maxDimension, height: Constants.Compression.maxDimension / aspectRatio)
        } else {
            newSize = CGSize(width: Constants.Compression.maxDimension * aspectRatio, height: Constants.Compression.maxDimension)
        }
        
        // Create renderer with new size
        let renderer = UIGraphicsImageRenderer(size: newSize)
        
        let resizedImage = renderer.image { context in
            image.draw(in: CGRect(origin: .zero, size: newSize))
        }
        
        return resizedImage
    }
    
    private func extractMetadata(from imageData: Data) -> [String: Any]? {
        guard let source = CGImageSourceCreateWithData(imageData as CFData, nil),
              let metadata = CGImageSourceCopyPropertiesAtIndex(source, 0, nil) as? [String: Any] else {
            return nil
        }
        return metadata
    }
    
    private func compressImage(_ image: UIImage, withMetadata metadata: [String: Any]?) -> Data? {
        guard let cgImage = image.cgImage else { return nil }
        
        let data = NSMutableData()
        guard let destination = CGImageDestinationCreateWithData(
            data as CFMutableData,
            UTType.jpeg.identifier as CFString,
            1,
            nil
        ) else { return nil }
        
        // Prepare options with compression quality
        var options: [String: Any] = [
            kCGImageDestinationLossyCompressionQuality as String: Constants.Compression.compressionQuality
        ]
        
        // Add metadata if available
        if let metadata = metadata {
            options.merge(metadata) { _, new in new }
        }
        
        CGImageDestinationAddImage(destination, cgImage, options as CFDictionary)
        
        guard CGImageDestinationFinalize(destination) else { return nil }
        
        return data as Data
    }
    
    /// Calculate quality score between original and compressed images
    func calculateQualityScore(original: UIImage, compressed: UIImage) -> Float {
        // This is a simplified quality metric
        // In production, you might want to use more sophisticated algorithms like SSIM
        let originalPixels = original.size.width * original.size.height
        let compressedPixels = compressed.size.width * compressed.size.height
        
        let sizeScore = Float(compressedPixels / originalPixels)
        
        // Assume compression quality contributes to the score
        let qualityScore = Float(Constants.Compression.compressionQuality)
        
        // Weighted average
        return (sizeScore * 0.3 + qualityScore * 0.7)
    }
}

// MARK: - Supporting Types

struct CompressedImageResult {
    let asset: PHAsset
    let originalSize: Int
    let compressedSize: Int
    let compressionRatio: Double
    let compressedData: Data
    let metadata: [String: Any]?
    
    var spaceSaved: Int {
        originalSize - compressedSize
    }
    
    var compressionPercentage: Double {
        (1.0 - compressionRatio) * 100
    }
}

struct CompressionProgress {
    let totalPhotos: Int
    let processedPhotos: Int
    let currentProgress: Float
    let errors: Int
    
    var successfulPhotos: Int {
        processedPhotos - errors
    }
}

enum CompressionError: LocalizedError {
    case imageLoadFailed
    case compressionFailed
    case saveFailed
    case assetCompressionFailed(asset: PHAsset, error: Error)
    case batchFailed(errors: [CompressionError])
    
    var errorDescription: String? {
        switch self {
        case .imageLoadFailed:
            return "Failed to load image from photo library"
        case .compressionFailed:
            return "Failed to compress image"
        case .saveFailed:
            return "Failed to save compressed image"
        case .assetCompressionFailed(_, let error):
            return "Compression failed: \(error.localizedDescription)"
        case .batchFailed(let errors):
            return "Batch compression failed with \(errors.count) errors"
        }
    }
}