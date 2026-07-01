//
//  FeaturesListView.swift
//  dawn-reference-app-fuse
//
//  Created by Milad Ahmad on 15-06-2026.
//
import SwiftUI

public struct FeaturesListView: View {
    @State public var vm = BiometricViewModel()
    @Bindable public var router: AppRouter

    public init(router: AppRouter) {
        self.router = router
    }

    public var body: some View {
        NavigationStack(path: $router.featuresPath) {
            List {
                Section("Hardware & Sensors") {
                    NavigationLink(
                        "Face ID & Biometrics",
                        destination: BiometricView(viewModel: vm)
                    )
                    NavigationLink(
                        "Camera & Photo Library",
                        destination: PhotoLibrary()
                    )
                    NavigationLink("Audio Recorder", destination: AudioView())
                    NavigationLink(
                        "Location Services",
                        destination: LocationView()
                    )
                }

                Section("System & UI") {
                    NavigationLink(
                        "Presentations (Sheets)",
                        destination: PresentationView()
                    )
                    NavigationLink(
                        "Notifications",
                        destination: NotificationView()
                    )
                    NavigationLink("Dates & Times", destination: DateTestView())
                    NavigationLink("Deep Links", destination: DeepLinkTestView())
                }

                Section("Architecture & Network") {
                    NavigationLink(
                        "Network Connectivity",
                        destination: NetworkView()
                    )
                    NavigationLink(
                        "State Behaviour",
                        destination: StateBehaviorView()
                    )
                    NavigationLink("Lifecycle", destination: ActivityView())
                }
            }
            .navigationTitle("Features")
            .navigationDestination(for: String.self) { route in
                if route == "location" {
                    LocationView()
                }
                if route == "biometrics" {
                    BiometricView(viewModel: vm)
                }
                if route == "camera" {
                    PhotoLibrary()
                }
            }
        }
    }
}
