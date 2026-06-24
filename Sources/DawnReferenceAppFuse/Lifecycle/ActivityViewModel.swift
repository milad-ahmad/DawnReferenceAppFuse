//
//  ActivityViewModel.swift
//  dawn-reference-app-fuse
//
//  Created by Milad Ahmad on 24-06-2026.
//

import SkipFuse
import Foundation
import Observation

@MainActor
@Observable
public final class ActivityViewModel {
    public var logs: [String] = []
    public var counter: Int = 0
    
    public init() {}
    
    public func incrementCounter() {
        counter += 1
    }

    public func logPhase(_ phaseName: String) {
        let formatter = DateFormatter()
        formatter.timeStyle = .medium
        let timestamp = formatter.string(from: Date())
        
        logs.insert("[\(timestamp)] \(phaseName)", at: 0)
    }
}
