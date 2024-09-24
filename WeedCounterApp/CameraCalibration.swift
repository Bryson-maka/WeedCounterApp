import UIKit
import CoreMotion

class CameraCalibration {
    static let shared = CameraCalibration()
    private let motionManager = CMMotionManager()
    
    private init() {
        motionManager.deviceMotionUpdateInterval = 0.1
        motionManager.startDeviceMotionUpdates()
    }
    
    func getBoundingBoxSize(for image: UIImage, atDistance distance: Double) -> CGSize {
        // This is a simplified calculation and should be calibrated for accuracy
        let focalLength: Double = 4.25 // Example focal length in mm (iPhone 12)
        let sensorHeight: Double = 4.80 // Example sensor height in mm (iPhone 12)
        
        let imageHeight = Double(image.size.height)
        let realWorldHeight = (distance * sensorHeight) / focalLength
        let pixelsPerMeter = imageHeight / realWorldHeight
        
        let boxSizeInMeters: Double = 0.3048 // 1 foot in meters
        let boxSizeInPixels = boxSizeInMeters * pixelsPerMeter
        
        return CGSize(width: boxSizeInPixels, height: boxSizeInPixels)
    }
    
    func getDeviceOrientation() -> (pitch: Double, roll: Double)? {
        guard let motion = motionManager.deviceMotion else { return nil }
        return (pitch: motion.attitude.pitch, roll: motion.attitude.roll)
    }
}