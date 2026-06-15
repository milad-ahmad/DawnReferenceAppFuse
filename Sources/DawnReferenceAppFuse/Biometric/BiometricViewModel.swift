import SwiftUI
import Observation

// SKIP @bridgeMembers
@MainActor
@Observable
public class BiometricViewModel {
    public var isAuthenticated: Bool = false
    public var statusMessage: String = "Not logged in"
    public var statusColor: Color = .gray
    
    public init() {}

    public func login() {
        statusMessage = "Authenticating..."
        statusColor = .blue
        
        #if os(Android)
        BiometricModel.androidAction(BiometricCallback(action: { success in
            Task { @MainActor in
                self.isAuthenticated = success
                self.statusMessage = success ? "Successfully logged in" : "Authentication failed"
                self.statusColor = success ? .green : .red
            }
        }))
        #else
        Task {
            let success = await BiometricModel.authenticate()
            
            self.isAuthenticated = success
            self.statusMessage = success ? "Successfully logged in" : "Authentication failed"
            self.statusColor = success ? .green : .red
        }
        #endif
    }
    
    public func logout() {
        isAuthenticated = false
        statusMessage = "Logged out"
        statusColor = .gray
    }
}

// SKIP @bridgeMembers
public class BiometricCallback {
    private let action: (Bool) -> Void
    
    public init(action: @escaping (Bool) -> Void) {
        self.action = action
    }
    
    public func complete(success: Bool) {
        action(success)
    }
}
