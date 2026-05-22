import SwiftUI
import Observation

/* SKIP @bridge */
@MainActor
@Observable
public class BiometricViewModel {
    public var isAuthenticated: Bool = false
    public var statusMessage: String = "Not logged in"
    public var statusColor: Color = .gray
    
    private var authenticator: Authenticatable
    
    public init() {
        #if !os(Android)
        self.authenticator = IOSAuthenticator()
        #else
        self.authenticator = AndroidAuthenticator()
        #endif
    }

    public func login() {
        statusMessage = "Authenticating..."
        statusColor = .blue
        
        Task { @MainActor in
            let success = await authenticator.authenticate()
            self.isAuthenticated = success
            
            if success {
                self.statusMessage = "Successfully logged in"
                self.statusColor = .green
            } else {
                self.statusMessage = "Authentication failed"
                self.statusColor = .red
            }
        }
    }

    public func logout() {
        self.authenticator.isAuthenticated = false
        isAuthenticated = false
        statusMessage = "Logged out"
        statusColor = .gray
    }
}
