//
//  YFLocationUtil.swift
//  YFPermissonUtil_Example
//
//  Created by Computer  on 12/01/26.
//  Copyright © 2026 CocoaPods. All rights reserved.
//

import UIKit
import Foundation
import CoreLocation

@objc public class LocationResult: NSObject {
    @objc public let success: Bool
    @objc public let latitude: String?
    @objc public let longitude: String?
    @objc public let needsSecondAlert: Bool
    @objc public let result: Bool
    
    @objc public init(success: Bool, latitude: String?, longitude: String?, needsSecondAlert: Bool, result: Bool) {
        self.success = success
        self.latitude = latitude
        self.longitude = longitude
        self.needsSecondAlert = needsSecondAlert
        self.result = result
    }
}

@objc public class YFLocationUtil: NSObject, CLLocationManagerDelegate {
    @objc public static let shared = YFLocationUtil()
    
    private var handler: ((LocationResult) -> Void)?
    private var locationManager: CLLocationManager?
    private var isRequired: Bool = false
    private var longitude = ""
    private var latitude = ""
    
    private override init() { super.init() }
    
    @objc public func requestLocation(isRequired: Bool, handler: @escaping (LocationResult) -> Void) {
        self.isRequired = isRequired
        self.handler = handler
        longitude = ""
        latitude = ""
        
        // Create or get location manager
        if locationManager == nil {
            locationManager = CLLocationManager()
            locationManager?.delegate = self
            locationManager?.desiredAccuracy = kCLLocationAccuracyBest
        }
        
        let status = CLLocationManager.authorizationStatus()
        
        switch status {
        case .authorizedAlways, .authorizedWhenInUse:
            locationManager?.requestLocation() // Request a single location update
        case .notDetermined:
            locationManager?.requestWhenInUseAuthorization()
            
        case .denied, .restricted:
            // Handle denial based on isRequired
            if isRequired {
                // For simplicity, show alert if location services are disabled OR permission is denied/restricted
                DispatchQueue.main.async { // Ensure UI updates on main thread
//                    self.showPermissionDeniedAlert()
                    let result = LocationResult(success: false, latitude: nil, longitude: nil, needsSecondAlert: true, result: false)
                    self.handler?(result)
                    self.handler = nil// Return failure
                }
            } else {
                let result = LocationResult(success: true, latitude: "-360", longitude: "-360", needsSecondAlert: false, result: false)
                self.handler?(result)
                self.handler = nil// Return failure
            }
        @unknown default:
            if isRequired {
                // For simplicity, show alert if location services are disabled OR permission is denied/restricted
                DispatchQueue.main.async { // Ensure UI updates on main thread
//                    self.showPermissionDeniedAlert()
                    let result = LocationResult(success: false, latitude: nil, longitude: nil, needsSecondAlert: true, result: false)
                    self.handler?(result)
                    self.handler = nil// Return failure
                }
            } else {
                let result = LocationResult(success: true, latitude: "-360", longitude: "-360", needsSecondAlert: false, result: false)
                self.handler?(result)
                self.handler = nil// Return failure
            }
        }
    }
    
    // MARK: - CLLocationManagerDelegate
    @objc public func locationManager(_ manager: CLLocationManager, didUpdateLocations locations: [CLLocation]) {
        guard let location = locations.last else { return }
        if longitude == "" && latitude == ""{
            longitude =  "\(location.coordinate.longitude)"
            latitude =  "\(location.coordinate.latitude)"
            let result = LocationResult(success: true, latitude: latitude, longitude: longitude, needsSecondAlert: false, result: true)
            self.handler?(result)
            self.handler = nil// Return failure
        }
        
        manager.stopUpdatingLocation()
        // Stop updates after getting location if needed, depends on use case. requestLocation gets one update.
    }
    
    @objc public func locationManager(_ manager: CLLocationManager, didFailWithError error: Error) {
        print("Location request failed: \(error.localizedDescription)")
        // Handle failure based on isRequired
        if isRequired {
            // Show alert or handle failure for required location
            DispatchQueue.main.async { // Ensure UI updates on main thread
                if self.longitude == "" && self.latitude == ""{
                    self.longitude = "-360"
                    self.latitude = "-360"
                    let result = LocationResult(success: false, latitude: nil, longitude: nil, needsSecondAlert: true, result: false)
                    self.handler?(result)
                    self.handler = nil// Return failure
                }
            }
        } else {
            if self.longitude == "" && self.latitude == ""{
                self.longitude = "-360"
                self.latitude = "-360"
                let result = LocationResult(success: true, latitude: "-360", longitude: "-360", needsSecondAlert: false, result: false)
                self.handler?(result)
                self.handler = nil// Return failure
            }
            // Return default failure values
        }
        // Clear handler after failure
        //handler = nil
    }
    
    @objc public func locationManagerDidChangeAuthorization(_ manager: CLLocationManager) {
        // This is called when the user changes authorization status
        let status = CLLocationManager.authorizationStatus()
        switch status {
        case .authorizedAlways, .authorizedWhenInUse:
            // If permission was just granted, request location
            manager.requestLocation()
        case .denied, .restricted:
            // If permission was just denied
            if isRequired {
                DispatchQueue.main.async { // Ensure UI updates on main thread
                    if self.longitude == "" && self.latitude == ""{
                        self.longitude =  "-360"
                        self.latitude =  "-360"
                        let result = LocationResult(success: false, latitude: nil, longitude: nil, needsSecondAlert: true, result: false)
                        self.handler?(result)
                        self.handler = nil// Return failure
                    }
                    
                    
                }
            } else {
                if self.longitude == "" && self.latitude == ""{
                    self.longitude = "-360"
                    self.latitude = "-360"
                    let result = LocationResult(success: true, latitude: "-360", longitude: "-360", needsSecondAlert: false, result: false)
                    self.handler?(result)
                    self.handler = nil// Return failure
                }
            }
            //handler = nil // Clear handler
        case .notDetermined:
            // Still waiting for user response, do nothing
            break
        @unknown default:
            if isRequired {
                DispatchQueue.main.async { // Ensure UI updates on main thread
                    if self.longitude == "" && self.latitude == ""{
                        self.longitude =  "-360"
                        self.latitude =  "-360"
                        let result = LocationResult(success: false, latitude: nil, longitude: nil, needsSecondAlert: true, result: false)
                        self.handler?(result)
                        self.handler = nil// Return failure
                    }
                    
                    
                }
            } else {
                if self.longitude == "" && self.latitude == ""{
                    self.longitude = "-360"
                    self.latitude = "-360"
                    let result = LocationResult(success: true, latitude: "-360", longitude: "-360", needsSecondAlert: false, result: false)
                    self.handler?(result)
                    self.handler = nil// Return failure
                }
            }
            break
        }
    }
}

