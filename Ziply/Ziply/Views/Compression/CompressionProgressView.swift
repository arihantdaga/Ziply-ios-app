//
//  CompressionProgressView.swift
//  Ziply
//
//  Created by Arihant Daga Second on 22/06/25.
//

import SwiftUI
import Photos

struct CompressionProgressView: View {
    @StateObject private var viewModel = CompressionViewModel()
    @State private var showResults = false
    @Environment(\.dismiss) private var dismiss
    @EnvironmentObject var appState: AppState
    
    let assets: [PHAsset]
    
    var body: some View {
        ZStack {
            // Dark background
            Color.black
                .ignoresSafeArea()
            
            VStack(spacing: 40) {
                Spacer()
                
                // Circular Progress
                ZStack {
                    // Background circle
                    Circle()
                        .stroke(Color.gray.opacity(0.3), lineWidth: 10)
                        .frame(width: 200, height: 200)
                    
                    // Progress circle
                    Circle()
                        .trim(from: 0, to: CGFloat(viewModel.currentProgress))
                        .stroke(
                            LinearGradient(
                                colors: [Color.blue, Color.blue.opacity(0.7)],
                                startPoint: .topLeading,
                                endPoint: .bottomTrailing
                            ),
                            style: StrokeStyle(lineWidth: 10, lineCap: .round)
                        )
                        .frame(width: 200, height: 200)
                        .rotationEffect(.degrees(-90))
                        .animation(.easeInOut(duration: 0.5), value: viewModel.currentProgress)
                    
                    // Percentage text
                    VStack(spacing: 8) {
                        Text("\(viewModel.progressPercentage)%")
                            .font(.system(size: 48, weight: .bold))
                            .foregroundColor(.white)
                        
                        Text("Compressing")
                            .font(.subheadline)
                            .foregroundColor(.white.opacity(0.8))
                    }
                }
                
                // Title
                Text("Optimizing Your Photos")
                    .font(.title)
                    .fontWeight(.bold)
                    .foregroundColor(.white)
                
                // Progress subtitle
                VStack(spacing: 4) {
                    Text("\(viewModel.photosProcessed) of \(viewModel.totalPhotos) photos processed")
                        .font(.subheadline)
                        .foregroundColor(.white.opacity(0.8))
                    
                    if viewModel.skippedPhotos > 0 {
                        Text("(\(viewModel.skippedPhotos) already compressed)")
                            .font(.caption)
                            .foregroundColor(.yellow.opacity(0.8))
                    }
                }
                
                // Stats Grid
                VStack(spacing: 24) {
                    HStack(spacing: 40) {
                        StatItem(
                            value: viewModel.formattedSpaceFreed,
                            label: "Space Freed",
                            color: .white
                        )
                        
                        StatItem(
                            value: viewModel.formattedTimeRemaining,
                            label: "Time Remaining",
                            color: .white
                        )
                    }
                    
                    HStack(spacing: 40) {
                        StatItem(
                            value: "\(Int(viewModel.averageQuality * 100))%",
                            label: "Avg. Quality",
                            color: .white
                        )
                        
                        StatItem(
                            value: "\(viewModel.errors)",
                            label: "Errors",
                            color: .white
                        )
                    }
                }
                .padding(.horizontal, 40)
                
                Spacer()
                
                // Cancel button
                Button(action: cancelCompression) {
                    Text("Cancel")
                        .foregroundColor(.white)
                        .padding(.horizontal, 40)
                        .padding(.vertical, 12)
                        .background(
                            RoundedRectangle(cornerRadius: 25)
                                .stroke(Color.white.opacity(0.5), lineWidth: 1)
                        )
                }
                .padding(.bottom, 50)
            }
        }
        .navigationBarHidden(true)
        .onAppear {
            viewModel.startCompression(assets: assets)
        }
        .onChange(of: viewModel.isCompressing) { isCompressing in
            if !isCompressing && viewModel.photosProcessed > 0 {
                showResults = true
            }
        }
        .fullScreenCover(isPresented: $showResults, onDismiss: {
            // When results are dismissed, reset navigation to go home
            appState.resetToHome()
            dismiss()
        }) {
            CompressionResultsView(summary: viewModel.getCompressionSummary())
                .environmentObject(appState)
        }
    }
    
    private func cancelCompression() {
        viewModel.cancelCompression()
        dismiss()
    }
}

struct StatItem: View {
    let value: String
    let label: String
    let color: Color
    
    var body: some View {
        VStack(spacing: 8) {
            Text(value)
                .font(.title2)
                .fontWeight(.bold)
                .foregroundColor(color)
            
            Text(label)
                .font(.caption)
                .foregroundColor(color.opacity(0.8))
        }
    }
}

#Preview {
    CompressionProgressView(assets: [])
        .environmentObject(AppState.shared)
}