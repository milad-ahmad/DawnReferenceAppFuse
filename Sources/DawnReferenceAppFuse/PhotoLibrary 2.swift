import SwiftUI
import SkipKit

/// A view that handles displaying a selected image and presents options to pick or take a new photo.
/// Utilizes SkipKit for cross-platform media selection on both iOS and Android.
public struct PhotoLibrary: View {
    @State public var selectedImageURL: URL? = nil
    @State public var selectedImage: UIImage? = nil
    
    @State public var showingCamera = false
    @State public var showingLibrary = false
    
    public init() {}
    
    public var body: some View {
        VStack {
            if let selectedImage = selectedImage {
                Image(uiImage: selectedImage)
                    .resizable()
                    .scaledToFit()
                    .frame(height: 300)
                    .clipShape(RoundedRectangle(cornerRadius: 25))
            } else {
                Text("No image is selected")
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
                Text("Select photo")
                    .font(.headline)
                    .padding()
                    .frame(maxWidth: .infinity)
                    .background(Color.cyan)
                    .foregroundStyle(.white)
                    .clipShape(RoundedRectangle(cornerRadius: 25))
            }
            .withMediaPicker(type: .library, isPresented: $showingLibrary, selectedImageURL: $selectedImageURL)
        }
        .onChange(of: selectedImageURL) { url in
            if let url = url {
                loadImage(from: url)
            }
        }
    }
    
    /// Loads the image data from a local file URL and updates the view state.
    ///
    /// - Parameter url: The local file URL pointing to the captured or selected image.
    private func loadImage(from url: URL) {
        Task {
            if let data = try? Data(contentsOf: url),
               let image = UIImage(data: data) {
                await MainActor.run {
                    self.selectedImage = image
                }
            }
        }
    }
}