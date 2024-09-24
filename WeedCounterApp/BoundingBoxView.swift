import SwiftUI

struct BoundingBoxView: View {
    let image: UIImage
    @State private var boxSize: CGSize
    @State private var orientation: (pitch: Double, roll: Double)?
    
    @State private var scale: CGFloat = 1.0
    @State private var lastScale: CGFloat = 1.0
    @State private var offset: CGSize = .zero
    @State private var lastOffset: CGSize = .zero
    
    init(image: UIImage) {
        self.image = image
        // Start with an estimated distance of 1 meter
        _boxSize = State(initialValue: CameraCalibration.shared.getBoundingBoxSize(for: image, atDistance: 1.0))
    }
    
    var body: some View {
        GeometryReader { geometry in
            ZStack {
                Image(uiImage: image)
                    .resizable()
                    .scaledToFit()
                    .scaleEffect(scale)
                    .offset(offset)
                    .gesture(
                        MagnificationGesture()
                            .onChanged { value in
                                let delta = value / lastScale
                                lastScale = value
                                scale *= delta
                            }
                            .onEnded { _ in
                                lastScale = 1.0
                            }
                    )
                    .gesture(
                        DragGesture()
                            .onChanged { value in
                                offset = CGSize(
                                    width: lastOffset.width + value.translation.width,
                                    height: lastOffset.height + value.translation.height
                                )
                            }
                            .onEnded { _ in
                                lastOffset = offset
                            }
                    )
                
                Rectangle()
                    .stroke(Color.red, lineWidth: 2)
                    .frame(width: boxSize.width, height: boxSize.height)
                
                VStack {
                    Spacer()
                    Text("Pitch: \(orientation?.pitch.rounded(to: 2) ?? 0), Roll: \(orientation?.roll.rounded(to: 2) ?? 0)")
                        .padding()
                        .background(Color.black.opacity(0.7))
                        .foregroundColor(.white)
                        .cornerRadius(10)
                }
            }
        }
        .onAppear {
            startOrientationUpdates()
        }
    }
    
    private func startOrientationUpdates() {
        Timer.scheduledTimer(withTimeInterval: 0.1, repeats: true) { _ in
            orientation = CameraCalibration.shared.getDeviceOrientation()
        }
    }
}

extension Double {
    func rounded(to places: Int) -> Double {
        let divisor = pow(10.0, Double(places))
        return (self * divisor).rounded() / divisor
    }
}