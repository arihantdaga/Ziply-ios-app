//
//  PhotoLibraryService.swift
//  Ziply
//
//  Created by Arihant Daga Second on 22/06/25.
//

import Foundation
import Photos
import UIKit

class PhotoLibraryService: NSObject, ObservableObject, PHPhotoLibraryChangeObserver {
    static let shared = PhotoLibraryService()
    
    @Published var authorizationStatus: PHAuthorizationStatus = .notDetermined
    
    override private init() {
        super.init()
        checkAuthorizationStatus()
        
        // Listen for authorization changes
        PHPhotoLibrary.shared().register(self)
    }
    
    // MARK: - Authorization
    
    func checkAuthorizationStatus() {
        authorizationStatus = PHPhotoLibrary.authorizationStatus(for: .readWrite)
    }
    
    func requestAuthorization() async -> Bool {
        let status = await PHPhotoLibrary.requestAuthorization(for: .readWrite)
        await MainActor.run {
            self.authorizationStatus = status
        }
        return status == .authorized || status == .limited
    }
    
    // MARK: - Photo Fetching
    
    func fetchPhotos(dateRange: DateInterval, minimumSize: Int64) async -> [PHAsset] {
        return await withCheckedContinuation { continuation in
            var assets: [PHAsset] = []
            
            print("Fetching photos from \(dateRange.start) to \(dateRange.end)")
            
            let fetchOptions = PHFetchOptions()
            fetchOptions.predicate = NSPredicate(
                format: "mediaType = %d AND creationDate >= %@ AND creationDate <= %@",
                PHAssetMediaType.image.rawValue,
                dateRange.start as NSDate,
                dateRange.end as NSDate
            )
            fetchOptions.sortDescriptors = [NSSortDescriptor(key: "creationDate", ascending: false)]
            
            let fetchResult = PHAsset.fetchAssets(with: .image, options: fetchOptions)
            
            print("Found \(fetchResult.count) photos in date range")
            
            fetchResult.enumerateObjects { asset, _, _ in
                // We'll filter by size after fetching resource info
                assets.append(asset)
            }
            
            continuation.resume(returning: assets)
        }
    }
    
    // MARK: - Asset Information
    
    func getAssetSize(_ asset: PHAsset) async -> Int64 {
        return await withCheckedContinuation { continuation in
            let resources = PHAssetResource.assetResources(for: asset)
            
            var totalSize: Int64 = 0
            
            for resource in resources {
                if let fileSize = resource.value(forKey: "fileSize") as? Int64 {
                    totalSize += fileSize
                }
            }
            
            continuation.resume(returning: totalSize)
        }
    }
    
    func filterAssetsBySize(_ assets: [PHAsset], minimumSize: Int64) async -> [PHAsset] {
        var filteredAssets: [PHAsset] = []
        
        for asset in assets {
            let size = await getAssetSize(asset)
            if size >= minimumSize {
                filteredAssets.append(asset)
            }
        }
        
        return filteredAssets
    }
    
    func calculateTotalSize(for assets: [PHAsset]) async -> Int64 {
        var totalSize: Int64 = 0
        
        for asset in assets {
            totalSize += await getAssetSize(asset)
        }
        
        return totalSize
    }
    
    // MARK: - Image Loading
    
    func loadImage(from asset: PHAsset, targetSize: CGSize = PHImageManagerMaximumSize) async -> UIImage? {
        return await withCheckedContinuation { continuation in
            let options = PHImageRequestOptions()
            options.deliveryMode = .highQualityFormat
            options.isNetworkAccessAllowed = true
            options.isSynchronous = false
            
            PHImageManager.default().requestImage(
                for: asset,
                targetSize: targetSize,
                contentMode: .aspectFit,
                options: options
            ) { image, _ in
                continuation.resume(returning: image)
            }
        }
    }
    
    // MARK: - Album Management
    
    func fetchAlbums() -> [PHAssetCollection] {
        var albums: [PHAssetCollection] = []
        
        // User albums
        let userAlbums = PHAssetCollection.fetchAssetCollections(
            with: .album,
            subtype: .any,
            options: nil
        )
        userAlbums.enumerateObjects { collection, _, _ in
            albums.append(collection)
        }
        
        // Smart albums
        let smartAlbums = PHAssetCollection.fetchAssetCollections(
            with: .smartAlbum,
            subtype: .any,
            options: nil
        )
        smartAlbums.enumerateObjects { collection, _, _ in
            if collection.assetCollectionSubtype != .smartAlbumAllHidden {
                albums.append(collection)
            }
        }
        
        return albums
    }
    
    func createAlbum(name: String) async -> PHAssetCollection? {
        var albumPlaceholder: PHObjectPlaceholder?
        
        do {
            try await PHPhotoLibrary.shared().performChanges {
                let createAlbumRequest = PHAssetCollectionChangeRequest.creationRequestForAssetCollection(withTitle: name)
                albumPlaceholder = createAlbumRequest.placeholderForCreatedAssetCollection
            }
            
            if let identifier = albumPlaceholder?.localIdentifier {
                let fetchResult = PHAssetCollection.fetchAssetCollections(
                    withLocalIdentifiers: [identifier],
                    options: nil
                )
                return fetchResult.firstObject
            }
        } catch {
            print("Error creating album: \(error)")
        }
        
        return nil
    }
    
    // MARK: - Utility
    
    func formatBytes(_ bytes: Int64) -> String {
        let formatter = ByteCountFormatter()
        formatter.countStyle = .file
        return formatter.string(fromByteCount: bytes)
    }
    
    func estimateCompressedSize(_ originalSize: Int64, compressionRatio: Double = 0.25) -> Int64 {
        return Int64(Double(originalSize) * compressionRatio)
    }
    
    // MARK: - PHPhotoLibraryChangeObserver
    
    func photoLibraryDidChange(_ changeInstance: PHChange) {
        // Update authorization status when library changes
        DispatchQueue.main.async { [weak self] in
            self?.checkAuthorizationStatus()
        }
    }
}