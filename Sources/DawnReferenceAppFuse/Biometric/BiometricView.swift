import SwiftUI
import Foundation
import SkipModel

public struct BiometricView: View {
    @State var viewModel: BiometricViewModel
    
    public init(viewModel: BiometricViewModel) {
        self.viewModel = viewModel
    }
    
    public var body: some View {
        VStack(spacing: 30) {
            Image(systemName: viewModel.isAuthenticated ? "lock.open.fill" : "lock.fill")
                .font(.system(size: 80))
                .foregroundColor(viewModel.statusColor)
            
            Text(viewModel.statusMessage)
                .font(.headline)
                .multilineTextAlignment(.center)
                .padding()
            
            if !viewModel.isAuthenticated {
                Button(action: {
                    viewModel.login()
                }) {
                    Text("Log in with Biometrics")
                        .fontWeight(.bold)
                        .padding()
                        .frame(maxWidth: .infinity)
                        .background(Color.blue)
                        .foregroundColor(.white)
                        .cornerRadius(10)
                }
            } else {
                Button(action: {
                    viewModel.logout()
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
}
