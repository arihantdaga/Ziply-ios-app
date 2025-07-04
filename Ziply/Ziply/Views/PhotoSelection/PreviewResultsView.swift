//
//  PreviewResultsView.swift
//  Ziply
//
//  Created by Arihant Daga Second on 22/06/25.
//

import SwiftUI

struct PreviewResultsView: View {
    @EnvironmentObject var appState: AppState
    @State private var showCompressionProgress = false
    
    var body: some View {
        VStack(spacing: 0) {
            if appState.photoSelectionViewModel.isSearching && appState.photoSelectionViewModel.photosFound == 0 {
                // Loading state - only show while no photos found yet
                loadingView
            } else if !appState.photoSelectionViewModel.isSearching && appState.photoSelectionViewModel.photosFound == 0 {
                // No photos found state - only show when search is complete
                noPhotosView
            } else {
                // Results view - show as soon as we have photos, even if still searching
                resultsView
            }
        }
        .navigationTitle(appState.photoSelectionViewModel.isSearching && appState.photoSelectionViewModel.photosFound == 0 ? "Searching..." : "Ready to Compress")
        .navigationBarTitleDisplayMode(.large)
        .background(
            NavigationLink(isActive: $showCompressionProgress) {
                CompressionProgressView(assets: appState.photoSelectionViewModel.selectedAssets)
            } label: {
                EmptyView()
            }
        )
        .onChange(of: appState.shouldResetNavigation) { shouldReset in
            if shouldReset {
                showCompressionProgress = false
            }
        }
        .onAppear {
            // Start search when view appears
            Task {
                await appState.photoSelectionViewModel.findPhotos()
            }
        }
        .onDisappear {
            // Cancel search if user goes back
            appState.photoSelectionViewModel.cancelSearch()
        }
    }
    
    private var loadingView: some View {
        VStack(spacing: 32) {
            Spacer()
            
            ProgressView()
                .progressViewStyle(CircularProgressViewStyle())
                .scaleEffect(1.5)
            
            VStack(spacing: 16) {
                Text("Searching your photo library...")
                    .font(.headline)
                
                // Live update of found photos
                if appState.photoSelectionViewModel.photosFound > 0 {
                    VStack(spacing: 8) {
                        Text("\(appState.photoSelectionViewModel.photosFound)")
                            .font(.system(size: 48, weight: .bold))
                            .foregroundColor(.blue)
                        
                        Text("Photos found")
                            .font(.subheadline)
                            .foregroundColor(.secondary)
                        
                        Text(appState.photoSelectionViewModel.totalSizeText)
                            .font(.caption)
                            .foregroundColor(.secondary)
                    }
                    .padding(.top)
                }
            }
            
            Spacer()
            Spacer()
        }
        .frame(maxWidth: .infinity, maxHeight: .infinity)
        .background(Color(.systemBackground))
    }
    
    private var noPhotosView: some View {
        VStack(spacing: 24) {
            Spacer()
            
            Image(systemName: "photo.on.rectangle.angled")
                .font(.system(size: 64))
                .foregroundColor(.secondary)
            
            VStack(spacing: 12) {
                Text("No Photos Found")
                    .font(.title2)
                    .fontWeight(.semibold)
                
                Text("No photos match your selected criteria.\nTry adjusting the filters.")
                    .font(.body)
                    .foregroundColor(.secondary)
                    .multilineTextAlignment(.center)
            }
            
            Button(action: { 
                // This will be handled by navigation back
            }) {
                Label("Adjust Filters", systemImage: "slider.horizontal.3")
                    .foregroundColor(.blue)
            }
            
            Spacer()
            Spacer()
        }
        .frame(maxWidth: .infinity, maxHeight: .infinity)
        .background(Color(.systemBackground))
    }
    
