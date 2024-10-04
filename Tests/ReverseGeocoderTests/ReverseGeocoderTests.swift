import XCTest
@testable import ReverseGeocoder
@testable import ReverseGeocoderTesting
import CoreLocation

final class ReverseGeocoderTests: XCTestCase {
    func testSuccessObserverCalledAndResultCached() {
        let location = CLLocation(latitude: 0, longitude: 0)
        let placemark = CLPlacemark.mock(
            coordinate: location.coordinate, name: "mock-name"
        )

        let mock = ReverseGeocoder.mock(mockResponses: [location.coordinate: ([placemark], nil)])
        let didGeocode = expectation(description: "didGeocode")
        let delegate = MockReverseGeocoderObserver(didGeocode: { res, req in
            XCTAssertEqual(res.name, placemark.name)
            didGeocode.fulfill()
        })
        mock.delegate = delegate
        let uncachedRes = mock.cachedGeocoding(
            coordinate: location.coordinate, startGeocodingIfNeeded: (true, [:])
        )
        guard case .inProgress = uncachedRes else {
            return XCTFail("Geocoding should be in progress")
        }
        wait(for: [didGeocode], timeout: 1)

        let cachedRes = mock.cachedGeocoding(
            coordinate: location.coordinate, startGeocodingIfNeeded: (true, [:])
        )
        guard case .success(let cachedPlacemark) = cachedRes else {
            return XCTFail("Geocoding should be in progress")
        }
        XCTAssertEqual(cachedPlacemark.name, placemark.name)
    }

    func testFailureObserverCalled() {
        let location = CLLocation(latitude: 0, longitude: 0)
        let errorCode = -1
        let error = NSError(domain: "reverseGeocoder.error", code: errorCode, userInfo: nil)

        let mock = ReverseGeocoder.mock(mockResponses: [location.coordinate: (nil, error)])
        let didFail = expectation(description: "didFail")
        let delegate = MockReverseGeocoderObserver(didFailGeocoding: { req, err in
            XCTAssertEqual((err as NSError).code, errorCode)
            didFail.fulfill()
        })
        mock.delegate = delegate
        mock.cachedGeocoding(coordinate: location.coordinate, startGeocodingIfNeeded: (true, [:]))
        wait(for: [didFail], timeout: 1)
    }
}
