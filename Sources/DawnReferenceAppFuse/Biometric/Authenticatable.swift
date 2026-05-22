import Foundation

#if !os(Android)
import LocalAuthentication
#endif

@MainActor
public protocol Authenticatable {
    var isAuthenticated: Bool { get set }
    func authenticate() async -> Bool
}

#if !os(Android)
public class IOSAuthenticator: Authenticatable {
    public var isAuthenticated: Bool = false
    
    public init() {}
    
    public func authenticate() async -> Bool {
        let context = LAContext()
        var error: NSError?
        
        guard context.canEvaluatePolicy(.deviceOwnerAuthenticationWithBiometrics, error: &error) else {
            return false
        }
        
        do {
            let success = try await context.evaluatePolicy(
                .deviceOwnerAuthenticationWithBiometrics,
                localizedReason: "Log in to access your data."
            )
            self.isAuthenticated = success
            return success
        } catch {
            self.isAuthenticated = false
            return false
        }
    }
}
#endif

#if os(Android)
public class AndroidAuthenticator: Authenticatable {
    public var isAuthenticated: Bool = false
    
    public init() {}
    
    public func authenticate() async -> Bool {
        try? await Task.sleep(for: .seconds(1.5))
        self.isAuthenticated = true
        return true
    }
}
#endif
