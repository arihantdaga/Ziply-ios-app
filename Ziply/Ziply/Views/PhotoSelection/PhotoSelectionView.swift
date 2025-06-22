//
//  PhotoSelectionView.swift
//  Ziply
//
//  Created by Arihant Daga Second on 22/06/25.
//

import SwiftUI

struct PhotoSelectionView: View {
  @EnvironmentObject var appState: AppState
  @State private var showPreviewResults = false
  
  var body: some View {
    NavigationView {
      ScrollView {
        VStack(spacing: 24) {
          // Date Range Selection
          VStack(alignment: .leading, spacing: 16) {
            Label("Select Date Range", systemImage: "calendar")
              .font(.headline)
              .padding(.horizontal)

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
          .padding(.horizontal)

          // Minimum Photo Size
          VStack(alignment: .leading, spacing: 16) {
            HStack {
              Text("Minimum Photo Size")
                .font(.headline)

              Spacer()

              Text("\(String(format: "%.1f", appState.photoSelectionViewModel.minimumPhotoSize)) MB")
                .font(.subheadline)
                .fontWeight(.semibold)
                .foregroundColor(.white)
                .padding(.horizontal, 12)
                .padding(.vertical, 6)
                .background(Color.orange)
                .cornerRadius(8)
            }

            Text("Only compress photos larger than this size")
              .font(.caption)
              .foregroundColor(.secondary)

            HStack {
              Text("100 KB")
                .font(.caption)
                .foregroundColor(.secondary)

              Slider(
                value: $appState.photoSelectionViewModel.minimumPhotoSize,
                in: 0.1...5.0,
                step: 0.1
              )
              .accentColor(.blue)

              Text("5 MB")
                .font(.caption)
                .foregroundColor(.secondary)
            }
          }
          .padding()
          .background(Color(.systemGray6))
          .cornerRadius(12)
          .padding(.horizontal)

          Spacer(minLength: 40)

          // Find Photos Button
          Button(action: findPhotos) {
            HStack {
              if appState.photoSelectionViewModel.isSearching {
                ProgressView()
                  .progressViewStyle(CircularProgressViewStyle())
                  .scaleEffect(0.8)
                  .foregroundColor(.white)
              } else {
                Image(systemName: "bolt.fill")
                Image(systemName: "magnifyingglass")
              }
              Text(appState.photoSelectionViewModel.isSearching ? "Searching..." : "Find Photos to Compress")
                .fontWeight(.semibold)
            }
            .foregroundColor(.white)
            .frame(maxWidth: .infinity)
            .padding(.vertical, 16)
            .background(Color.green)
            .cornerRadius(12)
          }
          .padding(.horizontal)
          .disabled(appState.photoSelectionViewModel.isSearching)
          .opacity(appState.photoSelectionViewModel.isSearching ? 0.6 : 1.0)
        }
        .padding(.vertical)
      }
      .navigationTitle("Compress Photos")
      .navigationBarTitleDisplayMode(.large)
      .background(
        NavigationLink(isActive: $showPreviewResults) {
          PreviewResultsView()
        } label: {
          EmptyView()
        }
      )
    }
  }

  private func findPhotos() {
    Task {
      await appState.photoSelectionViewModel.findPhotos()
      if appState.photoSelectionViewModel.photosFound > 0 {
        showPreviewResults = true
      } else {
        // Show alert that no photos were found
      }
    }
  }
}

struct DateRangeButton: View {
  let title: String
  let isSelected: Bool
  let action: () -> Void

  var body: some View {
    Button(action: action) {
      Text(title)
        .font(.subheadline)
        .fontWeight(isSelected ? .semibold : .regular)
        .foregroundColor(isSelected ? .white : .primary)
        .padding(.vertical, 10)
        .frame(maxWidth: .infinity)
        .background(
          isSelected ? Color.blue : Color(.systemGray5)
        )
        .cornerRadius(8)
    }
  }
}

#Preview {
	PhotoSelectionView()
    .environmentObject(AppState.shared)
}