import Foundation
#if !os(Android)
import LocalAuthentication
#endif

// SKIP @bridgeMembers
public class BiometricModel {
    
    @MainActor public static let model = BiometricModel()
    
    public init() {
    }
    
    @MainActor public var androidAction: (BiometricCallback) -> Void = { _ in }
    
    #if !os(Android)
    public func authenticate() async -> Bool {
        let context = LAContext()
        var error: NSError?
        
        if context.canEvaluatePolicy(.deviceOwnerAuthenticationWithBiometrics, error: &error) {
            return (try? await context.evaluatePolicy(.deviceOwnerAuthenticationWithBiometrics, localizedReason: "Log in")) ?? false
        }
        
        return false
    }
    #endif
}
