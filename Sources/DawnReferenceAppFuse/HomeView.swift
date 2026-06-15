import SwiftUI

public struct HomeView: View {
    var textBackground: RadialGradient = RadialGradient(
        colors: [.black.opacity(0.85), .gray.opacity(0.6)],
        center: .topLeading,
        startRadius: 8,
        endRadius: 500
    )

    public init() {}

    public var body: some View {
        ZStack {
            LinearGradient(colors: [.gray, .white], startPoint: .bottomLeading, endPoint: .topTrailing)
                .ignoresSafeArea()
            
            ScrollView {
                VStack(alignment: .center, spacing: 20) {
                    Text("Welcome to this Dawn reference app for translations to Android")
                        .font(.title)
                        .fontWeight(.bold)
                        .multilineTextAlignment(.center)
                        .padding(20)
                        .frame(maxWidth: .infinity)
                        .background(textBackground)
                        .foregroundStyle(.white)
                        .clipShape(RoundedRectangle(cornerRadius: 15))
                    
                    Text("Go to the features list to find out what features are usable on Android using the Skip translation")
                        .font(.title2)
                        .fontWeight(.bold)
                        .multilineTextAlignment(.center)
                        .padding(20)
                        .frame(maxWidth: .infinity)
                        .background(textBackground)
                        .foregroundStyle(.white)
                        .clipShape(RoundedRectangle(cornerRadius: 15))
                }
                .padding(20)
            }
        }
    }
}
