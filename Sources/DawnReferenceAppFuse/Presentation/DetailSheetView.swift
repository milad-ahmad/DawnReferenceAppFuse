//
//  DetailSheetView.swift
//  dawn-reference-app-fuse
//
//  Created by Milad Ahmad on 16-06-2026.
//
import SwiftUI

public struct DetailSheetView: View {
    @Environment(\.dismiss) var dismiss
    @State var showNestedAlert = false

    let title: String
    let isFullScreen: Bool

    public init(title: String, isFullScreen: Bool) {
        self.title = title
        self.isFullScreen = isFullScreen
    }

    public var body: some View {
        NavigationStack {
            VStack(spacing: 30) {
                Text("Testing presentations.")
                    .multilineTextAlignment(.center)
                    .padding()

                Button("Alert") {
                    showNestedAlert = true
                }
                .fontWeight(.bold)
                .padding()
                .background(Color.orange)
                .foregroundColor(.white)
                .cornerRadius(8)
                .alert("Alert", isPresented: $showNestedAlert) {
                    Button("OK", role: .cancel) {}
                } message: {
                    Text(
                        "This tests if Skip can show an alert on top of a \(isFullScreen ? "full screen cover" : "sheet") in Android."
                    )
                }

                Button(action: {
                    dismiss()
                }) {
                    Text("Dismiss via Button")
                        .fontWeight(.bold)
                        .padding()
                        .frame(maxWidth: .infinity)
                        .background(Color.red.opacity(0.8))
                        .foregroundColor(.white)
                        .cornerRadius(10)
                }
                .padding(.horizontal)
            }
            .navigationTitle(title)
            .navigationBarTitleDisplayMode(.inline)
            .toolbar {
                ToolbarItem(placement: .cancellationAction) {
                    Button("Close") {
                        dismiss()
                    }
                }
            }
        }
    }
}
