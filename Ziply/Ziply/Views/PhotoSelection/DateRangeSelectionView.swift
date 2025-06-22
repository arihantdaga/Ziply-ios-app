//
//  DateRangeSelectionView.swift
//  Ziply
//
//  Created by Arihant Daga Second on 22/06/25.
//

import SwiftUI

struct DateRangeSelectionView: View {
    @EnvironmentObject var appState: AppState
    @State private var showCustomDatePicker = false
    
    var body: some View {
        VStack(alignment: .leading, spacing: 16) {
            Label("Select Date Range", systemImage: "calendar")
                .font(.headline)
                .padding(.horizontal)
            
            VStack(spacing: 12) {
                HStack(spacing: 12) {
                    DateRangeButton(
                        title: "Last Week",
                        isSelected: appState.photoSelectionViewModel.selectedDateRange == .lastWeek,
                        action: { appState.photoSelectionViewModel.selectedDateRange = .lastWeek }
                    )
                    
                    DateRangeButton(
                        title: "Last Month",
                        isSelected: appState.photoSelectionViewModel.selectedDateRange == .lastMonth,
                        action: { appState.photoSelectionViewModel.selectedDateRange = .lastMonth }
                    )
                    
                    DateRangeButton(
                        title: "Last 3 Months",
                        isSelected: appState.photoSelectionViewModel.selectedDateRange == .last3Months,
                        action: { appState.photoSelectionViewModel.selectedDateRange = .last3Months }
                    )
                }
                
                CustomDateRangeView(
                    showCustomDatePicker: $showCustomDatePicker,
                    isCustomDateSelected: isCustomDateSelected,
                    applyCustomDateRange: applyCustomDateRange
                )
            }
            .padding(.horizontal)
            
            // Date range display
            HStack {
                Text(appState.photoSelectionViewModel.dateRangeText)
                    .font(.caption)
                    .foregroundColor(.secondary)
                Spacer()
            }
            .padding(.horizontal)
        }
        .padding(.vertical)
        .background(Color(.systemGray6))
        .cornerRadius(12)
    }
    
    private var isCustomDateSelected: Bool {
        if case .custom = appState.photoSelectionViewModel.selectedDateRange {
            return true
        }
        return false
    }
    
    private func applyCustomDateRange() {
        let interval = DateInterval(
            start: appState.photoSelectionViewModel.customStartDate,
            end: appState.photoSelectionViewModel.customEndDate
        )
        appState.photoSelectionViewModel.selectedDateRange = .custom(interval)
        withAnimation {
            showCustomDatePicker = false
        }
    }
}