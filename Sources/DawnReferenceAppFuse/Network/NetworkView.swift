//
//  ConnectivityTestView.swift
//  dawn-reference-app-fuse
//
//  Created by Milad Ahmad on 15-05-2026.
//


import SwiftUI
import Foundation


public struct NetworkView: View {
    @State public var dataResult: String = "Press the button to fetch data"
    @State public var isFetching: Bool = false
    @State public var hasError: Bool = false

    public init() {}

    public var body: some View {
        VStack(spacing: 20) {
            Image(systemName: hasError ? "wifi.slash" : "wifi")
                .font(.system(size: 60))
                .foregroundColor(hasError ? .red : .green)
            
            if isFetching {
                ProgressView("Processing network request...")
                    .padding()
            } else {
                Text(dataResult)
                    .font(.body)
                    .multilineTextAlignment(.center)
                    .padding()
                    .frame(minHeight: 100)
            }

            if hasError {
                Text("Offline or network error detected.")
                    .foregroundColor(.red)
                    .font(.subheadline)

                // Retry
                Button(action: {
                    fetchData()
                }) {
                    Text("Retry Connection")
                        .fontWeight(.bold)
                        .padding()
                        .frame(maxWidth: .infinity)
                        .background(Color.blue)
                        .foregroundColor(.white)
                        .cornerRadius(10)
                }
            } else {
                // Happy Path
                Button(action: {
                    fetchData()
                }) {
                    Text("Fetch Data")
                        .fontWeight(.bold)
                        .padding()
                        .frame(maxWidth: .infinity)
                        .background(Color.green)
                        .foregroundColor(.white)
                        .cornerRadius(10)
                }
            }
        }
        .padding()
        .navigationTitle("Connectivity Test")
    }

    public func fetchData() {
        isFetching = true
        hasError = false
        dataResult = "Connecting to server..."

        // Test API URL
        guard let url = URL(string: "https://jsonplaceholder.typicode.com/todos/1") else {
            return
        }

        Task {
            do {
                let (data, _) = try await URLSession.shared.data(from: url)
                if let jsonString = String(data: data, encoding: .utf8) {
                    await MainActor.run {
                        self.dataResult = "Successfully fetched data :\n\(jsonString)"
                        self.isFetching = false
                    }
                }
            } catch {
                await MainActor.run {
                    self.dataResult = "Error during fetching:\n\(error.localizedDescription)"
                    self.hasError = true
                    self.isFetching = false
                }
            }
        }
    }
}
