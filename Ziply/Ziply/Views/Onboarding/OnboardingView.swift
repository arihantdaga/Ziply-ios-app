//
//  OnboardingView.swift
//  Ziply
//
//  Created by Arihant Daga Second on 22/06/25.
//

import SwiftUI
import PhotosUI

struct OnboardingView: View {
    @State private var showMainApp = false
    @State private var showLimitedAccess = false
    @State private var authorizationStatus = PHPhotoLibrary.authorizationStatus(for: .readWrite)
    
    var body: some View {
        ZStack {
            // Background gradient
            LinearGradient(
                colors: [Color(red: 0.4, green: 0.3, blue: 0.9), Color(red: 0.6, green: 0.4, blue: 0.95)],
                startPoint: .topLeading,
                endPoint: .bottomTrailing
            )
            .ignoresSafeArea()
            
            VStack(spacing: 40) {
                Spacer()
                
                // App Icon
                Image(systemName: "wand.and.stars")
                    .font(.system(size: 80))
                    .foregroundColor(.white)
                    .frame(width: 120, height: 120)
                    .background(
                        RoundedRectangle(cornerRadius: 24)
                            .fill(Color.white.opacity(0.2))
                    )
                
                // Welcome Text
                VStack(spacing: 16) {
                    Text("Welcome to Ziply")
                        .font(.largeTitle)
                        .fontWeight(.bold)
                        .foregroundColor(.white)
                    
                    Text("Free up space instantly by compressing your photos without losing memories")
                        .font(.body)
                        .multilineTextAlignment(.center)
                        .foregroundColor(.white.opacity(0.9))
                        .padding(.horizontal, 40)
                }
                
                Spacer()
                
                // Permission Card
                VStack(spacing: 24) {
                    HStack(spacing: 16) {
                        Image(systemName: "photo.on.rectangle.angled")
                            .font(.system(size: 40))
                            .foregroundColor(.white)
                        
                        VStack(alignment: .leading, spacing: 8) {
                            Text("Photo Library Access Required")
                                .font(.headline)
                                .foregroundColor(.white)
                            
                            Text("We need access to your photo library to compress your photos and help you save storage space")
                                .font(.subheadline)
                                .foregroundColor(.white.opacity(0.9))
                        }
                    }
                    .padding(24)
                    .background(
                        RoundedRectangle(cornerRadius: 16)
                            .fill(Color.white.opacity(0.15))
                    )
                }
                .padding(.horizontal, 24)
                
                // Privacy Text
                Text("Your photos remain on your device. We never upload or share your photos.")
                    .font(.footnote)
                    .multilineTextAlignment(.center)
                    .foregroundColor(.white.opacity(0.8))
                    .padding(.horizontal, 40)
                
                // Grant Access Button
                Button(action: requestPhotoAccess) {
                    Text("Grant Photo Access")
                        .font(.headline)
                        .foregroundColor(Color(red: 0.4, green: 0.3, blue: 0.9))
                        .frame(maxWidth: .infinity)
                        .padding(.vertical, 16)
                        .background(Color.white)
                        .cornerRadius(12)
                }
                .padding(.horizontal, 24)
                .padding(.bottom, 40)
            }
        }
        .fullScreenCover(isPresented: $showMainApp) {
            MainTabView()
                .environmentObject(AppState.shared)
        }
        .fullScreenCover(isPresented: $showLimitedAccess) {
            LimitedAccessView(showMainApp: $showMainApp)
        }
        .onAppear {
            checkPhotoLibraryPermission()
        }
    }
    
    private func checkPhotoLibraryPermission() {
        authorizationStatus = PHPhotoLibrary.authorizationStatus(for: .readWrite)
        if authorizationStatus == .authorized {
            showMainApp = true
        } else if authorizationStatus == .limited {
            showLimitedAccess = true
        }
    }
    
    private func requestPhotoAccess() {
        PHPhotoLibrary.requestAuthorization(for: .readWrite) { status in
            DispatchQueue.main.async {
                authorizationStatus = status
                if status == .authorized {
                    showMainApp = true
                } else if status == .limited {
                    showLimitedAccess = true
                } else if status == .denied {
                    // Handle denied case - maybe show alert to go to settings
                }
            }
        }
    }
}