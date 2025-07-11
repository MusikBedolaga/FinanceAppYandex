//
//  ShakeDatector.swift
//  FinanceAppYandex
//
//  Created by Муса Зарифянов on 26.06.2025.
//

import SwiftUI
import CoreMotion

class ShakeDetector: ObservableObject {
    private var motionManager = CMMotionManager()
    private let threshold = 2.3
    private let interval = 0.15
    
    @Published var isShaking = false
    
    init() {
        start()
    }
    
    deinit {
        motionManager.stopAccelerometerUpdates()
    }
    
    func start() {
        guard motionManager.isAccelerometerAvailable else { return }
        motionManager.accelerometerUpdateInterval = interval
        motionManager.startAccelerometerUpdates(to: .main) { [weak self] data, error in
            guard let self = self, let data = data else { return }
            let x = data.acceleration.x
            let y = data.acceleration.y
            let z = data.acceleration.z
            let magnitude = sqrt(x * x + y * y + z * z)
            
            self.isShaking = magnitude > self.threshold
        }
    }
}
