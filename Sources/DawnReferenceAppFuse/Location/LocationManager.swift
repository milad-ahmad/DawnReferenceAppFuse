//
//  LocationManager.swift
//  dawn-reference-app-fuse
//
//  Created by Milad Ahmad on 16-06-2026.
//
import Foundation
import SkipFuse
import Observation
import SwiftUI

#if os(iOS)
import CoreLocation
#else
import SkipDevice
import SkipKit
#endif

@MainActor
@Observable
public final class LocationManager: @unchecked Sendable {
    public var isUpdating = false
    public var permissionDenied = false
    public var latitude = 0.0
    public var longitude = 0.0
    public var error: Error?
    
    #if os(iOS)
    private let coreLocationManager = CLLocationManager()
    private var locationDelegate: LocationDelegate?
    #else
    private var updateTask: Task<Void, Never>?
    #endif
    
    public init() {
        #if os(iOS)
        let delegate = LocationDelegate(parent: self)
        self.locationDelegate = delegate
        self.coreLocationManager.delegate = delegate
        #endif
    }
    
    public func request() {
        #if os(iOS)
        coreLocationManager.requestWhenInUseAuthorization()
        #else
        Task { @MainActor in _ = await PermissionManager.requestLocationPermission(precise: true, always: false) }
        #endif
    }
    
    public func start() {
        #if os(iOS)
        guard coreLocationManager.authorizationStatus != .denied, coreLocationManager.authorizationStatus != .restricted else {
            permissionDenied = true
            return
        }
        permissionDenied = false
        coreLocationManager.desiredAccuracy = kCLLocationAccuracyBest
        coreLocationManager.startUpdatingLocation()
        isUpdating = true
        #else
        updateTask?.cancel()
        updateTask = Task { @MainActor [weak self] in
            guard await PermissionManager.requestLocationPermission(precise: true, always: false).isAuthorized == true else {
                self?.permissionDenied = true
                return
            }
            self?.permissionDenied = false
            self?.isUpdating = true
            
            do {
                let provider = LocationProvider()
                if let location = try? await provider.fetchCurrentLocation() { self?.update(location.latitude, location.longitude) }
                for try await event in provider.monitor() { self?.update(event.latitude, event.longitude) }
            } catch {
                self?.error = error
                self?.isUpdating = false
            }
        }
        #endif
    }
    
    public func stop() {
        #if os(iOS)
        coreLocationManager.stopUpdatingLocation()
        #else
        updateTask?.cancel()
        #endif
        isUpdating = false
    }
    
    public func update(_ latitude: Double, _ longitude: Double) {
        self.latitude = latitude
        self.longitude = longitude
        self.error = nil
        self.permissionDenied = false
    }
}

#if os(iOS)
private final class LocationDelegate: NSObject, CLLocationManagerDelegate, @unchecked Sendable {
    var parent: LocationManager?
    
    init(parent: LocationManager) {
        self.parent = parent
    }
    
    func locationManager(_ manager: CLLocationManager, didUpdateLocations locations: [CLLocation]) {
        guard let location = locations.last else { return }
        Task { @MainActor in parent?.update(location.coordinate.latitude, location.coordinate.longitude) }
    }
    
    func locationManager(_ manager: CLLocationManager, didFailWithError error: Error) {
        guard let LocationError = error as? CLError, LocationError.code != .locationUnknown else { return }
        Task { @MainActor in
            if LocationError.code == .denied {
                parent?.permissionDenied = true
                parent?.stop()
            } else {
                parent?.error = error
            }
        }
    }
}
#endif
