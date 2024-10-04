//
//  MockReverseGeocoder.swift
//
//
//  Created by Thibaud David on 17/10/2023.
//

import Foundation
import CoreLocation
@testable import ReverseGeocoder

public class MockReverseGeocoder: ReverseGeocoder {

    public typealias MockResponses = [CLLocationCoordinate2D: (placemarks: [CLPlacemark]?, error: Error?)]

    var mockResponses = MockResponses()

    public init(logger: @escaping Logger, mockResponses: MockResponses) {
        self.mockResponses = mockResponses
        super.init(logger: logger)
    }

    override public func reverseGeocodeLocation(
        _ location: CLLocation,
        completionHandler: @escaping CLGeocodeCompletionHandler
    ) {
        guard let res = mockResponses[location.coordinate] else {
            self.logger(self, .error, "No mock for \(location)")
            return
        }
        completionHandler(res.placemarks, res.error)
    }
}

public extension ReverseGeocoder {
    static func mock(
        logger: @escaping Logger = { print("\($1): \($2)") },
        mockResponses: MockReverseGeocoder.MockResponses
    ) -> MockReverseGeocoder {
        return MockReverseGeocoder(logger: logger, mockResponses: mockResponses)
    }
}
