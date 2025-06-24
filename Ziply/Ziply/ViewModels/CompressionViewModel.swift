import Foundation
import SwiftUI
import Photos
import Combine

@MainActor
class CompressionViewModel: ObservableObject {
    // MARK: - Published Properties
    
    @Published var isCompressing = false
    @Published var currentProgress: Float = 0.0
    @Published var photosProcessed = 0
    @Published var totalPhotos = 0
    @Published var spaceFreed: Int64 = 0
    @Published var errors = 0
    @Published var averageQuality: Float = 0.0
    @Published var estimatedTimeRemaining: TimeInterval = 0
    @Published var compressionResults: [CompressedImageResult] = []
    
    // MARK: - Private Properties
    
    private let compressionService = CompressionService.shared
    private let photoLibraryService = PhotoLibraryService.shared
    private var compressionTask: Task<Void, Never>?
    private var startTime: Date?
    private var isCancelled = false
    
    // Album management
    private var albumCache: [String: PHAssetCollection] = [:]
    
    // MARK: - Computed Properties
    
    var progressPercentage: Int {
        Int(currentProgress * 100)
    }
    
    var formattedSpaceFreed: String {
        photoLibraryService.formatBytes(spaceFreed)
    }
    
    var formattedTimeRemaining: String {
        if estimatedTimeRemaining <= 0 {
            return "Calculating..."
        }
        
        let minutes = Int(estimatedTimeRemaining) / 60
        let seconds = Int(estimatedTimeRemaining) % 60
        
        if minutes > 0 {
            return "\(minutes)m \(seconds)s"
        } else {
            return "\(seconds)s"
        }
    }
    
    var totalSpaceSaved: Int64 {
        compressionResults.reduce(0) { $0 + Int64($1.spaceSaved) }
    }
    
    var averageCompressionRatio: Double {
        guard !compressionResults.isEmpty else { return 0 }
        let totalRatio = compressionResults.reduce(0.0) { $0 + $1.compressionRatio }
        return totalRatio / Double(compressionResults.count)
    }
    
    var timeTaken: TimeInterval {
        guard let startTime = startTime else { return 0 }
        return Date().timeIntervalSince(startTime)
    }
    
    // MARK: - Public Methods
    
    func startCompression(assets: [PHAsset]) {
        guard !isCompressing else { return }
        
        isCompressing = true
        isCancelled = false
        totalPhotos = assets.count
        photosProcessed = 0
        spaceFreed = 0
        errors = 0
        currentProgress = 0
        compressionResults = []
        startTime = Date()
        
        compressionTask = Task {
            await performCompression(assets: assets)
        }
    }
    
    func cancelCompression() {
        isCancelled = true
        compressionTask?.cancel()
        isCompressing = false
    }
    
    // MARK: - Private Methods
    
    private func performCompression(assets: [PHAsset]) async {
        // Group assets by their album
        let assetsByAlbum = await groupAssetsByAlbum(assets)
        
        for (albumName, albumAssets) in assetsByAlbum {
            if isCancelled { break }
            
            // Create or get compressed album
            let compressedAlbum = await getOrCreateCompressedAlbum(for: albumName)
            
            // Process assets in this album
            for asset in albumAssets {
                if isCancelled { break }
                
                await processAsset(asset, targetAlbum: compressedAlbum)
                
                // Update progress
                photosProcessed += 1
                currentProgress = Float(photosProcessed) / Float(totalPhotos)
                updateTimeEstimate()
            }
        }
        
        isCompressing = false
        
        // Calculate final stats
        if !compressionResults.isEmpty {
            averageQuality = calculateAverageQuality()
        }
    }
    
    private func processAsset(_ asset: PHAsset, targetAlbum: PHAssetCollection?) async {
        do {
            // Compress the image
            let result = try await compressionService.compressImage(from: asset)
            
            // Save to photo library
            _ = try await compressionService.saveCompressedImage(result, to: targetAlbum)
            
            // Update stats
            spaceFreed += Int64(result.spaceSaved)
            compressionResults.append(result)
            
            // Update average quality
            averageQuality = calculateAverageQuality()
            
        } catch {
            print("Failed to compress asset: \(error)")
            errors += 1
        }
    }
    
