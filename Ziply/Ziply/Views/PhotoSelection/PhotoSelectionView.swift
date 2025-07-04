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
        .onChange(of: appState.shouldResetNavigation) { shouldReset in
            if shouldReset {
                showPreviewResults = false
                appState.shouldResetNavigation = false
            }
        }
    }
    
    private var findPhotosButton: some View {
        Button(action: findPhotos) {
            HStack {
                Image(systemName: "bolt.fill")
                Image(systemName: "magnifyingglass")
                Text("Find Photos to Compress")
                    .fontWeight(.semibold)
            }
            .foregroundColor(.white)
            .frame(maxWidth: .infinity)
            .padding(.vertical, 16)
            .background(Color.green)
            .cornerRadius(12)
        }
        .padding(.horizontal)
    }
    
    private var navigationLink: some View {
        NavigationLink(isActive: $showPreviewResults) {
            PreviewResultsView()
                .environmentObject(appState)
        } label: {
            EmptyView()
        }
    }
    
    private func findPhotos() {
        // Reset search state and mark as searching
        appState.photoSelectionViewModel.resetSearch()
        appState.photoSelectionViewModel.isSearching = true
        
        // Navigate immediately
        showPreviewResults = true
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