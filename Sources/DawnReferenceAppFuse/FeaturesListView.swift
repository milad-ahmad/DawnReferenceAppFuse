//
//  FeaturesListView.swift
//  dawn-reference-app-fuse
//
//  Created by Milad Ahmad on 15-06-2026.
//
import SwiftUI


public struct FeaturesListView: View {
    @State public var vm = BiometricViewModel()
    
    public init() {
    }
    
    public var body: some View {
        NavigationStack {
            List {
                Section("Hardware & Sensors") {
                    NavigationLink("Face ID & Biometrics", destination: BiometricView(viewModel: vm))
                    NavigationLink("Camera & Photo Library", destination: PhotoLibrary())
                    NavigationLink("Audio Recorder", destination: AudioView())
                }
                
                Section("System & UI") {
                    NavigationLink("Presentations (Sheets)", destination: PresentationView())
                    NavigationLink("Notifications", destination: NotificationView())
                    NavigationLink("Dates & Times", destination: DateTestView())
                }
                
                Section("Architecture & Network") {
                    NavigationLink("Network Connectivity", destination: NetworkView())
                    NavigationLink("State Behaviour", destination: StateBehaviorView())
                }
            }
            .navigationTitle("Features")
        }
    }
}
