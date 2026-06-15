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
