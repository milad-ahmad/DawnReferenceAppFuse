//
//  ConnectivityTestView.swift
//  dawn-reference-app-fuse
//
//  Created by Milad Ahmad on 15-05-2026.
//


import SwiftUI
import Foundation


public struct NetworkView: View {
    @State var dataResult: String = "Press the button to fetch data"
    @State var isFetching: Bool = false
    @State var hasError: Bool = false
    
    private let cornerRadius: Double = 10

    public init() {}

    public var body: some View {
        VStack(spacing: 20) {
            Image(systemName: hasError ? "wifi.slash" : "wifi")
                .font(.system(size: 60))
                .foregroundStyle(hasError ? .red : .green)
            
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
                    .foregroundStyle(.red)
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
                        .foregroundStyle(.white)
                        .clipShape(RoundedRectangle(cornerRadius: cornerRadius))
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
                        .foregroundStyle(.white)
                        .clipShape(RoundedRectangle(cornerRadius: cornerRadius))

                }
            }
        }
        .padding()
        .navigationTitle("Connectivity Test")
    }

    @MainActor
    private func fetchData() {
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
                        self.hasError = false
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
