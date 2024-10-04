//
//  ReverseGeocoder.swift
//  RozeEngine
//
//  Created by Thibaud David on 15/09/2023.
//

import CoreLocation

public protocol ReverseGeocoderDelegate: AnyObject {
    func reverseGeocoder(
        _ reverseGeocoder: ReverseGeocoder,
        didGeocode placemark: CLPlacemark,
        for request: ReverseGeocoder.Request
    )
    func reverseGeocoder(
        _ reverseGeocoder: ReverseGeocoder,
        didFailGeocoding request: ReverseGeocoder.Request,
        error: Error
    )
}

public class ReverseGeocoder {

    private let geocoder = CLGeocoder()
    private var queue: [Request] = []
    internal let logger: Logger

    var pendingRequest: Request?

    public weak var delegate: ReverseGeocoderDelegate?

    public init(logger: @escaping Logger) {
        self.logger = logger
    }

    /// A non-persistent cache of reverse-geocoded placemark for coordinates.
    internal var cachedLocationForCoordinates = ReverseGeocoderCache<GeocodingProgress>()

    @discardableResult
    public func cachedGeocoding(
        coordinate: CLLocationCoordinate2D,
        startGeocodingIfNeeded: (geocodeIfNeeded: Bool, userInfos: [String: String])
    ) -> GeocodingProgress? {
        let progress = cachedLocationForCoordinates.get(valueForLocation: coordinate)
        switch progress {
        case .none, .error:
            if startGeocodingIfNeeded.geocodeIfNeeded {
                enqueueRequest(userInfos: startGeocodingIfNeeded.userInfos, coordinate: coordinate)
                return .inProgress
            }
            return nil
        default:
            return progress
        }
    }

    /// Enqueue coordinates to be geocoded.
    func enqueueRequest(
        userInfos: [String: String],
        coordinate: CLLocationCoordinate2D
    ) {
        assert(Thread.isMainThread, "Can't enqueue request from background thread")
        guard !queue.contains(
            where: { $0.coordinate == coordinate }
        ) else {
            // Can't duplicate coordinates
            return
        }

        switch cachedLocationForCoordinates.get(valueForLocation: coordinate) {
        case .inProgress, .success, .error(ReverseGeocoderError.unknownLocation):
            return
        case .error, .none:
            cachedLocationForCoordinates.set(value: .inProgress, for: coordinate)
            let request = Request(userInfos: userInfos, coordinate: coordinate)
            queue.append(request)
            logger(self, .debug, "enqueueRequest \(request)")

            processNextQueuedItem()
        }
    }

    private func processNextQueuedItem() {
        assert(Thread.isMainThread, "Can't process request from background thread")
        logger(self, .debug, "processNextQueuedItem")

        guard !queue.isEmpty else {
            logger(self, .debug, "… queue is empty")
            return
        }

        guard pendingRequest == nil else {
            logger(self, .debug, "… a geocoding operation is already in progress, aborting")
            return
        }

        let request = queue.removeFirst()
        pendingRequest = request
        logger(self, .debug, "… request \(request)")

        reverseGeocodeLocation(request.location) { [weak self] (placemarks, error) in
            defer {
                DispatchQueue.main.async { [weak self] in
                    self?.pendingRequest = nil
                    self?.logger(self, .debug, "… will process next")
                    self?.processNextQueuedItem()
                }
            }
            guard let self = self else { return }

            if let error = error {
                logger(self, .debug, "… error \(error)")
                cachedLocationForCoordinates.set(value: .error(error), for: request.coordinate)
                delegate?.reverseGeocoder(
                    self,
                    didFailGeocoding: request,
                    error: error
                )
                return
            }

            if let placemark = placemarks?.first {
                logger(self, .debug, "… geocoded")
                cachedLocationForCoordinates.set(value: .success(placemark), for: request.coordinate)
                delegate?.reverseGeocoder(
                    self,
                    didGeocode: placemark,
                    for: request
                )
            } else {
                logger(self, .debug, "… unknown location")
                cachedLocationForCoordinates.set(value: .error(
                    ReverseGeocoderError.unknownLocation
                ), for: request.coordinate)

                delegate?.reverseGeocoder(
                    self,
                    didFailGeocoding: request,
                    error: ReverseGeocoderError.unknownLocation
                )
            }
        }
    }

    internal func reverseGeocodeLocation(
        _ location: CLLocation,
        completionHandler: @escaping CLGeocodeCompletionHandler
    ) {
        geocoder.reverseGeocodeLocation(location, completionHandler: completionHandler)
    }
}

extension ReverseGeocoder {

    enum ReverseGeocoderError: Error {
        case unknownLocation
    }

    public struct Request {
        public let userInfos: [String: String]
        public let coordinate: CLLocationCoordinate2D

        public var location: CLLocation {
            return .init(
                latitude: coordinate.latitude,
                longitude: coordinate.longitude
            )
        }
    }
}

extension CLLocationCoordinate2D: @retroactive Hashable, @retroactive Equatable {
    public func hash(into hasher: inout Hasher) {
        hasher.combine(latitude)
        hasher.combine(longitude)
    }

    public static func == (lhs: CLLocationCoordinate2D, rhs: CLLocationCoordinate2D) -> Bool {
        return lhs.latitude == rhs.latitude && lhs.longitude == rhs.longitude
    }
}

public enum GeocodingProgress {
    case inProgress
    case success(CLPlacemark)
    case error(Error)

    var isInErrorState: Bool {
        guard case .error = self else { return false }
        return true
    }
}
