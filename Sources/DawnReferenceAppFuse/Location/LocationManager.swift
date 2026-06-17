//
//  LocationManager.swift
//  dawn-reference-app-fuse
//
//  Created by Milad Ahmad on 16-06-2026.
//
import Foundation
import Observation
import SkipFuse
import SwiftUI

#if os(iOS)
    import CoreLocation
#else
    import SkipDevice
    import SkipKit
#endif

@MainActor
@Observable
public final class LocationManager: NSObject {
    public private(set) var isUpdating = false
    public private(set) var permissionDenied = false
    public private(set) var latitude: Double?
    public private(set) var longitude: Double?
    public private(set) var error: Error?

    #if os(iOS)
        private let coreLocationManager = CLLocationManager()
    #else
        private var updateTask: Task<Void, Never>?
    #endif

    public override init() {
        super.init()
        #if os(iOS)
            self.coreLocationManager.delegate = self
        #endif
    }

    public func request() {
        #if os(iOS)
            coreLocationManager.requestWhenInUseAuthorization()
        #else
            Task { @MainActor in
                _ = await PermissionManager.requestLocationPermission(
                    precise: true,
                    always: false
                )
            }
        #endif
    }

    public func start() {
        #if os(iOS)
            guard coreLocationManager.authorizationStatus != .denied,
                coreLocationManager.authorizationStatus != .restricted
            else {
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
                guard
                    await PermissionManager.requestLocationPermission(
                        precise: true,
                        always: false
                    ).isAuthorized == true
                else {
                    self?.permissionDenied = true
                    return
                }
                self?.permissionDenied = false
                self?.isUpdating = true

                do {
                    let provider = LocationProvider()
                    for try await event in provider.monitor() {
                        self?.update(event.latitude, event.longitude)
                    }
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
    extension LocationManager: @MainActor CLLocationManagerDelegate {
        public func locationManager(
            _ manager: CLLocationManager,
            didUpdateLocations locations: [CLLocation]
        ) {
            guard let location = locations.last else { return }
            Task { @MainActor in
                self.update(
                    location.coordinate.latitude,
                    location.coordinate.longitude
                )
            }
        }

        public func locationManager(
            _ manager: CLLocationManager,
            didFailWithError error: Error
        ) {
            guard let locationError = error as? CLError,
                locationError.code != .locationUnknown
            else { return }
            Task { @MainActor in
                if locationError.code == .denied {
                    self.permissionDenied = true
                    self.stop()
                } else {
                    self.error = error
                }
            }
        }
    }
#endif
