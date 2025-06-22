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
                    DateRangeSelectionView()
                        .padding(.horizontal)
                    
                    // Minimum Photo Size
                    MinimumSizeSelectionView()
                        .padding(.horizontal)
                    
                    Spacer(minLength: 40)
                    
                    // Find Photos Button
                    findPhotosButton
                }
                .padding(.vertical)
            }
            .navigationTitle("Compress Photos")
            .navigationBarTitleDisplayMode(.large)
            .background(navigationLink)
        }
    }
    
    private var findPhotosButton: some View {
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
    
    private var navigationLink: some View {
        NavigationLink(isActive: $showPreviewResults) {
            PreviewResultsView()
        } label: {
            EmptyView()
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