    private func groupAssetsByAlbum(_ assets: [PHAsset]) async -> [String: [PHAsset]] {
        var assetsByAlbum: [String: [PHAsset]] = [:]
        
        // Default album for assets not in any album
        assetsByAlbum["Camera Roll"] = []
        
        for asset in assets {
            var foundInAlbum = false
            
            // Find which album(s) this asset belongs to
            let fetchOptions = PHFetchOptions()
            let collections = PHAssetCollection.fetchAssetCollectionsContaining(
                asset,
                with: .album,
                options: fetchOptions
            )
            
            collections.enumerateObjects { collection, _, _ in
                if let albumName = collection.localizedTitle {
                    if assetsByAlbum[albumName] == nil {
                        assetsByAlbum[albumName] = []
                    }
                    assetsByAlbum[albumName]?.append(asset)
                    foundInAlbum = true
                }
            }
            
            // If not in any album, add to Camera Roll
            if !foundInAlbum {
                assetsByAlbum["Camera Roll"]?.append(asset)
            }
        }
        
        // Remove empty albums
        assetsByAlbum = assetsByAlbum.filter { !$0.value.isEmpty }
        
        return assetsByAlbum
    }
    
    private func getOrCreateCompressedAlbum(for originalAlbumName: String) async -> PHAssetCollection? {
        let compressedAlbumName = "Compressed - \(originalAlbumName)"
        
        // Check cache first
        if let cachedAlbum = albumCache[compressedAlbumName] {
            return cachedAlbum
        }
        
        // Try to find existing album
        let fetchOptions = PHFetchOptions()
        fetchOptions.predicate = NSPredicate(format: "title = %@", compressedAlbumName)
        let collections = PHAssetCollection.fetchAssetCollections(with: .album, subtype: .any, options: fetchOptions)
        
        if let existingAlbum = collections.firstObject {
            albumCache[compressedAlbumName] = existingAlbum
            return existingAlbum
        }
        
        // Create new album
        let newAlbum = await photoLibraryService.createAlbum(name: compressedAlbumName)
        if let newAlbum = newAlbum {
            albumCache[compressedAlbumName] = newAlbum
        }
        return newAlbum
    }
    
    private func updateTimeEstimate() {
        guard photosProcessed > 0, let startTime = startTime else {
            estimatedTimeRemaining = 0
            return
        }
        
        let elapsed = Date().timeIntervalSince(startTime)
        let averageTimePerPhoto = elapsed / Double(photosProcessed)
        let remainingPhotos = totalPhotos - photosProcessed
        
        estimatedTimeRemaining = averageTimePerPhoto * Double(remainingPhotos)
    }
    
    private func calculateAverageQuality() -> Float {
        // For now, we'll estimate quality based on compression ratio
        // In a real implementation, you might want to use SSIM or other quality metrics
        let avgRatio = averageCompressionRatio
        
        // Assume quality is inversely related to compression
        // If compressed to 25% of original (ratio 0.25), quality might be ~85%
        // This is a simplified estimation
        return Float(0.7 + (avgRatio * 0.3))
    }
    
    // MARK: - Result Summary
    
    func getCompressionSummary() -> CompressionSummary {
        return CompressionSummary(
            totalPhotos: totalPhotos,
            successfulPhotos: photosProcessed - errors,
            failedPhotos: errors,
            totalSpaceSaved: totalSpaceSaved,
            averageCompressionRatio: averageCompressionRatio,
            averageQuality: averageQuality,
            timeTaken: timeTaken
        )
    }
}

// MARK: - Supporting Types

struct CompressionSummary {
    let totalPhotos: Int
    let successfulPhotos: Int
    let failedPhotos: Int
    let totalSpaceSaved: Int64
    let averageCompressionRatio: Double
    let averageQuality: Float
    let timeTaken: TimeInterval
    
    var compressionPercentage: Double {
        (1.0 - averageCompressionRatio) * 100
    }
    
    var formattedTimeTaken: String {
        let minutes = Int(timeTaken) / 60
        let seconds = Int(timeTaken) % 60
        
        if minutes > 0 {
            return "\(minutes)m \(seconds)s"
        } else {
            return "\(seconds)s"
        }
    }
}