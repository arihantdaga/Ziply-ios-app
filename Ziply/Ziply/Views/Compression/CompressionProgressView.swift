//
//  CompressionProgressView.swift
//  Ziply
//
//  Created by Arihant Daga Second on 22/06/25.
//

import SwiftUI

struct CompressionProgressView: View {
    @State private var progress: CGFloat = 0.67
    @State private var photosProcessed = 218
    @State private var totalPhotos = 327
    @State private var showResults = false
    @Environment(\.dismiss) private var dismiss
    
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
                        .trim(from: 0, to: progress)
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
                        .animation(.easeInOut(duration: 0.5), value: progress)
                    
                    // Percentage text
                    VStack(spacing: 8) {
                        Text("\(Int(progress * 100))%")
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
                Text("\(photosProcessed) of \(totalPhotos) photos processed")
                    .font(.subheadline)
                    .foregroundColor(.white.opacity(0.8))
                
                // Stats Grid
                VStack(spacing: 24) {
                    HStack(spacing: 40) {
                        StatItem(
                            value: "1.2 GB",
                            label: "Space Freed",
                            color: .white
                        )
                        
                        StatItem(
                            value: "2:34",
                            label: "Time Remaining",
                            color: .white
                        )
                    }
                    
                    HStack(spacing: 40) {
                        StatItem(
                            value: "94%",
                            label: "Avg. Quality",
                            color: .white
                        )
                        
                        StatItem(
                            value: "0",
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
            simulateProgress()
        }
        .fullScreenCover(isPresented: $showResults) {
            CompressionResultsView()
        }
    }
    
    private func simulateProgress() {
        // Simulate progress for demo
        Timer.scheduledTimer(withTimeInterval: 0.1, repeats: true) { timer in
            if progress < 1.0 {
                progress += 0.01
                photosProcessed = Int(Double(totalPhotos) * Double(progress))
            } else {
                timer.invalidate()
                showResults = true
            }
        }
    }
    
    private func cancelCompression() {
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
    CompressionProgressView()
}