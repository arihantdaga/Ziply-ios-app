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
        
        print("Found \(assets.count) assets before size filtering")
        
        // Filter by size
        let filteredAssets = await photoService.filterAssetsBySize(
            assets,
            minimumSize: minimumSizeInBytes
        )
        
        print("Found \(filteredAssets.count) assets after size filtering")
        
        // Calculate total size
        let size = await photoService.calculateTotalSize(for: filteredAssets)
        print("Total size: \(size) bytes")
        
        // Update UI
        selectedAssets = filteredAssets
        photosFound = filteredAssets.count
        totalSize = size
        
        isSearching = false
    }
}