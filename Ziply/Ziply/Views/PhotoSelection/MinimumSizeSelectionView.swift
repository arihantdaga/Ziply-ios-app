//
//  MinimumSizeSelectionView.swift
//  Ziply
//
//  Created by Arihant Daga Second on 22/06/25.
//

import SwiftUI

struct MinimumSizeSelectionView: View {
    @EnvironmentObject var appState: AppState
    
    var body: some View {
        VStack(alignment: .leading, spacing: 16) {
            HStack {
                Text("Minimum Photo Size")
                    .font(.headline)
                
                Spacer()
                
                Text("\(String(format: "%.1f", appState.photoSelectionViewModel.minimumPhotoSize)) MB")
                    .font(.subheadline)
                    .fontWeight(.semibold)
                    .foregroundColor(.white)
                    .padding(.horizontal, 12)
                    .padding(.vertical, 6)
                    .background(Color.orange)
                    .cornerRadius(8)
            }
            
            Text("Only compress photos larger than this size")
                .font(.caption)
                .foregroundColor(.secondary)
            
            HStack {
                Text("100 KB")
                    .font(.caption)
                    .foregroundColor(.secondary)
                
                Slider(
                    value: $appState.photoSelectionViewModel.minimumPhotoSize,
                    in: Constants.PhotoSelection.minimumSizeRangeMB,
                    step: 0.1
                )
                .accentColor(.blue)
                
                Text("5 MB")
                    .font(.caption)
                    .foregroundColor(.secondary)
            }
        }
        .padding()
        .background(Color(.systemGray6))
        .cornerRadius(12)
    }
}