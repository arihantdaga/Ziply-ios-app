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
    @Published var skippedPhotos = 0
    @Published var averageQuality: Float = 0.0
    @Published var estimatedTimeRemaining: TimeInterval = 0
    @Published var compressionResults: [CompressedImageResult] = []
    
    // MARK: - Private Properties
    
    private let compressionService = CompressionService.shared
    private let photoLibraryService = PhotoLibraryService.shared
    private var compressionTask: Task<Void, Never>?
    private var startTime: Date?
    private var isCancelled = false
    
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
        skippedPhotos = 0
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
        // Process all assets
        for asset in assets {
            if isCancelled { break }
            
            await processAsset(asset)
            
            // Update progress
            photosProcessed += 1
            currentProgress = Float(photosProcessed) / Float(totalPhotos)
            updateTimeEstimate()
        }
        
        isCompressing = false
        
        // Calculate final stats
        if !compressionResults.isEmpty {
            averageQuality = calculateAverageQuality()
        }
    }
    
    private func processAsset(_ asset: PHAsset) async {
        do {
            // Compress the image
            let result = try await compressionService.compressImage(from: asset)
            
            // Replace original with compressed version
            _ = try await compressionService.replaceOriginalWithCompressed(result)
            
            // Update stats
            spaceFreed += Int64(result.spaceSaved)
            compressionResults.append(result)
            
            // Update average quality
            averageQuality = calculateAverageQuality()
            
            print("Successfully replaced asset: \(asset.localIdentifier)")
            
        } catch {
            print("Failed to compress/replace asset: \(error)")
            errors += 1
        }
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
        
        // Handle cases where compression might increase size
        if avgRatio >= 1.0 {
            // If file got larger, assume quality is preserved (but compression failed)
            return 0.95
        }
        
        // Normal case: quality decreases as compression increases
        // If compressed to 25% of original (ratio 0.25), quality might be ~85%
        // This gives a range from 70% to 100% quality
        let quality = Float(0.7 + (avgRatio * 0.3))
        
        // Ensure quality is between 0 and 1
        return min(max(quality, 0), 1)
    }
    
    // MARK: - Result Summary
    
    func getCompressionSummary() -> CompressionSummary {
        return CompressionSummary(
            totalPhotos: totalPhotos,
            successfulPhotos: photosProcessed - errors - skippedPhotos,
            failedPhotos: errors,
            skippedPhotos: skippedPhotos,
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
    let skippedPhotos: Int
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