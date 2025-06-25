//
//  AppState.swift
//  Ziply
//
//  Created by Arihant Daga Second on 22/06/25.
//

import Foundation
import SwiftUI

@MainActor
class AppState: ObservableObject {
    static let shared = AppState()
    
    @Published var photoSelectionViewModel = PhotoSelectionViewModel()
    @Published var shouldResetNavigation = false
    
    private init() {}
    
    func resetToHome() {
        photoSelectionViewModel.selectedAssets = []
        photoSelectionViewModel.photosFound = 0
        photoSelectionViewModel.totalSize = 0
        shouldResetNavigation = true
    }
}