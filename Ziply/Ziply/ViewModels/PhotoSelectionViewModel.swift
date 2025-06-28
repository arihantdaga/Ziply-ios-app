//
//  PhotoSelectionViewModel.swift
//  Ziply
//
//  Created by Arihant Daga Second on 22/06/25.
//

import SwiftUI
import Photos

enum DateRangeOption: Equatable {
    case lastWeek
    case lastMonth
    case last3Months
    case custom(DateInterval)
    
    var dateInterval: DateInterval {
        let now = Date()
        let startDate: Date
        
        switch self {
        case .lastWeek:
            startDate = Calendar.current.date(byAdding: .day, value: -7, to: now) ?? now
            return DateInterval(start: startDate, end: now)
        case .lastMonth:
            startDate = Calendar.current.date(byAdding: .month, value: -1, to: now) ?? now
            return DateInterval(start: startDate, end: now)
        case .last3Months:
            startDate = Calendar.current.date(byAdding: .month, value: -3, to: now) ?? now
            return DateInterval(start: startDate, end: now)
        case .custom(let interval):
            return interval
        }
    }
}

@MainActor
class PhotoSelectionViewModel: ObservableObject {
    @Published var selectedDateRange: DateRangeOption = .lastMonth
    @Published var customStartDate = Calendar.current.date(byAdding: .month, value: -1, to: Date()) ?? Date()
    @Published var customEndDate = Date()
    @Published var minimumPhotoSize: Float = 2.5 // MB
    @Published var isSearching = false
    @Published var photosFound = 0
    @Published var totalSize: Int64 = 0
    @Published var selectedAssets: [PHAsset] = []
    
    private let photoService = PhotoLibraryService.shared
    private var searchTask: Task<Void, Never>?
    
    var dateRangeText: String {
        let formatter = DateFormatter()
        formatter.dateFormat = "MMM d, yyyy"
        let interval = selectedDateRange.dateInterval
        
        switch selectedDateRange {
        case .custom:
            return "Custom: \(formatter.string(from: interval.start)) - \(formatter.string(from: interval.end))"
        default:
            return "\(formatter.string(from: interval.start)) - \(formatter.string(from: interval.end))"
        }
    }
    
    var totalSizeText: String {
        photoService.formatBytes(totalSize)
    }
    
    var estimatedSavings: Int64 {
        photoService.estimateCompressedSize(totalSize)
    }
    
    var estimatedSavingsText: String {
        let savings = totalSize - estimatedSavings
        return photoService.formatBytes(savings)
    }
    
    var compressionPercentage: Int {
        guard totalSize > 0 else { return 0 }
        let savings = totalSize - estimatedSavings
        return Int((Double(savings) / Double(totalSize)) * 100)
    }
    
    func findPhotos() async {
        // Cancel any existing search
        searchTask?.cancel()
        
        // Create new search task
        searchTask = Task {
            isSearching = true
            selectedAssets = []
            photosFound = 0
            totalSize = 0
            
            // Check authorization first
            let status = photoService.authorizationStatus
            print("Photo authorization status: \(status.rawValue)")
            
            if status != .authorized && status != .limited {
                print("No photo access - requesting authorization")
                let granted = await photoService.requestAuthorization()
                if !granted {
                    print("Authorization denied")
                    isSearching = false
                    return
                }
            }
            
            // Convert MB to bytes
            let minimumSizeInBytes = Int64(minimumPhotoSize * 1024 * 1024)
            print("Minimum size filter: \(minimumSizeInBytes) bytes (\(minimumPhotoSize) MB)")
            
            // Fetch photos in date range
            let assets = await photoService.fetchPhotos(
                dateRange: selectedDateRange.dateInterval,
                minimumSize: minimumSizeInBytes
            )
            
            // Check if cancelled
            if Task.isCancelled {
                isSearching = false
                return
            }
            
            print("Found \(assets.count) assets before size filtering")
            
            // Filter by size with progressive updates
            var filteredAssets: [PHAsset] = []
            var runningSize: Int64 = 0
            
            for asset in assets {
                // Check if cancelled
                if Task.isCancelled {
                    isSearching = false
                    return
                }
                
                let assetSize = await photoService.getAssetSize(asset)
                if assetSize >= minimumSizeInBytes {
                    filteredAssets.append(asset)
                    runningSize += assetSize
                    
                    // Update UI progressively
                    photosFound = filteredAssets.count
                    totalSize = runningSize
                    selectedAssets = filteredAssets
                    
                    // Small delay to make the counting visible
                    try? await Task.sleep(nanoseconds: 10_000_000) // 10ms
                }
            }
            
            print("Found \(filteredAssets.count) assets after size filtering")
            print("Total size: \(runningSize) bytes")
            
            isSearching = false
        }
        
        await searchTask?.value
    }
    
    func cancelSearch() {
        searchTask?.cancel()
        isSearching = false
    }
    
    func resetSearch() {
        searchTask?.cancel()
        selectedAssets = []
        photosFound = 0
        totalSize = 0
        // Don't set isSearching to false here - let findPhotos manage it
    }
}