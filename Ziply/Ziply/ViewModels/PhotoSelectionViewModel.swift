//
//  PhotoSelectionViewModel.swift
//  Ziply
//
//  Created by Arihant Daga Second on 22/06/25.
//

import SwiftUI
import Photos

enum DateRangeOption {
    case lastWeek
    case lastMonth
    case last3Months
    
    var dateInterval: DateInterval {
        let now = Date()
        let startDate: Date
        
        switch self {
        case .lastWeek:
            startDate = Calendar.current.date(byAdding: .day, value: -7, to: now) ?? now
        case .lastMonth:
            startDate = Calendar.current.date(byAdding: .month, value: -1, to: now) ?? now
        case .last3Months:
            startDate = Calendar.current.date(byAdding: .month, value: -3, to: now) ?? now
        }
        
        return DateInterval(start: startDate, end: now)
    }
}

@MainActor
class PhotoSelectionViewModel: ObservableObject {
    @Published var selectedDateRange: DateRangeOption = .lastMonth
    @Published var minimumPhotoSize: Float = 2.5 // MB
    @Published var isSearching = false
    @Published var photosFound = 0
    @Published var totalSize: Int64 = 0
    
    var dateRangeText: String {
        let formatter = DateFormatter()
        formatter.dateFormat = "MMM d, yyyy"
        let interval = selectedDateRange.dateInterval
        return "\(formatter.string(from: interval.start)) - \(formatter.string(from: interval.end))"
    }
    
    func findPhotos() async {
        isSearching = true
        
        // TODO: Implement actual photo fetching logic
        // For now, simulate finding photos
        try? await Task.sleep(nanoseconds: 1_000_000_000) // 1 second delay
        
        photosFound = 327 // Simulated value from mockup
        totalSize = 1_800_000_000 // 1.8 GB in bytes
        
        isSearching = false
    }
}