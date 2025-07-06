//
//  CompressionResultsView.swift
//  Ziply
//
//  Created by Arihant Daga Second on 22/06/25.
//

import SwiftUI

struct CompressionResultsView: View {
    @Environment(\.dismiss) private var dismiss
    @EnvironmentObject var appState: AppState
    
    let summary: CompressionSummary
    
    var body: some View {
        NavigationView {
            VStack(spacing: 0) {
                ScrollView {
                    VStack(spacing: 40) {
                        // Success Icon
                        ZStack {
                            Circle()
                                .fill(Color.green)
                                .frame(width: 120, height: 120)
                            
                            Image(systemName: "checkmark")
                                .font(.system(size: 60, weight: .bold))
                                .foregroundColor(.white)
                        }
                        .padding(.top, 40)
                        
                        // Title
                        VStack(spacing: 12) {
                            Text("All Done!")
                                .font(.largeTitle)
                                .fontWeight(.bold)
                            
                            Text("Your photos have been compressed")
                                .font(.body)
                                .foregroundColor(.secondary)
                        }
                        
                        // Total Space Saved Card
                        VStack(spacing: 16) {
                            Text("Total Space Saved")
                                .font(.headline)
                                .foregroundColor(.white)
                            
                            Text(PhotoLibraryService.shared.formatBytes(summary.totalSpaceSaved))
                                .font(.system(size: 56, weight: .bold))
                                .foregroundColor(.white)
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
                        
                        // Stats Grid
                        VStack(spacing: 16) {
                            HStack(spacing: 16) {
                                ResultStatCard(
                                    value: "\(summary.successfulPhotos)",
                                    subtitle: "Photos\nCompressed",
                                    color: .blue
                                )
                                
                                ResultStatCard(
                                    value: "\(Int(summary.compressionPercentage))%",
                                    subtitle: "Size\nReduction",
                                    color: .blue
                                )
                            }
                            
                            HStack(spacing: 16) {
                                ResultStatCard(
                                    value: "\(Int(summary.averageQuality * 100))%",
                                    subtitle: "Quality\nRetained",
                                    color: .secondary
                                )
                                
                                ResultStatCard(
                                    value: summary.formattedTimeTaken,
                                    subtitle: "Time\nTaken",
                                    color: .secondary
                                )
                            }
                            
                            // Show skipped photos info if any
                            if summary.skippedPhotos > 0 {
                                HStack {
                                    Image(systemName: "info.circle.fill")
                                        .foregroundColor(.yellow)
                                    Text("\(summary.skippedPhotos) photos were already compressed")
                                        .font(.caption)
                                        .foregroundColor(.secondary)
                                }
                                .padding(.horizontal)
                                .padding(.vertical, 12)
                                .background(Color(.systemGray6))
                                .cornerRadius(8)
                            }
                        }
                        .padding(.horizontal)
                        
                        // Can Delete Album Info
                        VStack(spacing: 16) {
                            HStack(spacing: 12) {
                                Image(systemName: "info.circle.fill")
                                    .foregroundColor(.blue)
                                    .font(.title2)
                                
                                VStack(alignment: .leading, spacing: 8) {
                                    Text("Ready to Delete Originals")
                                        .font(.headline)
                                    
                                    Text("Original photos have been added to the \"Can Delete - Ziply\" album. You can safely delete these photos manually when you're ready to free up the space.")
                                        .font(.subheadline)
                                        .foregroundColor(.secondary)
                                        .fixedSize(horizontal: false, vertical: true)
                                }
                                
                                Spacer()
                            }
                            
                            Button(action: openPhotosApp) {
                                Label("Open Photos App", systemImage: "photo.on.rectangle")
                                    .font(.subheadline)
                                    .foregroundColor(.blue)
                            }
                        }
                        .padding()
                        .background(Color.blue.opacity(0.1))
                        .cornerRadius(12)
                        .padding(.horizontal)
                        
                        Spacer(minLength: 40)
                    }
                }
                
                // Bottom Button
                VStack(spacing: 12) {
                    Button(action: compressMore) {
                        Text("Compress More")
                            .fontWeight(.semibold)
                            .foregroundColor(.white)
                            .frame(maxWidth: .infinity)
                            .padding(.vertical, 16)
                            .background(Color.blue)
                            .cornerRadius(12)
                    }
                }
                .padding()
                .background(Color(.systemBackground))
            }
            .navigationBarTitleDisplayMode(.inline)
            .toolbar {
                ToolbarItem(placement: .navigationBarTrailing) {
                    Button("Done") {
                        dismiss()
                    }
                }
            }
        }
    }
    
    private func compressMore() {
        // This will trigger navigation reset and dismiss
        dismiss()
    }
    
    private func openPhotosApp() {
        // Open Photos app - iOS doesn't allow deep linking to specific albums
        if let url = URL(string: "photos-redirect://") {
            UIApplication.shared.open(url)
        }
    }
}

struct ResultStatCard: View {
    let value: String
    let subtitle: String
    let color: Color
    
    var body: some View {
        VStack(spacing: 8) {
            Text(value)
                .font(.title)
                .fontWeight(.bold)
                .foregroundColor(color == .secondary ? .primary : color)
            
            Text(subtitle)
                .font(.caption)
                .multilineTextAlignment(.center)
                .foregroundColor(.secondary)
        }
        .frame(maxWidth: .infinity)
        .padding(.vertical, 20)
        .background(Color(.systemGray6))
        .cornerRadius(12)
    }
}

#Preview {
    CompressionResultsView(summary: CompressionSummary(
        totalPhotos: 327,
        successfulPhotos: 327,
        failedPhotos: 0,
        skippedPhotos: 0,
        totalSpaceSaved: 1932735283,
        averageCompressionRatio: 0.25,
        averageQuality: 0.94,
        timeTaken: 227
    ))
    .environmentObject(AppState.shared)
}
