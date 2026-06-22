import Foundation
import SwiftUI

public struct MainView: View {
    @State public var viewModel: MainViewModel

    public init(router: AppRouter) {
        _viewModel = State(initialValue: MainViewModel(router: router))
    }

    public var body: some View {
        @Bindable var vm = viewModel
        
        TabView(selection: $vm.router.selectedTab) {

            Tab("Home", systemImage: "house", value: 0) {
                HomeView()
            }

            Tab("Features", systemImage: "list.bullet", value: 1) {
                FeaturesListView(router: viewModel.router)
            }

        }
        .tabViewStyle(.automatic)
        .alert(
            "Invalid Link",
            isPresented: $vm.showErrorAlert,
            presenting: vm.router.errorMessage
        ) { _ in
            Button("OK", role: .cancel) {
                vm.router.errorMessage = nil
            }
        } message: { error in
            Text(error)
        }
    }
}
