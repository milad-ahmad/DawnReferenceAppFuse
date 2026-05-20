//
//  DateTestView.swift
//  dawn-reference-app-fuse
//
//  Created by Milad Ahmad on 11-05-2026.
//

import Foundation
import SwiftUI

public struct DateTestView: View {

    @State var output: String = "Press a button"
    @State var liveTime: String = ""
    @State var timerTask: Task<Void, Never>?

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

                Button("Month Boundary Test") {
                    monthBoundaryTest()
                }

                Button("Daylight Savings Test") {
                    daylightSavingTimeTest()
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

        guard
            let before = calendar.date(
                from: DateComponents(
                    year: 2026,
                    month: 5,
                    day: 11,
                    hour: 23,
                    minute: 59,
                    second: 59
                )
            )
        else {
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

    public func monthBoundaryTest() {
        let calendar = Calendar.current

        guard
            let nonLeapYearDate = calendar.date(
                from: DateComponents(year: 2026, month: 2, day: 28, hour: 12)
            )
        else {
            return
        }

        guard
            let nextDay = calendar.date(
                byAdding: .day,
                value: 1,
                to: nonLeapYearDate
            )
        else {
            return
        }

        let formatter = DateFormatter()
        formatter.dateFormat = "yyyy-MM-dd"
        formatter.timeZone = .current

        output = """
            Month boundary test

            Before (Feb 28, 2026):
            \(formatter.string(from: nonLeapYearDate))

            After (+1 Day):
            \(formatter.string(from: nextDay))

            Expected: 2026-03-01
            """
    }

    public func daylightSavingTimeTest() {
        let calendar = Calendar.current
        let amsterdamTimeZone = TimeZone(identifier: "Europe/Amsterdam")!

        var components = DateComponents()
        components.year = 2026
        components.month = 3
        components.day = 29
        components.hour = 1
        components.minute = 59
        components.timeZone = amsterdamTimeZone

        guard let beforeDST = calendar.date(from: components) else {
            return
        }

        let afterDST = beforeDST.addingTimeInterval(120)

        let formatter = DateFormatter()
        formatter.dateFormat = "yyyy-MM-dd HH:mm:ss"
        formatter.timeZone = amsterdamTimeZone

        output = """
            Daylight savings transition test

            Before (01:59:00 CET):
            \(formatter.string(from: beforeDST))

            After (+120 seconds):
            \(formatter.string(from: afterDST))
            
            Expected: 2026-03-29 03:01:00
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
