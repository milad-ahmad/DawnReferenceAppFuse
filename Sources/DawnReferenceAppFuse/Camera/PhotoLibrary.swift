import SwiftUI
import SkipKit

public struct PhotoLibrary: View {
    @State var selectedImageURL: URL? = nil
    @State var selectedImage: UIImage? = nil
    
    @State var showingCamera = false
    @State var showingLibrary = false
    
    private let cornerRadius: CGFloat = 25
    
    public init() {}
    
    public var body: some View {
        VStack(spacing: 20) {
            
            if let selectedImage = selectedImage {
                Image(uiImage: selectedImage)
                    .resizable()
                    .scaledToFit()
                    .frame(height: 300)
                    .clipShape(RoundedRectangle(cornerRadius: cornerRadius))
            } else {
                VStack {
                    Text("No image is selected")
                        .font(.subheadline)
                        .foregroundStyle(.secondary)
                }
                .frame(height: 300)
            }
            
            Button {
                showingCamera = true
            } label: {
                Text("Take Photo")
                    .font(.headline)
                    .padding()
                    .frame(maxWidth: .infinity)
                    .background(Color.yellow)
                    .foregroundStyle(.white)
                    .clipShape(RoundedRectangle(cornerRadius: cornerRadius))
            }
            .withMediaPicker(type: .camera, isPresented: $showingCamera, selectedImageURL: $selectedImageURL)
            
            Button {
                showingLibrary = true
            } label: {
                Text("Select from Gallery")
                    .font(.headline)
                    .padding()
                    .frame(maxWidth: .infinity)
                    .background(Color.cyan)
                    .foregroundStyle(.white)
                    .clipShape(RoundedRectangle(cornerRadius: cornerRadius))
            }
            .withMediaPicker(type: .library, isPresented: $showingLibrary, selectedImageURL: $selectedImageURL)
        }
        .padding()
        .onChange(of: selectedImageURL) { url in
            if let url = url {
                loadImage(from: url)
            }
        }
    }
    
    private func loadImage(from url: URL) {
        #if !SKIP
        Task {
            if let data = try? Data(contentsOf: url), let image = UIImage(data: data) {
                await MainActor.run {
                    self.selectedImage = image
                }
            }
        }
        #else
        if let image = UIImage(contentsOfFile: url.path) {
            self.selectedImage = image
        }
        #endif
    }
}
