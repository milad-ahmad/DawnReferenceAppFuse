//
//  LocationView.swift
//  dawn-reference-app-fuse
//
//  Created by Milad Ahmad on 16-06-2026.
//

import SwiftUI

public struct LocationView: View {
    @State public var manager = LocationManager()
    public init() {}
    
    public var body: some View {
        VStack(spacing: 20) {
            Text("Latitude: \(manager.latitude)\nLongitude: \(manager.longitude)")
            
            if manager.permissionDenied {
                Text("Permission Denied").foregroundColor(.red)
            } else if let err = manager.error {
                Text(err.localizedDescription).foregroundColor(.red)
            }
            
            Button("Request Permission") { manager.request() }
            Button(manager.isUpdating ? "Stop" : "Start") {
                manager.isUpdating ? manager.stop() : manager.start()
            }
        }
        .padding()
    }
}
