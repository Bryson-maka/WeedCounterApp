import SwiftUI

struct BoundingBoxView: View {
    let image: UIImage
    @State private var boxSize: CGSize
    @State private var orientation: (pitch: Double, roll: Double)?
    @State private var markedPlants: [CGPoint] = []
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
                
                ForEach(markedPlants.indices, id: \.self) { index in
                    Circle()
                        .fill(Color.green)
                        .frame(width: 10, height: 10)
                        .position(markedPlants[index])
                }
                
                VStack {
                    Spacer()
                    HStack {
                        Text("Plants: \(markedPlants.count)")
                        Spacer()
                        Text("Pitch: \(orientation?.pitch.rounded(to: 2) ?? 0), Roll: \(orientation?.roll.rounded(to: 2) ?? 0)")
                    }
                    .padding()
                    .background(Color.black.opacity(0.7))
                    .foregroundColor(.white)
                    .cornerRadius(10)
                }
            }
            .contentShape(Rectangle())
            .gesture(
                TapGesture()
                    .onEnded { location in
                        let tapLocation = geometry.frame(in: .local).origin + location
                        if isWithinBoundingBox(point: tapLocation, in: geometry) {
                            markedPlants.append(tapLocation)
                        }
                    }
            )
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
    
    private func isWithinBoundingBox(point: CGPoint, in geometry: GeometryProxy) -> Bool {
        let boxOrigin = CGPoint(
            x: (geometry.size.width - boxSize.width) / 2,
            y: (geometry.size.height - boxSize.height) / 2
        )
        let boxRect = CGRect(origin: boxOrigin, size: boxSize)
        return boxRect.contains(point)
    }
}

extension CGPoint {
    static func +(lhs: CGPoint, rhs: CGPoint) -> CGPoint {
        return CGPoint(x: lhs.x + rhs.x, y: lhs.y + rhs.y)
    }
}

extension Double {
    func rounded(to places: Int) -> Double {
        let divisor = pow(10.0, Double(places))
        return (self * divisor).rounded() / divisor
    }
}