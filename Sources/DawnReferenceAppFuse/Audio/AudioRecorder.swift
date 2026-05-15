import Foundation
import SkipFuse
import Observation

#if os(iOS)
import AVFoundation
#else
import SkipAV
#endif


@MainActor
@Observable
public final class AudioRecorder {
    
    public var isRecording: Bool = false
    public var meterLevel: Float = 0
    public var meterHistory: [Float] = []

    public var error: Error?
    private(set) public var recorder: AVAudioRecorder?
    private(set) public var fileURL: URL?
    
    private var meteringTask: Task<Void, Never>?
    
    public init() {
    }

    public func requestPermission(_ done: @escaping @Sendable (Bool) -> Void) {
        #if os(iOS)
        if #available(iOS 17.0, *) {
            AVAudioApplication.requestRecordPermission { ok in
                Task { @MainActor in
                    done(ok)
                }
            }
        } else {
            AVAudioSession.sharedInstance().requestRecordPermission { ok in
                Task { @MainActor in
                    done(ok)
                }
            }
        }
        #else
        done(true)
        #endif
    }
    

    public func start() {
        do {
            #if os(iOS)
            let session = AVAudioSession.sharedInstance()
            try session.setCategory(.playAndRecord, mode: .default, options: [.defaultToSpeaker])
            try session.setActive(true)
            #endif
            
            let dir = try FileManager.default
                .url(for: .applicationSupportDirectory, in: .userDomainMask, appropriateFor: nil, create: true)
                .appendingPathComponent("Recordings", isDirectory: true)
            
            try FileManager.default.createDirectory(at: dir, withIntermediateDirectories: true)
            
            let stamp = ISO8601DateFormatter().string(from: .now).replacingOccurrences(of: ":", with: "-")
            let url = dir.appendingPathComponent("\(stamp).m4a")
            fileURL = url
            
            let settings: [String: Any] = [
                AVFormatIDKey: kAudioFormatMPEG4AAC,
                AVSampleRateKey: 44_100,
                AVNumberOfChannelsKey: 2,
                AVEncoderAudioQualityKey: AVAudioQuality.high.rawValue
            ]
            
            recorder = try AVAudioRecorder(url: url, settings: settings)
            
            #if os(iOS)
            recorder?.isMeteringEnabled = true
            #endif
            
            recorder?.record()
            isRecording = true
            
            startMetering()
        } catch let err {
            print("Startfailed: \(err)")
            self.error = err
        }
    }


    public func startMetering() {
        meteringTask?.cancel()
        
        meteringTask = Task { @MainActor [weak self] in
            while !Task.isCancelled {
                guard let self, let rec = self.recorder, rec.isRecording else { return }
                
                #if os(iOS)
                rec.updateMeters()
                
                let power = rec.averagePower(forChannel: 0)
                self.meterLevel = Self.normalize(power)
                self.meterHistory.append(self.meterLevel)
                
                if self.meterHistory.count > 100 {
                    self.meterHistory.removeFirst(self.meterHistory.count - 100)
                }
                #else
                self.meterLevel = 0.0
                #endif
                
                try? await Task.sleep(nanoseconds: 50_000_000)
            }
        }
    }
    
    public static func normalize(_ db: Float) -> Float {
        let floor: Float = -60
        if db <= floor { return 0 }
        let clamped = max(min(db, 0), floor)
        return (clamped - floor) / -floor
    }

    public func stopMetering() {
        meteringTask?.cancel()
        meteringTask = nil
        meterLevel = 0
        meterHistory.removeAll()
    }

    public func stop() {
        stopMetering()
        recorder?.stop()
        isRecording = false
        recorder = nil
    }
}
