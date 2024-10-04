//
//  ReverseGeocoderCache.swift
//
//
//  Created by Benjamin Garrigues on 04/04/2024.
//

import Foundation
import CoreLocation

// Make it typesafe. But it's all internal anyway.
struct RoundedCoordinates2D: Equatable, Hashable {
    let latitude: Double
    let longitude: Double

    var clLocationCoordinate2D: CLLocationCoordinate2D {
        return .init(latitude: latitude, longitude: longitude)
    }
}

class ReverseGeocoderCache<T> {
    var cachedGeocodes: [RoundedCoordinates2D: T] = [:]

    // we're building a grid in meters, and sticking coordinates on that grid for caching.
    // each square of that grid is "resolutionInMeters" wide and "resolutionInMeters" high.
    let resolutionInMeters: Double

    init(resolutionInMeters: Double = 10) {
        self.resolutionInMeters = resolutionInMeters
    }

    let metersPerLatDegrees: Double = 111_111.0
    func roundCoordinates(_ coordinates: CLLocationCoordinate2D ) -> RoundedCoordinates2D {
        return .init(latitude: roundLatitude(lat: coordinates.latitude),
                     longitude: roundLongitude(lon:coordinates.longitude, atLat: coordinates.latitude))
    }

    /// 1 degree of latitude is about 111 111 meters, everywhere in the globe.
    /// so we can round the latitude pretty easily.
    func roundLatitude(lat: CLLocationDegrees) -> CLLocationDegrees {
        let latGridIndex = round(lat * metersPerLatDegrees / resolutionInMeters)
        return latGridIndex * resolutionInMeters / metersPerLatDegrees
    }

    /// Longitude rounding is a diffeerent matter. a degree of lon is very wide at equator, and
    /// collapse at the north pole.
    /// 1 degree of lon is about 111km at equator (lat 0) (aka 10m = 10/111000 degrees = 0.00009 degrees)
    /// but it is about 78km at lat 45 (10m is 10m/78km = 0.0001 degrees)
    /// and 38km at lat 70 (10m is 10m/38km = 0.0002 degrees)
    /// We use the formula : 111319 x cos(latitude in radian) as the distance between two longitude degrees
    /// at a given lat, which gives pretty good approximation.
    func roundLongitude(lon: CLLocationDegrees, atLat lat: CLLocationDegrees) -> CLLocationDegrees {
        let latInRadian = abs(lat) * .pi / 180
        let distancePerLonDegree = 111_319.0 * cos(latInRadian)
        let lonGridIndex = round(lon * distancePerLonDegree / resolutionInMeters)
        return lonGridIndex * resolutionInMeters / distancePerLonDegree
    }

    //MARK: - PUBLIC API
    func set(value: T, for location: CLLocationCoordinate2D) {
        cachedGeocodes[roundCoordinates(location)] = value
    }

    func get(valueForLocation location: CLLocationCoordinate2D) -> T? {
        return cachedGeocodes[roundCoordinates(location)]
    }
}
