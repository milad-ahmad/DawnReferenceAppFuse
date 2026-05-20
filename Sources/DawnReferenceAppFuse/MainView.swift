//
//  File.swift
//  dawn-reference-app-fuse
//
//  Created by Milad Ahmad on 08-05-2026.
//

import Foundation
import SwiftUI

public struct MainView: View {

    @State public var selectedTab: Int = 0

    public var body: some View {

        ZStack {

            tabView
        }

    }

    @ViewBuilder
    public var tabView: some View {

        TabView(selection: $selectedTab) {

            Tab("home", systemImage: "house", value: 0) {
                HomeView()

            }

            Tab("Audio", systemImage: "waveform", value: 1) {
                AudioView()
            }

            Tab("Notifications", systemImage: "bell", value: 2) {
                NotificationView()
            }

            Tab("Dates", systemImage: "calendar", value: 3) {
                DateTestView()
            }

            Tab("Photo Library", systemImage: "photo", value: 4) {
                PhotoLibrary()
            }

            Tab(
                "State Behaviour",
                systemImage: "figure.walk.triangle.fill",
                value: 5
            ) {
                StateBehaviorView()
            }

            Tab("Network", systemImage: "network", value: 6) {
                NetworkView()
            }

        }
        .tabViewStyle(.automatic)

    }

}

//public extension View {
//    func setGradient() -> some View {
//        LinearGradient(colors: [.black, .gray], startPoint: .bottomLeading ,endPoint: .topTrailing).ignoresSafeArea()
//    }
//}
