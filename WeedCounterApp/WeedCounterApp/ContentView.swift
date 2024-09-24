import SwiftUI

struct ContentView: View {
    @State private var capturedImage: UIImage?
    @State private var isCameraActive = false
    
    let boxSize = CGSize(width: 300, height: 300) // Adjust this size as needed
    
    var body: some View {
        VStack {
            if let image = capturedImage {
                BoundingBoxView(image: image, boxSize: boxSize)
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