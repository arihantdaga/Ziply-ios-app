//
//  ZiplyApp.swift
//  Ziply
//
//  Created by Arihant Daga Second on 22/06/25.
//

import SwiftUI

@main
struct ZiplyApp: App {
    @StateObject private var appState = AppState.shared
    
    var body: some Scene {
        WindowGroup {
            OnboardingView()
                .environmentObject(appState)
        }
    }	
}
