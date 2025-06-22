//
//  CompressionResultsView.swift
//  Ziply
//
//  Created by Arihant Daga Second on 22/06/25.
//

import SwiftUI

struct CompressionResultsView: View {
    @Environment(\.dismiss) private var dismiss
    @State private var showingDetails = false
    
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
                            
                            Text("1.8 GB")
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
                                    value: "327",
                                    subtitle: "Photos\nCompressed",
                                    color: .blue
                                )
                                
                                ResultStatCard(
                                    value: "75%",
                                    subtitle: "Size\nReduction",
                                    color: .blue
                                )
                            }
                            
                            HStack(spacing: 16) {
                                ResultStatCard(
                                    value: "94%",
                                    subtitle: "Quality\nRetained",
                                    color: .secondary
                                )
                                
                                ResultStatCard(
                                    value: "3:47",
                                    subtitle: "Time\nTaken",
                                    color: .secondary
                                )
                            }
                        }
                        .padding(.horizontal)
                        
                        Spacer(minLength: 40)
                    }
                }
                
                // Bottom Buttons
                VStack(spacing: 12) {
                    HStack(spacing: 12) {
                        Button(action: viewDetails) {
                            Text("View Details")
                                .fontWeight(.medium)
                                .foregroundColor(.primary)
                                .frame(maxWidth: .infinity)
                                .padding(.vertical, 16)
                                .background(Color(.systemGray5))
                                .cornerRadius(12)
                        }
                        
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
    
    private func viewDetails() {
        // Show details view
        showingDetails = true
    }
    
    private func compressMore() {
        // Dismiss and go back to photo selection
        dismiss()
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
    CompressionResultsView()
}