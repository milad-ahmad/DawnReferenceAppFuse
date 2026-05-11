import SwiftUI
import SkipFuse

#if os(iOS)
import AVFoundation
#else
import SkipAV
#endif

public struct AudioView: View {
    @State public var rec = AudioRecorder()
    @State public var recordings: [URL] = []
    @State public var player = MiniPlayer()
    
    public var body: some View {
        VStack {
            ProgressView(value: rec.meterLevel)
                .progressViewStyle(.linear)
                .animation(.linear, value: rec.meterLevel)
                .tint(.orange)
            
            HStack {
                Button(rec.isRecording ? "Stop" : "Record") {
                    if rec.isRecording {
                        rec.stop()
                    } else {
                        player.stop()
                        rec.start()
                    }
                }
                Button("Play"){
                    player.play(rec.fileURL)
                }
                .disabled(rec.isRecording || rec.fileURL == nil)
            }
            
            if let url = rec.fileURL {
                #if os(iOS)
                Text("File: \(url.lastPathComponent)")
                    .font(.footnote)
                    .lineLimit(1)
                    .truncationMode(.middle)
                #else
                Text("File: \(url.lastPathComponent)")
                    .font(.footnote)
                    .lineLimit(1)
                #endif
            }
            
            List {
                Section("Recordings") {
                    ForEach(recordings, id: \.self) { url in
                        HStack {
                            #if os(iOS)
                            Text(url.lastPathComponent)
                                .font(.footnote)
                                .lineLimit(1)
                                .truncationMode(.middle)
                            #else
                            Text(url.lastPathComponent)
                                .font(.footnote)
                                .lineLimit(1)
                            #endif
                            
                            Button {
                                if player.playingURL == url && player.isPlaying {
                                    player.pause()
                                } else {
                                    player.play(url)
                                }
                            } label: {
                                Image(systemName: (player.playingURL == url && player.isPlaying) ? "pause.fill" : "play.fill")
                            }
                            
                            ProgressView(value: player.playingURL == url ? player.progress : 0)
                                .frame(width: 60)
                        }
                    }
                    .onDelete { indexSet in
                        for index in indexSet {
                            let url = recordings[index]
                            try? FileManager.default.removeItem(at: url)
                            if player.playingURL == url {
                                player.stop()
                            }
                        }
                        recordings = recordingList()
                    }
                }
            }
        }
        .padding()
        .task {
            rec.requestPermission { _ in }
            recordings = recordingList()
        }
        .onChange(of: rec.isRecording) { _, newValue in
            if newValue {
                player.stop()
            } else {
                recordings = recordingList()
            }
        }
    }
    
    public func recordingList() -> [URL] {
        let dir = try? FileManager.default
            .url(for: .applicationSupportDirectory, in: .userDomainMask, appropriateFor: nil, create: true)
            .appendingPathComponent("Recordings", isDirectory: true)
        
        guard let dir, let files = try? FileManager.default.contentsOfDirectory(at: dir, includingPropertiesForKeys: nil) else {
            return []
        }
                
        return files.filter { $0.pathExtension == "m4a" }.sorted { $0.lastPathComponent > $1.lastPathComponent }
    }
}
