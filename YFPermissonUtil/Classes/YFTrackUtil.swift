//
//  YFTrackUtil.swift
//  YFPermissonUtil_Example
//
//  Created by Computer  on 13/01/26.
//  Copyright © 2026 CocoaPods. All rights reserved.
//

import UIKit
import AppTrackingTransparency
import AdSupport

@objc public class YFTrackUtil: NSObject {
    @objc public static let shared = YFTrackUtil()
    @objc public var isTracking = false
    @objc public var isCompleted: Bool = false
    @objc public var onCompleted: (() -> Void)?
    
    private override init() { super.init() }
    
    @objc public func requestTrackingAuthorization(onCompleted: (() -> Void)?) {
        if self.isTracking == true {
            return
        }
        self.onCompleted = onCompleted
        self.isTracking = true
        self.isCompleted = false
        
        if #available(iOS 14, *) {
            let status = ATTrackingManager.trackingAuthorizationStatus
            if status == .authorized {
                self.initReturnCompleted()
            }else if status == .denied || status == .restricted {
                self.initReturnCompleted()
            }else{
                DispatchQueue.main.asyncAfter(deadline: .now() + .seconds(2)) {
                    self.initReturnCompleted()
                }
                ATTrackingManager.requestTrackingAuthorization { status in
                    DispatchQueue.main.async {
                        switch status {
                        case .authorized:
                            self.initReturnCompleted()
                        case .denied:
                            self.initReturnCompleted()
                        case .notDetermined:
                            
                            DispatchQueue.main.asyncAfter(deadline: .now() + .seconds(2)) {
                                self.initReturnCompleted()
                            }
                            
                        case .restricted:
                            
                            self.initReturnCompleted()
                        @unknown default:
                            
                            self.initReturnCompleted()
                        }
                    }
                }
            }
            
        } else {
            if ASIdentifierManager.shared().isAdvertisingTrackingEnabled {
                self.initReturnCompleted()
            } else {
                self.initReturnCompleted()
            }
            
            
        }
    }
    
    @objc public func initReturnCompleted() {
        if self.isCompleted == false {
            self.onCompleted?()
            self.isCompleted = true
        }
    }
    
    
    /// 获取当前 ATT 权限状态 (iOS 14+)
    @available(iOS 14, *)
    @objc public var trackingAuthorizationStatus: Int {
        return Int(ATTrackingManager.trackingAuthorizationStatus.rawValue)
    }
}

