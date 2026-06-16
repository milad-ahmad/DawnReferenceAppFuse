//
//  PresentationView.swift
//  dawn-reference-app-fuse
//
//  Created by Milad Ahmad on 22-05-2026.
//

import SwiftUI

public struct PresentationView: View {
    @State var showSheet = false
    @State var showFullScreen = false

    public init() {}

    public var body: some View {
        ScrollView {
            VStack(spacing: 30) {
                Text("Modal & Sheet Tests")
                    .font(.title2.bold())

                Button(action: {
                    showSheet = true
                }) {
                    Text("Show Standard Sheet")
                        .fontWeight(.bold)
                        .padding()
                        .frame(maxWidth: .infinity)
                        .background(Color.blue)
                        .foregroundColor(.white)
                        .cornerRadius(10)
                }
                .sheet(isPresented: $showSheet) {
                    DetailSheetView(
                        title: "Standard Sheet",
                        isFullScreen: false
                    )
                }

                Button(action: {
                    showFullScreen = true
                }) {
                    Text("Show Full Screen Cover")
                        .fontWeight(.bold)
                        .padding()
                        .frame(maxWidth: .infinity)
                        .background(Color.purple)
                        .foregroundColor(.white)
                        .cornerRadius(10)
                }
                .fullScreenCover(isPresented: $showFullScreen) {
                    DetailSheetView(
                        title: "Full Screen Cover",
                        isFullScreen: true
                    )
                }
            }
            .padding()
        }
        .navigationTitle("Presentations")
    }
}