    private var resultsView: some View {
        VStack(spacing: 0) {
            // Main content
            ScrollView {
                VStack(spacing: 24) {
                    // Subtitle
                    if appState.photoSelectionViewModel.isSearching {
                        HStack(spacing: 8) {
                            ProgressView()
                                .progressViewStyle(CircularProgressViewStyle())
                                .scaleEffect(0.8)
                            Text("Still searching...")
                                .font(.subheadline)
                                .foregroundColor(.secondary)
                        }
                        .padding(.top)
                    } else {
                        Text("We found photos matching your criteria")
                            .font(.subheadline)
                            .foregroundColor(.secondary)
                            .padding(.top)
                    }
                    
                    // Stats Cards
                    HStack(spacing: 16) {
                        // Photos Found Card
                        VStack(spacing: 12) {
                            Text("\(appState.photoSelectionViewModel.photosFound)")
                                .font(.system(size: 48, weight: .bold))
                                .foregroundColor(.white)
                            
                            Text("Photos")
                                .font(.subheadline)
                                .foregroundColor(.white)
                            Text("Found")
                                .font(.subheadline)
                                .foregroundColor(.white)
                        }
                        .frame(maxWidth: .infinity)
                        .padding(.vertical, 24)
                        .background(Color.blue)
                        .cornerRadius(16)
                        
                        // Total Size Card
                        VStack(spacing: 12) {
                            Text(appState.photoSelectionViewModel.totalSizeText)
                                .font(.system(size: 36, weight: .bold))
                                .foregroundColor(.primary)
                            
                            Text("Total Size")
                                .font(.subheadline)
                                .foregroundColor(.secondary)
                        }
                        .frame(maxWidth: .infinity)
                        .padding(.vertical, 32)
                        .background(Color(.systemGray6))
                        .cornerRadius(16)
                    }
                    .padding(.horizontal)
                    
                    // Applied Filters
                    VStack(alignment: .leading, spacing: 16) {
                        Text("Applied Filters")
                            .font(.headline)
                            .foregroundColor(.secondary)
                        
                        VStack(spacing: 12) {
                            HStack {
                                Label("Date Range", systemImage: "calendar")
                                    .foregroundColor(.secondary)
                                Spacer()
                                Text(appState.photoSelectionViewModel.dateRangeText)
                                    .foregroundColor(.blue)
                                    .fontWeight(.medium)
                            }
                            
                            Divider()
                            
                            HStack {
                                Label("Minimum Size", systemImage: "ruler")
                                    .foregroundColor(.secondary)
                                Spacer()
                                Text("\(String(format: "%.1f", appState.photoSelectionViewModel.minimumPhotoSize)) MB")
                                    .foregroundColor(.blue)
                                    .fontWeight(.medium)
                            }
                        }
                        .padding()
                        .background(Color(.systemGray6))
                        .cornerRadius(12)
                    }
                    .padding(.horizontal)
                    
                    // Space Savings Card
                    VStack(spacing: 16) {
                        Text("Estimated Space Savings")
                            .font(.headline)
                            .foregroundColor(.white)
                        
                        Text("~\(appState.photoSelectionViewModel.estimatedSavingsText)")
                            .font(.system(size: 48, weight: .bold))
                            .foregroundColor(.white)
                        
                        Text("≈ \(appState.photoSelectionViewModel.compressionPercentage)% reduction")
                            .font(.subheadline)
                            .foregroundColor(.white.opacity(0.9))
                    }
                    .frame(maxWidth: .infinity)
                    .padding(.vertical, 32)
                    .background(
                        LinearGradient(
                            colors: [Color.green, Color.green.opacity(0.8)],
                            startPoint: .topLeading,
                            endPoint: .bottomTrailing
                        )
                    )
                    .cornerRadius(16)
                    .padding(.horizontal)
                    
                    Spacer(minLength: 100)
                }
            }
            
            // Bottom CTA
            VStack(spacing: 0) {
                Divider()
                
                Button(action: startCompression) {
                    HStack {
                        if appState.photoSelectionViewModel.isSearching {
                            ProgressView()
                                .progressViewStyle(CircularProgressViewStyle(tint: .white))
                                .scaleEffect(0.8)
                        } else {
                            Image(systemName: "wand.and.stars")
                        }
                        Text(appState.photoSelectionViewModel.isSearching ? "Still Searching..." : "Start Compression")
                            .fontWeight(.semibold)
                    }
                    .foregroundColor(.white)
                    .frame(maxWidth: .infinity)
                    .padding(.vertical, 16)
                    .background(appState.photoSelectionViewModel.isSearching ? Color.gray : Color.green)
                    .cornerRadius(12)
                }
                .disabled(appState.photoSelectionViewModel.isSearching)
                .padding()
            }
            .background(Color(.systemBackground))
        }
    }
    
    private func startCompression() {
        showCompressionProgress = true
    }
}

#Preview {
    NavigationView {
        PreviewResultsView()
    }
    .environmentObject(AppState.shared)
}