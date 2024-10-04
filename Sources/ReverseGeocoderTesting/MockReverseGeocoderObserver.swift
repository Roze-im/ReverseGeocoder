//
//  MockReverseGeocoderObserver.swift
//  
//
//  Created by Thibaud David on 17/10/2023.
//

import Foundation
import CoreLocation
@testable import ReverseGeocoder

public class MockReverseGeocoderObserver: ReverseGeocoderDelegate {

    var didGeocode: ((CLPlacemark, ReverseGeocoder.Request) -> Void)?
    var didFailGeocoding: ((ReverseGeocoder.Request, Error) -> Void)?

    public init(
        didGeocode: ((CLPlacemark, ReverseGeocoder.Request) -> Void)? = nil,
        didFailGeocoding: ((ReverseGeocoder.Request, Error) -> Void)? = nil
    ) {
        self.didGeocode = didGeocode
        self.didFailGeocoding = didFailGeocoding
    }

    public func reverseGeocoder(
        _ reverseGeocoder: ReverseGeocoder,
        didGeocode placemark: CLPlacemark,
        for request: ReverseGeocoder.Request
    ) {
        didGeocode?(placemark, request)
    }
    public func reverseGeocoder(
        _ reverseGeocoder: ReverseGeocoder,
        didFailGeocoding request: ReverseGeocoder.Request,
        error: Error
    ) {
        didFailGeocoding?(request, error)
    }
}
