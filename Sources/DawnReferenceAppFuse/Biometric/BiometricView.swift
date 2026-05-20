//
//  BiometricView.swift
//  dawn-reference-app-fuse
//
//  Created by Milad Ahmad on 20-05-2026.
//
import SwiftUI
#if os(iOS)
import LocalAuthentication
#endif

#if !os(Android)
public struct BiometricView: View {
    @State public var statusMessage: String = "Not logged in"
    @State public var statusColor: Color = .gray
    @State public var isAuthenticated: Bool = false
    
    public init() {}
    
    public var body: some View {
        VStack(spacing: 30) {
            Image(systemName: isAuthenticated ? "lock.open.fill" : "lock.fill")
                .font(.system(size: 80))
                .foregroundColor(statusColor)
            
            Text(statusMessage)
                .font(.headline)
                .multilineTextAlignment(.center)
                .padding()
            
            if !isAuthenticated {
                Button(action: {
                    authenticate()
                }) {
                    Text("Log in with Face ID")
                        .fontWeight(.bold)
                        .padding()
                        .frame(maxWidth: .infinity)
                        .background(Color.blue)
                        .foregroundColor(.white)
                        .cornerRadius(10)
                }
            } else {
                Button(action: {
                    isAuthenticated = false
                    statusMessage = "Logged out"
                    statusColor = .gray
                }) {
                    Text("Log out")
                        .fontWeight(.bold)
                        .padding()
                        .frame(maxWidth: .infinity)
                        .background(Color.red)
                        .foregroundColor(.white)
                        .cornerRadius(10)
                }
            }
        }
        .padding()
        .navigationTitle("Authentication Test")
    }
    
    public func authenticate() {
        let context = LAContext()
        var error: NSError?
        
        statusMessage = "Checking if Face ID is available..."
        
        if context.canEvaluatePolicy(.deviceOwnerAuthenticationWithBiometrics, error: &error) {
            
            let reason = "Log in to access your data."
            
            context.evaluatePolicy(.deviceOwnerAuthenticationWithBiometrics, localizedReason: reason) { success, authenticationError in
                
                Task { @MainActor in
                    if success {
                        self.isAuthenticated = true
                        self.statusMessage = "Successfully logged in"
                        self.statusColor = .green
                    } else {
                        self.isAuthenticated = false
                        self.statusColor = .orange
                        
                        if let error = authenticationError as? LAError {
                            switch error.code {
                            case .userCancel:
                                self.statusMessage = "Cancelled by user."
                            case .userFallback:
                                self.statusMessage = "User chose password."
                            case .biometryLockout:
                                self.statusMessage = "Face ID blocked due to too many failed attempts."
                            default:
                                self.statusMessage = "Authentication failed: \(error.localizedDescription)"
                            }
                        } else {
                            self.statusMessage = "Authentication failed."
                        }
                    }
                }
            }
        } else {
            self.isAuthenticated = false
            self.statusColor = .red
            self.statusMessage = "Face ID not available on this device.\n\(error?.localizedDescription ?? "")"
        }
        
    }

}
#endif

public struct AndroidBiometricView: View {
    public var body: some View {
        Text("This View cannot be translated to android with Skip. In order to use biometrics like Face ID and Touch ID, you have to build these seperately in Android Studio.")
            .font(.title2)
            .fontDesign(.rounded)
            .padding()
            .background(.secondary)
            .clipShape(RoundedRectangle(cornerRadius: 20))
    }
}
