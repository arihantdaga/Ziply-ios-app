//
//  MainTabView.swift
//  Ziply
//
//  Created by Arihant Daga Second on 22/06/25.
//

import SwiftUI

struct MainTabView: View {
    var body: some View {
        TabView {
            PhotoSelectionView()
                .tabItem {
                    Label("Compress", systemImage: "wand.and.stars")
                }
            
            SettingsView()
                .tabItem {
                    Label("Settings", systemImage: "gearshape")
                }
        }
        .accentColor(Color(red: 0.4, green: 0.3, blue: 0.9))
    }
}