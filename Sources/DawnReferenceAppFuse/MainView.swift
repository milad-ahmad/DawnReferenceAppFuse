import Foundation
import SwiftUI

public struct MainView: View {
    @Bindable public var router: AppRouter
    @State public var showErrorAlert: Bool = false

    public init(router: AppRouter) {
        self.router = router
    }

    public var body: some View {
        TabView(selection: $router.selectedTab) {

            Tab("Home", systemImage: "house", value: 0) {
                HomeView()
            }

            Tab("Features", systemImage: "list.bullet", value: 1) {
                FeaturesListView(router: router)
            }

        }
        .tabViewStyle(.automatic)
        .onChange(of: router.errorMessage) { _, newError in
            if newError != nil {
                showErrorAlert = true
            }
        }
        .alert(
            "Invalid Link",
            isPresented: $showErrorAlert,
            presenting: router.errorMessage
        ) { _ in
            Button("OK", role: .cancel) {
                router.errorMessage = nil
            }
        } message: { error in
            Text(error)
        }
    }
}
