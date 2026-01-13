//
//  YFCameraUtil.swift
//  YFPermissonUtil_Example
//
//  Created by Computer  on 13/01/26.
//  Copyright © 2026 CocoaPods. All rights reserved.
//

import UIKit
import AVFoundation

@objc public class CameraResult: NSObject {
    @objc public let result: Bool
    @objc public let needsSecondAlert: Bool
    
    @objc public init(result: Bool, needsSecondAlert: Bool) {
        self.result = result
        self.needsSecondAlert = needsSecondAlert
    }
}

@objc public class YFCameraUtil: NSObject {
    @objc public static let shared = YFCameraUtil()
    
    private override init() { super.init() }
    
    @objc public func requestCameraPermission(handler: @escaping (CameraResult) -> Void) {
        let status = AVCaptureDevice.authorizationStatus(for: .video)
        switch status {
        case .authorized:
            let result = CameraResult(result: true, needsSecondAlert: false)
            handler(result)
        case .notDetermined:
            AVCaptureDevice.requestAccess(for: .video) { granted in
                DispatchQueue.main.async {
                    let result = CameraResult(result: granted, needsSecondAlert: false)
                    handler(result)
                }
            }
        case .denied, .restricted:
            DispatchQueue.main.async {
                let result = CameraResult(result: false, needsSecondAlert: true)
                handler(result)
            }
        @unknown default:
            let result = CameraResult(result: false, needsSecondAlert: true)
            handler(result)
        }
    }
}

       
