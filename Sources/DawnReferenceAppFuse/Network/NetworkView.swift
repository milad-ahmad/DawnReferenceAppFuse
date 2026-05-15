//
//  ConnectivityTestView.swift
//  dawn-reference-app-fuse
//
//  Created by Milad Ahmad on 15-05-2026.
//


import SwiftUI
import Foundation

/**
 * A view to test network connectivity, offline states, and recovery (retry) behavior.
 */
public struct ConnectivityTestView: View {
    @State public var dataResult: String = "Druk op de knop om data op te halen"
    @State public var isFetching: Bool = false
    @State public var hasError: Bool = false

    public init() {}

    public var body: some View {
        VStack(spacing: 20) {
            Image(systemName: hasError ? "wifi.slash" : "wifi")
                .font(.system(size: 60))
                .foregroundColor(hasError ? .red : .green)
            
            if isFetching {
                ProgressView("Bezig met netwerkverzoek...")
                    .padding()
            } else {
                Text(dataResult)
                    .font(.body)
                    .multilineTextAlignment(.center)
                    .padding()
                    .frame(minHeight: 100)
            }

            if hasError {
                Text("Offline of netwerkfout gedetecteerd.")
                    .foregroundColor(.red)
                    .font(.subheadline)

                // Recovery Action (Retry)
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
                // Happy Path Action
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

    /**
     * Attempts to fetch data from a public test API.
     * Handles both success and offline/error scenarios.
     */
    public func fetchData() {
        isFetching = true
        hasError = false
        dataResult = "Verbinden met server..."

        // Test API URL
        guard let url = URL(string: "https://jsonplaceholder.typicode.com/todos/1") else {
            return
        }

        Task {
            do {
                // Probeer data op te halen
                let (data, _) = try await URLSession.shared.data(from: url)
                if let jsonString = String(data: data, encoding: .utf8) {
                    await MainActor.run {
                        self.dataResult = "Succes! Data ontvangen:\n\(jsonString)"
                        self.isFetching = false
                    }
                }
            } catch {
                // Vang offline status of netwerkfout op
                await MainActor.run {
                    self.dataResult = "Fout bij ophalen:\n\(error.localizedDescription)"
                    self.hasError = true
                    self.isFetching = false
                }
            }
        }
    }
}