import SwiftUI
import SkipKit

public struct PhotoLibrary: View {
    @State public var selectedImageURL: URL? = nil
    @State public var selectedImage: UIImage? = nil
    
    @State public var showingCamera = false
    @State public var showingLibrary = false
    
    public init() {}
    
    public var body: some View {
        VStack(spacing: 20) {
            
            if let selectedImage = selectedImage {
                Image(uiImage: selectedImage)
                    .resizable()
                    .scaledToFit()
                    .frame(height: 300)
                    .clipShape(RoundedRectangle(cornerRadius: 25))
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
                    .clipShape(RoundedRectangle(cornerRadius: 25))
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
                    .clipShape(RoundedRectangle(cornerRadius: 25))
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
    
    public func loadImage(from url: URL) {
        #if !SKIP
        Task {
            if let data = try? Data(contentsOf: url), let image = UIImage(data: data) {
                await MainActor.run {
                    self.selectedImage = image
                }
            }
        }
        #else
        if let image = UIImage(contentsOfFile: url.absoluteString) {
            self.selectedImage = image
        }
        #endif
    }
}
