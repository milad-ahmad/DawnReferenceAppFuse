//
//  DateTestView.swift
//  dawn-reference-app-fuse
//
//  Created by Milad Ahmad on 11-05-2026.
//

import SwiftUI
import Foundation

public struct DateTestView: View {
    
    @State public var output: String = "Press a button"
    @State public var liveTime: String = ""
    @State public var timerTask: Task<Void, Never>?
    
    public init() {
    }
    
    public var body: some View {
        ScrollView {
            VStack(spacing: 20) {
                
                Text("Date & Time Test")
                    .font(.title2.bold())
                
                Button("Current Time Test") {
                    currentTimeTest()
                }
                
                Button("UTC vs Local Test") {
                    utcTest()
                }
                
                Button("Midnight Test") {
                    midnightTest()
                }
                
                Button("Start Live Clock") {
                    startClock()
                }
                
                Button("Stop Live Clock") {
                    stopClock()
                }
                
                Text("Live Clock")
                    .font(.headline)
                
                Text(liveTime)
                    .font(.system(.body, design: .monospaced))
                
                Divider()
                
                Text(output)
                    .frame(maxWidth: .infinity, alignment: .leading)
                    .padding()
            }
            .padding()
            .onDisappear {
                stopClock()
            }
        }
    }
}

// MARK: - Tests

extension DateTestView {
    
    public func currentTimeTest() {
        let now = Date()
        
        let iso = ISO8601DateFormatter().string(from: now)
        
        let formatter = DateFormatter()
        formatter.timeZone = .current
        formatter.dateFormat = "HH:mm:ss"
        
        output = """
        CURRENT TIME TEST
        
        Date:
        \(now)
        
        ISO8601:
        \(iso)
        
        Formatted:
        \(formatter.string(from: now))
        
        Timezone:
        \(TimeZone.current.identifier)
        """
    }
    
    public func utcTest() {
        let now = Date()
        
        let utc = DateFormatter()
        utc.dateFormat = "yyyy-MM-dd HH:mm:ss"
        utc.timeZone = TimeZone(abbreviation: "UTC")
        
        let local = DateFormatter()
        local.dateFormat = "yyyy-MM-dd HH:mm:ss"
        local.timeZone = .current
        
        output = """
        UTC VS LOCAL
        
        UTC:
        \(utc.string(from: now))
        
        Local:
        \(local.string(from: now))
        """
    }
    
    public func midnightTest() {
        let calendar = Calendar.current
        
        guard let before = calendar.date(from: DateComponents(
            year: 2026,
            month: 5,
            day: 11,
            hour: 23,
            minute: 59,
            second: 59
        )) else {
            return
        }
        
        let after = before.addingTimeInterval(2)
        
        let formatter = DateFormatter()
        formatter.dateFormat = "yyyy-MM-dd HH:mm:ss"
        formatter.timeZone = .current
        
        output = """
        MIDNIGHT TEST
        
        Before:
        \(formatter.string(from: before))
        
        After:
        \(formatter.string(from: after))
        
        Same Day:
        \(calendar.isDate(before, inSameDayAs: after))
        """
    }
}

// MARK: - Live Clock

extension DateTestView {
    
    public func startClock() {
            stopClock()
            
            timerTask = Task {
                let formatter = DateFormatter()
                formatter.dateFormat = "HH:mm:ss"
                formatter.timeZone = .current
                
                while !Task.isCancelled {
                    let timeString = formatter.string(from: Date())
                    
                    await MainActor.run {
                        liveTime = timeString
                    }
                    
                    try? await Task.sleep(nanoseconds: 1_000_000_000)
                }
            }
        }
    
    public func stopClock() {
        timerTask?.cancel()
        timerTask = nil
    }
}
