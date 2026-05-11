//
//  DateTestView.swift
//  dawn-reference-app-fuse
//
//  Created by Milad Ahmad on 11-05-2026.
//


import SwiftUI
import Foundation

/**
 * A temporary view to visually test the output of different date formatters.
 */
struct DateTestView: View {
    @State private var output: String = "Waiting..."

    var body: some View {
        VStack(spacing: 30) {
            Text(output)
                .multilineTextAlignment(.center)
                .padding()

            Button("Generate Timestamps") {
                let date = Date()
                let unix = String(Int(date.timeIntervalSince1970))
                
                let formatter = ISO8601DateFormatter()
                let iso = formatter.string(from: date)
                
                output = "Unix:\n\(unix)\n\nISO8601:\n\(iso)"
            }
        }
    }
}