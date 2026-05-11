import Foundation
import SwiftUI
import Observation
import SkipFuse

#if os(iOS)
import AVFoundation
#else
import SkipAV
#endif

@MainActor
@Observable
public final class MiniPlayer {
    public var isPlaying = false
    public var progress: Double = 0
    public var player: AVAudioPlayer?
    
    public var progressTask: Task<Void, Never>?
    public var currentURL: URL?
    
    public init() {
    }
    

    public func play(_ url: URL?) {
        guard let url else { return }
        if isPlaying, currentURL == url {
            pause()
            return
        }
        
        stop()
        
        do {
            player = try AVAudioPlayer(contentsOf: url)
            currentURL = url
            
            player?.prepareToPlay()
            player?.play()
            isPlaying = true
            
            startUpdatingProgress()
        } catch {
            print("Playback failed: \(error)")
            isPlaying = false
        }
    }
    
    public func pause() {
        player?.pause()
        isPlaying = false
        stopUpdatingProgress()
    }
    
    public func stop() {
        player?.stop()
        isPlaying = false
        progress = 0
        stopUpdatingProgress()
        player = nil
        currentURL = nil
    }
    

    public func startUpdatingProgress() {
        stopUpdatingProgress()
        
        progressTask = Task { @MainActor [weak self] in
            while !Task.isCancelled {
                guard let self, let player = self.player else { return }
                
                if player.isPlaying {
                    self.progress = player.duration > 0 ? player.currentTime / player.duration : 0
                } else {
                    self.isPlaying = false
                    self.stopUpdatingProgress()
                }
                
                try? await Task.sleep(nanoseconds: 50_000_000)
            }
        }
    }
    

    public func stopUpdatingProgress() {
        progressTask?.cancel()
        progressTask = nil
    }
    

    public func seek(to prog: Double) {
        guard let player, player.duration > 0 else { return }
        player.currentTime = prog * player.duration
        progress = prog
    }
    
    public var isPaused: Bool {
        player != nil && !isPlaying && progress > 0 && progress < 1
    }
    
    public var playingURL: URL? {
        currentURL
    }
}
