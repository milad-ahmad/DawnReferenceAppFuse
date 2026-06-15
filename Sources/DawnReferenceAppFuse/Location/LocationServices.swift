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

public struct LocationView: View {
    @State public var manager = LocationManager()
    
    public init() {}
    
    public var body: some View {
        VStack(spacing: 20) {
            Text("Latitude: \(manager.latitude)\nLongitude: \(manager.longitude)")
                .multilineTextAlignment(.center)
            
            if manager.permissionDenied {
                Text("No permission granted for location services")
                    .foregroundColor(.red)
                    .multilineTextAlignment(.center)
            } else if let err = manager.error {
                Text(err.localizedDescription).foregroundColor(.red)
            }
            
            Button("Permission") { manager.request() }
            
            Button(action: {
                manager.isUpdating ? manager.stop() : manager.start()
            }) {
                Text(manager.isUpdating ? "Stop" : "Start")
            }
        }
        .padding()
    }
}

@MainActor
@Observable
public final class LocationManager: @unchecked Sendable {
    public var isUpdating = false
    public var permissionDenied = false
    public var latitude = 0.0
    public var longitude = 0.0
    public var error: Error?
    
    #if os(iOS)
    private let clManager = CLLocationManager()
    private var delegate: LocationDelegate?
    #else
    private var task: Task<Void, Never>?
    #endif
    
    public init() {
        #if os(iOS)
        let del = LocationDelegate(parent: self)
        self.delegate = del
        self.clManager.delegate = del
        #endif
    }

    public func request() {
        #if os(iOS)
        clManager.requestWhenInUseAuthorization()
        #else
        Task { @MainActor in
            _ = await PermissionManager.requestLocationPermission(precise: true, always: false)
        }
        #endif
    }
    
    public func start() {
        #if os(iOS)
        let status = clManager.authorizationStatus
        if status == .denied || status == .restricted {
            permissionDenied = true
            return
        }
        permissionDenied = false
        clManager.desiredAccuracy = kCLLocationAccuracyBest
        clManager.startUpdatingLocation()
        isUpdating = true
        #else
        task?.cancel()
        task = Task { @MainActor [weak self] in
            let status = await PermissionManager.requestLocationPermission(precise: true, always: false)
            if status.isAuthorized != true {
                self?.permissionDenied = true
                return
            }
            self?.permissionDenied = false
            self?.isUpdating = true
            
            do {
                let provider = LocationProvider()
                if let loc = try? await provider.fetchCurrentLocation() {
                    self?.latitude = loc.latitude
                    self?.longitude = loc.longitude
                }
                for try await event in provider.monitor() {
                    self?.latitude = event.latitude
                    self?.longitude = event.longitude
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
        clManager.stopUpdatingLocation()
        #else
        task?.cancel()
        #endif
        isUpdating = false
    }
}

#if os(iOS)
private final class LocationDelegate: NSObject, CLLocationManagerDelegate, @unchecked Sendable {
    weak var parent: LocationManager?
    
    init(parent: LocationManager) {
        self.parent = parent
        super.init()
    }
    
    func locationManager(_ m: CLLocationManager, didUpdateLocations locs: [CLLocation]) {
        guard let loc = locs.last else { return }
        Task { @MainActor in
            self.parent?.latitude = loc.coordinate.latitude
            self.parent?.longitude = loc.coordinate.longitude
            self.parent?.error = nil
            self.parent?.permissionDenied = false
        }
    }
    
    func locationManager(_ m: CLLocationManager, didFailWithError err: Error) {
        if let clError = err as? CLError {
            if clError.code == .locationUnknown { return }
            if clError.code == .denied {
                Task { @MainActor in
                    self.parent?.permissionDenied = true
                    self.parent?.stop()
                }
                return
            }
        }
        Task { @MainActor in self.parent?.error = err }
    }
}
#endif
