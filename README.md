# A wrapper around ReverseGeocoder to manage a geocoding queue with data caching

```
public func cachedGeocoding(
    coordinate: CLLocationCoordinate2D,
    startGeocodingIfNeeded: (geocodeIfNeeded: Bool, userInfos: [String: String])
) -> GeocodingProgress?
```

## Delegate methods

```
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
```