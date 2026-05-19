//
//  BiometricTestView.swift
//  dawn-reference-app-fuse
//
//  Created by Milad Ahmad on 18-05-2026.
//


import SwiftUI
import LocalAuthentication

public struct BiometricTestView: View {
    @State public var statusMessage: String = "Niet ingelogd"
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
                    Text("Log in met Biometrie")
                        .fontWeight(.bold)
                        .padding()
                        .frame(maxWidth: .infinity)
                        .background(Color.blue)
                        .foregroundColor(.white)
                        .cornerRadius(10)
                }
            } else {
                Button(action: {
                    // Reset status (Fallback/Logout actie)
                    isAuthenticated = false
                    statusMessage = "Uitgelogd"
                    statusColor = .gray
                }) {
                    Text("Log uit")
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
        .navigationTitle("Authenticatie Test")
    }
    

    public func authenticate() {
        let context = LAContext()
        var error: NSError?
        
        statusMessage = "Controleren of biometrie beschikbaar is..."
        
        if context.canEvaluatePolicy(.deviceOwnerAuthenticationWithBiometrics, error: &error) {
            
            let reason = "Log in om toegang te krijgen tot je gegevens."
            
            context.evaluatePolicy(.deviceOwnerAuthenticationWithBiometrics, localizedReason: reason) { success, authenticationError in
                
                Task { @MainActor in
                    if success {
                        self.isAuthenticated = true
                        self.statusMessage = "Succesvol ingelogd!"
                        self.statusColor = .green
                    } else {
                        self.isAuthenticated = false
                        self.statusColor = .orange
                        
                        if let error = authenticationError as? LAError {
                            switch error.code {
                            case .userCancel:
                                self.statusMessage = "Geannuleerd door de gebruiker."
                            case .userFallback:
                                self.statusMessage = "Gebruiker koos voor wachtwoord (fallback)."
                            case .biometryLockout:
                                self.statusMessage = "Biometrie is geblokkeerd door te veel foute pogingen."
                            default:
                                self.statusMessage = "Authenticatie mislukt: \(error.localizedDescription)"
                            }
                        } else {
                            self.statusMessage = "Authenticatie mislukt."
                        }
                    }
                }
            }
        } else {
            self.isAuthenticated = false
            self.statusColor = .red
            self.statusMessage = "Biometrie is niet beschikbaar op dit apparaat.\n\(error?.localizedDescription ?? "")"
        }
    }
}
