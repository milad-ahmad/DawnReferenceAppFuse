import SwiftUI
import Observation

@MainActor
@Observable
public final class AppRouter: @unchecked Sendable {
    public var currentRoute: Route = .home
    public var errorMessage: String? = nil
    
    public enum Route: Equatable {
        case home
        case location
        case settings
    }
    
    public init() {}
    
    public func handle(url: URL) {
        guard url.scheme == "dawnapp" else { return }
        
        errorMessage = nil
        
        let target = (url.host ?? url.path).replacingOccurrences(of: "/", with: "").lowercased()
        
        switch target {
        case "location":
            currentRoute = .location
        case "settings":
            currentRoute = .settings
        case "home":
            currentRoute = .home
        default:
            errorMessage = "Invalid route: \(url.absoluteString)"
            currentRoute = .home
        }
    }
}

public struct HomeFeatureView: View {
    public init() {}
    
    public var body: some View {
        VStack {
            Text("Home Dashboard")
                .font(.largeTitle)
        }
        .frame(maxWidth: .infinity, maxHeight: .infinity)
        .background(Color.blue.opacity(0.1))
    }
}

public struct SettingsFeatureView: View {
    public init() {}
    
    public var body: some View {
        VStack {
            Text("Settings")
                .font(.largeTitle)
        }
        .frame(maxWidth: .infinity, maxHeight: .infinity)
        .background(Color.gray.opacity(0.1))
    }
}
