//
//  LimitedAccessView.swift
//  Ziply
//
//  Created by Arihant Daga Second on 22/06/25.
//

import SwiftUI
import PhotosUI

struct LimitedAccessView: View {
    @Binding var showMainApp: Bool
    @State private var showingSettings = false
    
    var body: some View {
        ZStack {
            // Background gradient
            LinearGradient(
                colors: [Color(red: 0.4, green: 0.3, blue: 0.9), Color(red: 0.6, green: 0.4, blue: 0.95)],
                startPoint: .topLeading,
                endPoint: .bottomTrailing
            )
            .ignoresSafeArea()
            
            VStack(spacing: 32) {
                Spacer()
                
                // Warning Icon
                Image(systemName: "exclamationmark.triangle.fill")
                    .font(.system(size: 80))
                    .foregroundColor(.yellow)
                
                // Title
                VStack(spacing: 16) {
                    Text("Limited Photo Access")
                        .font(.largeTitle)
                        .fontWeight(.bold)
                        .foregroundColor(.white)
                    
                    Text("You've granted limited photo access. This will cause iOS to ask for permission for each photo we compress.")
                        .font(.body)
                        .multilineTextAlignment(.center)
                        .foregroundColor(.white.opacity(0.9))
                        .padding(.horizontal, 32)
                }
                
                // Info Card
                VStack(alignment: .leading, spacing: 16) {
                    HStack(spacing: 12) {
                        Image(systemName: "photo.fill")
                            .foregroundColor(.white)
                        Text("Why Full Access?")
                            .font(.headline)
                            .foregroundColor(.white)
                    }
                    
                    VStack(alignment: .leading, spacing: 12) {
                        Label("Compress photos without interruptions", systemImage: "checkmark.circle.fill")
                        Label("Replace originals seamlessly", systemImage: "checkmark.circle.fill")
                        Label("No repeated permission prompts", systemImage: "checkmark.circle.fill")
                    }
                    .font(.subheadline)
                    .foregroundColor(.white.opacity(0.9))
                }
                .padding(24)
                .background(
                    RoundedRectangle(cornerRadius: 16)
                        .fill(Color.white.opacity(0.15))
                )
                .padding(.horizontal, 24)
                
                Spacer()
                
                // Buttons
                VStack(spacing: 16) {
                    Button(action: openSettings) {
                        Text("Grant Full Access in Settings")
                            .font(.headline)
                            .foregroundColor(Color(red: 0.4, green: 0.3, blue: 0.9))
                            .frame(maxWidth: .infinity)
                            .padding(.vertical, 16)
                            .background(Color.white)
                            .cornerRadius(12)
                    }
                    
                    Button(action: continueWithLimited) {
                        Text("Continue with Limited Access")
                            .font(.subheadline)
                            .foregroundColor(.white.opacity(0.8))
                    }
                }
                .padding(.horizontal, 24)
                .padding(.bottom, 40)
            }
        }
        .onAppear {
            checkIfStillLimited()
        }
    }
    
    private func checkIfStillLimited() {
        let status = PHPhotoLibrary.authorizationStatus(for: .readWrite)
        if status == .authorized {
            showMainApp = true
        }
    }
    
    private func openSettings() {
        if let url = URL(string: UIApplication.openSettingsURLString) {
            UIApplication.shared.open(url)
        }
    }
    
    private func continueWithLimited() {
        showMainApp = true
    }
}

#Preview {
    LimitedAccessView(showMainApp: .constant(false))
}