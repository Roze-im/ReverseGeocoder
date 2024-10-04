import XCTest
@testable import ReverseGeocoder
@testable import ReverseGeocoderTesting
import CoreLocation

final class ReverseGeocoderCacheTests: XCTestCase {
    func testRounding() {
        // 10 meters resolution
        let maxDistance = sqrt(10*10 + 10*10) // diagonal of the grid's square
        let cache = ReverseGeocoderCache<String>(resolutionInMeters: 10)

        // take coordinates around the globe, at various lon / lat
        let coordinatesToTest: [CLLocationCoordinate2D] = [
            /// 18 rue raymond aron, Paris, France
           .init(latitude: 48.835088, longitude: 2.374214),
            /// Abuja, nigeria
            .init(latitude: 9.052808, longitude: 7.497595),
            /// Vivero la rosa, argentina
            .init(latitude: -34.66656167419167, longitude: -58.48922111516931)
        ]
        for c in coordinatesToTest {
            let rounded = cache.roundCoordinates(c)
            let originalLocation = CLLocation(latitude: c.latitude, longitude: c.longitude)
            let roundedLocation = CLLocation(latitude: rounded.latitude, longitude: rounded.longitude)
            let distance = roundedLocation.distance(from: originalLocation)
            XCTAssert( distance < maxDistance, "\(roundedLocation) is \(distance) meters away from \(originalLocation) ")
        }
    }
}
