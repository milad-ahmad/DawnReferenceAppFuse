//
//  SwiftUIView.swift
//  dawn-reference-app-fuse
//
//  Created by Milad Ahmad on 15-05-2026.
//

import SwiftUI

public struct StateBehaviorTest: View {
    @State public var currentState: ViewState = .empty
    
    public init() {}
    
    public var body: some View {
        VStack {
            Spacer()
            
            switch currentState {
            case .loading:
                ProgressView("Loading data...")
                    .progressViewStyle(.circular)
            case .empty:
                VStack(spacing: 12) {
                    Image(systemName: "tray.fill")
                        .font(.system(size: 50))
                        .foregroundColor(.gray)
                    Text("No data found.")
                        .font(.headline)
                    Text("Please try searching for something else.")
                        .font(.subheadline)
                        .foregroundColor(.secondary)
                }
            case .error(let message):
                VStack(spacing: 12) {
                    Image(systemName: "exclamationmark.triangle.fill")
                        .font(.system(size: 50))
                        .foregroundColor(.red)
                    Text("Something went wrong")
                        .font(.headline)
                    Text(message)
                        .font(.subheadline)
                        .multilineTextAlignment(.center)
                        .padding(.horizontal)
                    
                    Button {
                        simulateNetworkCall(success: true)
                    } label: {
                        Text("Retry")
                            .fontWeight(.bold)
                            .padding(.horizontal, 24)
                            .padding(.vertical, 10)
                            .background(Color.blue)
                            .foregroundColor(.white)
                            .cornerRadius(8)
                    }
                    .padding(.top, 10)
                }
            case .success(let items):
                List(items, id: \.self) { item in
                    Text(item)
                }
            }
            
            Spacer()
            Divider()
            
            // Testing Controls
            HStack {
                Button("Set Empty") { currentState = .empty }
                Spacer()
                Button("Set Error") { simulateNetworkCall(success: false) }
                Spacer()
                Button("Set Success") { simulateNetworkCall(success: true) }
            }
            .padding()
        }
        .navigationTitle("State Tests")
    }
    
    public func simulateNetworkCall(success: Bool) {
        currentState = .loading
        
        DispatchQueue.main.asyncAfter(deadline: .now() + 1.5) {
            if success {
                self.currentState = .success(["Document A", "Document B", "Document C"])
            } else {
                self.currentState = .error("Failed to connect to the server. Please check your internet connection and try again.")
            }
        }
    }
}

public enum ViewState {
    case loading
    case empty
    case error(String)
    case success([String])
}
