//
//  ActivityViewModel.swift
//  dawn-reference-app-fuse
//
//  Created by Milad Ahmad on 24-06-2026.
//
import Foundation
import Observation
import SkipFuse

@MainActor
@Observable
public final class ActivityViewModel {
    public var logs: [String] = []
    
    public init() {}
    
    public func logPhase(_ phaseName: String) {
        let formatter = DateFormatter()
        formatter.timeStyle = .medium
        let timestamp = formatter.string(from: Date())
        
        var updatedEvents = logs
        updatedEvents.insert("[\(timestamp)] \(phaseName)", at: 0)
        logs = updatedEvents
    }
}
