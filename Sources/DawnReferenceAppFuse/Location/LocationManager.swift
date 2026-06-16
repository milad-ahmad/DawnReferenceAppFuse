
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
        Task { @MainActor in _ = await PermissionManager.requestLocationPermission(precise: true, always: false) }
        #endif
    }
    
    public func start() {
        #if os(iOS)
        guard clManager.authorizationStatus != .denied, clManager.authorizationStatus != .restricted else {
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
            guard let self, await PermissionManager.requestLocationPermission(precise: true, always: false).isAuthorized else {
                self?.permissionDenied = true
                return
            }
            self.permissionDenied = false
            self.isUpdating = true
            
            do {
                let provider = LocationProvider()
                if let loc = try? await provider.fetchCurrentLocation() { self.update(loc.latitude, loc.longitude) }
                for try await event in provider.monitor() { self.update(event.latitude, event.longitude) }
            } catch {
                self.error = error
                self.isUpdating = false
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
    
    fileprivate func update(_ lat: Double, _ lon: Double) {
        self.latitude = lat
        self.longitude = lon
        self.error = nil
        self.permissionDenied = false
    }
}

#if os(iOS)
private final class LocationDelegate: NSObject, CLLocationManagerDelegate, @unchecked Sendable {
    weak var parent: LocationManager?
    init(parent: LocationManager) { self.parent = parent }
    
    func locationManager(_ m: CLLocationManager, didUpdateLocations locs: [CLLocation]) {
        guard let loc = locs.last else { return }
        Task { @MainActor in parent?.update(loc.coordinate.latitude, loc.coordinate.longitude) }
    }
    
    func locationManager(_ m: CLLocationManager, didFailWithError err: Error) {
        guard let clError = err as? CLError, clError.code != .locationUnknown else { return }
        Task { @MainActor in
            if clError.code == .denied {
                parent?.permissionDenied = true
                parent?.stop()
            } else {
                parent?.error = err
            }
        }
    }
}
#endif
