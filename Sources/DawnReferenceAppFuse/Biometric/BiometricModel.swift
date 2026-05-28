//
//  IOSBiometricModel.swift
//  dawn-reference-app-fuse
//
//  Created by Milad Ahmad on 28-05-2026.
//

import Foundation
#if !os(Android)
import LocalAuthentication

public class IOSBiometricModel {
    
    public init() {}

    public func authenticate() async -> Bool {
        let context = LAContext()
        var error: NSError?
        
        if context.canEvaluatePolicy(.deviceOwnerAuthenticationWithBiometrics, error: &error) {
            return (try? await context.evaluatePolicy(.deviceOwnerAuthenticationWithBiometrics, localizedReason: "Log in")) ?? false
        }
        
        return false
    }
}
#endif
