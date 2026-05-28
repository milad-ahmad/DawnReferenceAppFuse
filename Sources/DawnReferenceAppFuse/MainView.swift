import Foundation
import SwiftUI

public struct MainView: View {
    @State public var selectedTab: Int = 0
    @State public var vm: BiometricViewModel

    public init(vm: BiometricViewModel) {
        self.vm = vm
    }
 
    public var body: some View {
        TabView(selection: $selectedTab) {
            
            Tab("Home", systemImage: "house", value: 0) {
                HomeView()
            }
            
            Tab("Features", systemImage: "list.bullet", value: 1) {
                FeaturesListView(vm: vm)
            }
            
        }
        .tabViewStyle(.automatic)
    }
}

public struct FeaturesListView: View {
    public var vm: BiometricViewModel
    
    public init(vm: BiometricViewModel) {
        self.vm = vm
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
