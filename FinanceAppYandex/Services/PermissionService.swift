//
//  PermissionService.swift
//  FinanceAppYandex
//
//  Created by Муса Зарифянов on 04.07.2025.
//

import AVFoundation

actor PermissionService {
    static let shared = PermissionService()
    private init() {}
    
    func requestMicrophonePermission() async -> Bool {
        let recordPermission = AVAudioSession.sharedInstance().recordPermission
        
        switch recordPermission {
        case .granted:
            return true
        case .denied:
            return false
        case .undetermined:
            return await withCheckedContinuation { continuation in
                AVAudioSession.sharedInstance().requestRecordPermission { granted in
                    continuation.resume(returning: granted)
                }
            }
        @unknown default:
            return false
        }
    }
}
