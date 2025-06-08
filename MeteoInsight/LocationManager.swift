//
//  LocationManager.swift
//  MeteoInsight
//
//  Created by Olaf Lueg on 08.06.25.
//

import Foundation
import CoreLocation // Für Location Services

class LocationManager: NSObject, ObservableObject, CLLocationManagerDelegate {
    private let locationManager = CLLocationManager()

    @Published var authorizationStatus: CLAuthorizationStatus?
    @Published var currentLocation: CLLocation?
    @Published var lastError: Error?

    override init() {
        super.init()
        locationManager.delegate = self
        locationManager.desiredAccuracy = kCLLocationAccuracyReduced // Für Wetter reichen geringere Genauigkeiten
    }

    func requestLocationAuthorization() {
        locationManager.requestWhenInUseAuthorization() // Für Apps, die nur im Vordergrund Standort nutzen
    }

    func startUpdatingLocation() {
        locationManager.startUpdatingLocation()
    }

    func stopUpdatingLocation() {
        locationManager.stopUpdatingLocation()
    }

    // MARK: - CLLocationManagerDelegate

    func locationManager(_ manager: CLLocationManager, didUpdateLocations locations: [CLLocation]) {
        if let location = locations.last {
            DispatchQueue.main.async {
                self.currentLocation = location
                self.lastError = nil
            }
        }
    }

    func locationManager(_ manager: CLLocationManager, didFailWithError error: Error) {
        DispatchQueue.main.async {
            self.lastError = error
            print("Location Manager Fehler: \(error.localizedDescription)")
        }
    }

    func locationManagerDidChangeAuthorization(_ manager: CLLocationManager) {
        DispatchQueue.main.async {
            self.authorizationStatus = manager.authorizationStatus
            switch manager.authorizationStatus {
            case .authorizedWhenInUse, .authorizedAlways:
                self.startUpdatingLocation()
            case .denied, .restricted:
                print("Standortberechtigung verweigert oder eingeschränkt.")
            case .notDetermined:
                print("Standortberechtigung noch nicht bestimmt.")
            @unknown default:
                fatalError("Unbekannter Autorisierungsstatus")
            }
        }
    }
}
