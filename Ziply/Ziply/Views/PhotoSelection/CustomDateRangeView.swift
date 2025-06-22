//
//  CustomDateRangeView.swift
//  Ziply
//
//  Created by Arihant Daga Second on 22/06/25.
//

import SwiftUI

struct CustomDateRangeView: View {
    @EnvironmentObject var appState: AppState
    @Binding var showCustomDatePicker: Bool
    let isCustomDateSelected: Bool
    let applyCustomDateRange: () -> Void
    
    var body: some View {
        VStack(spacing: 12) {
            // Custom date range button
            Button(action: { showCustomDatePicker.toggle() }) {
                HStack {
                    Image(systemName: "calendar")
                    Text("Custom Range")
                    Spacer()
                    Image(systemName: showCustomDatePicker ? "chevron.up" : "chevron.down")
                }
                .font(isCustomDateSelected ? .subheadline.weight(.semibold) : .subheadline)
                .foregroundColor(isCustomDateSelected ? .white : .primary)
                .padding(.vertical, 10)
                .padding(.horizontal, 16)
                .frame(maxWidth: .infinity)
                .background(
                    isCustomDateSelected ? Color.blue : Color(.systemGray5)
                )
                .cornerRadius(8)
            }
            
            // Custom date pickers
            if showCustomDatePicker {
                VStack(spacing: 16) {
                    HStack {
                        Text("From:")
                            .font(.subheadline)
                            .foregroundColor(.secondary)
                            .frame(width: 50, alignment: .leading)
                        
                        DatePicker(
                            "",
                            selection: $appState.photoSelectionViewModel.customStartDate,
                            in: ...appState.photoSelectionViewModel.customEndDate,
                            displayedComponents: .date
                        )
                        .datePickerStyle(CompactDatePickerStyle())
                        .labelsHidden()
                    }
                    
                    HStack {
                        Text("To:")
                            .font(.subheadline)
                            .foregroundColor(.secondary)
                            .frame(width: 50, alignment: .leading)
                        
                        DatePicker(
                            "",
                            selection: $appState.photoSelectionViewModel.customEndDate,
                            in: appState.photoSelectionViewModel.customStartDate...Date(),
                            displayedComponents: .date
                        )
                        .datePickerStyle(CompactDatePickerStyle())
                        .labelsHidden()
                    }
                    
                    Button(action: applyCustomDateRange) {
                        Text("Apply Custom Range")
                            .font(.subheadline.weight(.medium))
                            .foregroundColor(.white)
                            .frame(maxWidth: .infinity)
                            .padding(.vertical, 10)
                            .background(Color.blue)
                            .cornerRadius(8)
                    }
                }
                .padding()
                .background(Color(.systemGray6))
                .cornerRadius(8)
                .transition(.opacity.combined(with: .move(edge: .top)))
            }
        }
    }
}