import SwiftUI

public struct DeepLinkTestView: View {
    @Environment(\.openURL) public var openURL
    
    public init() {}
    
    public var body: some View {
        List {
            Section("Valid Routes") {
                Button("Open Home") { openURL(URL(string: "dawnapp://home")!) }
                Button("Open Location Services") { openURL(URL(string: "dawnapp://location")!) }
                Button("Open Biometrics") { openURL(URL(string: "dawnapp://biometrics")!) }
                Button("Open Camera") { openURL(URL(string: "dawnapp://camera")!) }
            }
            
            Section("Error Handling") {
                Button("Test Invalid Route") { openURL(URL(string: "dawnapp://does-not-exist")!) }
            }
        }
        .navigationTitle("Deep Links")
    }
}
