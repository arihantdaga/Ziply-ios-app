//
//  AppState.swift
//  Ziply
//
//  Created by Arihant Daga Second on 22/06/25.
//

import Foundation
import SwiftUI
import Combine

@MainActor
class AppState: ObservableObject {
    static let shared = AppState()
    
    @Published var photoSelectionViewModel = PhotoSelectionViewModel()
    @Published var shouldResetNavigation = false
    
    private var cancellables = Set<AnyCancellable>()
    
    private init() {
        print("AppState - Initialized")
        
        // Forward changes from nested view model to trigger UI updates
        photoSelectionViewModel.objectWillChange
            .sink { [weak self] _ in
                self?.objectWillChange.send()
            }
            .store(in: &cancellables)
    }
    
    func resetToHome() {
        photoSelectionViewModel.selectedAssets = []
        photoSelectionViewModel.photosFound = 0
        photoSelectionViewModel.totalSize = 0
        shouldResetNavigation = true
    }
}