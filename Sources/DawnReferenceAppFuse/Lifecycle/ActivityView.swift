//
//  ActivityView.swift
//  dawn-reference-app-fuse
//
//  Created by Milad Ahmad on 24-06-2026.
import SwiftUI

public struct ActivityView: View {
    @State public var viewModel = ActivityViewModel()
    @Environment(\.scenePhase) public var scenePhase
    
    #if os(IOS)
    @SceneStorage("counter") public var counter: Int = 0
    #else
    @State public var counter: Int = 0
    #endif
    
    public init() {}
    
    public var body: some View {
        VStack(spacing: 24) {
            VStack(spacing: 12) {
                Text("State Restoration Test")
                    .font(.headline)
                
                Text("\(counter)")
                    .font(.system(size: 48, weight: .bold))
                
                Button("Increment Value") {
                    counter += 1
                }
                .buttonStyle(.borderedProminent)
            }
            .padding()
            .background(Color.gray.opacity(0.1), in: RoundedRectangle(cornerRadius: 12))
            
            VStack(alignment: .leading) {
                Text("Event Log")
                    .font(.headline)
                    .padding(.horizontal)
                
                List(viewModel.logs, id: \.self) { event in
                    Text(event)
                        .font(.system(.footnote, design: .monospaced))
                }
                .listStyle(.plain)
            }
        }
        .padding(.top)
        .navigationTitle("Lifecycle Validation")
        .onChange(of: scenePhase) { _, newPhase in
            switch newPhase {
            case .active:
                viewModel.logPhase("Active (Foreground)")
            case .inactive:
                viewModel.logPhase("Inactive (Interrupted)")
            case .background:
                viewModel.logPhase("Background")
            @unknown default:
                viewModel.logPhase("Unknown Phase")
            }
        }
    }
}
