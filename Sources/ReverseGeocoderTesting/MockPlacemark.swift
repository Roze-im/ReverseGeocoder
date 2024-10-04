//
//  MockPlacemark.swift
//
//
//  Created by Thibaud David on 17/10/2023.
//

import Foundation
import CoreLocation
import MapKit

extension CLPlacemark {
    public static func mock(coordinate: CLLocationCoordinate2D, name: String) -> CLPlacemark {
        let mkPlacemark = MKPlacemark(
            coordinate: coordinate,
            addressDictionary: ["name": name]
        )
        return CLPlacemark(placemark: mkPlacemark)
    }
}
