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
            // Main content
            ScrollView {
                VStack(spacing: 24) {
                    // Subtitle
                    Text("We found photos matching your criteria")
                        .font(.subheadline)
                        .foregroundColor(.secondary)
                        .padding(.top)
                    
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
                        Image(systemName: "wand.and.stars")
                        Text("Start Compression")
                            .fontWeight(.semibold)
                    }
                    .foregroundColor(.white)
                    .frame(maxWidth: .infinity)
                    .padding(.vertical, 16)
                    .background(Color.green)
                    .cornerRadius(12)
                }
                .padding()
            }
            .background(Color(.systemBackground))
        }
        .navigationTitle("Ready to Compress")
        .navigationBarTitleDisplayMode(.large)
        .background(
            NavigationLink(isActive: $showCompressionProgress) {
                CompressionProgressView()
            } label: {
                EmptyView()
            }
        )
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