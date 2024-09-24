import SwiftUI

struct ContentView: View {
    @State private var capturedImage: UIImage?
    @State private var isCameraActive = false
    
    var body: some View {
        VStack {
            if let image = capturedImage {
                BoundingBoxView(image: image)
            } else {
                Text("No image captured")
            }
            
            Button("Capture Image") {
                isCameraActive = true
            }
        }
        .sheet(isPresented: $isCameraActive) {
            CameraView(capturedImage: $capturedImage, isCameraActive: $isCameraActive)
        }
    }
}

struct ContentView_Previews: PreviewProvider {
    static var previews: some View {
        ContentView()
    }
}