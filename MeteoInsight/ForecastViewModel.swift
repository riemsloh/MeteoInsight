//
//  ForecastViewModel.swift
//  AuraCast
//
//  Created by Olaf Lueg on 05.06.25.
//
import Foundation // Für URL, URLSession, JSONDecoder
import SwiftUI // Für ObservableObject, @Published, @MainActor, @AppStorage
import CoreLocation // Für CLLocationCoordinate2D

// MARK: - ForecastViewModel
/// Ein ViewModel, das die Logik für den Abruf und die Verwaltung der 5 Tage Vorhersage  kapselt.
/// Es ist ein ObservableObject, damit Views auf Änderungen seiner @Published-Eigenschaften reagieren können.
class ForecastViewModel: ObservableObject {
    // Veröffentlichte Eigenschaften, die die UI aktualisieren, wenn sie sich ändern.
    @Published var forecastResponse: ForecastResponse? // Das aktuelle Vorhersage-Objekt
    @Published var isLoading: Bool = false // Zeigt an, ob Daten geladen werden
    @Published var errorMessage: String? // Speichert die Fehlermeldungen
    
    // Timer-Instanz für den automatischen Datenabruf
    private var timer: Timer?
    
    // Lese die Konfigurationswerte direkt aus AppStorage
    @AppStorage("apiKey") private var storedApiKey: String = "YOUR_WEATHER_API_KEY"
    // Annahme: Standortdaten werden über eine andere Quelle (z.B. CLLocationManager) bereitgestellt
    // oder könnten ebenfalls in AppStorage gespeichert werden, wenn sie statisch sind.
    // Für dieses Beispiel verwenden wir feste Koordinaten.
    // In einer realen App würden diese von einem Standortdienst kommen.
    @AppStorage("latitude") private var storedLatitude: Double = 52.2039 // Beispiel: Melle Latitude
    @AppStorage("longitude") private var storedLongitude: Double = 8.3374 // Beispiel: Melle Longitude
    
    @AppStorage("autoRefreshEnabled") private var autoRefreshEnabled: Bool = true // Auch diese Einstellung wird hier benötigt
    
    // Die Basis-URL für die Weather Company 5 Day Forecast API.
    private let baseURL = "https://api.weather.com/v3/wx/forecast/daily/5day"
    
    /// Ruft Wetterdaten asynchron von der Weather Company API ab.
    /// Verwendet die in AppStorage gespeicherten Werte für Geolocation und API-Schlüssel.
    @MainActor // Stellt sicher, dass UI-Updates auf dem Haupt-Thread erfolgen
    func fetchForecastData() async {
        // Verhindert unnötige Aufrufe, wenn bereits geladen wird
        guard !isLoading else { return }
        
        isLoading = true // Ladezustand aktivieren
        errorMessage = nil // Vorherige Fehlermeldungen zurücksetzen
        
        // URL-Komponenten erstellen, um die URL sicher zusammenzusetzen
        var components = URLComponents(string: baseURL)
        
        // Fügen Sie Abfrageparameter hinzu
        components?.queryItems = [
            URLQueryItem(name: "geocode", value: "\(storedLatitude),\(storedLongitude)"),
            URLQueryItem(name: "format", value: "json"),
            URLQueryItem(name: "units", value: "m"), // 'm' für metrisch (Celsius, km/h), 'e' für imperial (Fahrenheit, mph)
            URLQueryItem(name: "language", value: "de-DE"), // Sprache der Antwort
            URLQueryItem(name: "apiKey", value: storedApiKey)
        ]
        
        // Überprüfen, ob die URL gültig ist
        guard let url = components?.url else {
            self.errorMessage = "Fehler: Ungültige URL-Konfiguration."
            self.isLoading = false
            return
        }
        
        // Debug-Ausgabe der URL
        print("Fetching data from URL: \(url.absoluteString)")
        
        do {
            // Führen Sie den Netzwerk-Request asynchron aus
            let (data, response) = try await URLSession.shared.data(from: url)
            
            // Überprüfen des HTTP-Statuscodes
            guard let httpResponse = response as? HTTPURLResponse,
                  (200...299).contains(httpResponse.statusCode) else {
                let statusCode = (response as? HTTPURLResponse)?.statusCode ?? -1
                print("HTTP Error: Status Code \(statusCode)")
                print("Response data: \(String(data: data, encoding: .utf8) ?? "N/A")")
                self.errorMessage = "Fehler beim Laden der Daten. Statuscode: \(statusCode)"
                self.isLoading = false
                return
            }
            
            // JSON-Daten dekodieren
            let decoder = JSONDecoder()
            decoder.keyDecodingStrategy = .convertFromSnakeCase // Nützlich, wenn JSON-Schlüssel snake_case sind
                                                                // und Ihre Swift-Eigenschaften camelCase
            
            self.forecastResponse = try decoder.decode(ForecastResponse.self, from: data)
            
            // Debug-Ausgabe zur Bestätigung
            print("Successfully fetched forecast data.")
            // Optional: Einige Daten ausgeben, um die Dekodierung zu prüfen
            if let firstDayTempMax = self.forecastResponse?.calendarDayTemperatureMax?.first {
                print("First day max temp: \(firstDayTempMax)°C")
            }
            
        } catch let decodingError as DecodingError {
            // Spezifische Fehler beim Dekodieren
            print("Decoding Error: \(decodingError)")
            self.errorMessage = "Fehler beim Dekodieren der Wetterdaten: \(decodingError.localizedDescription)"
        } catch {
            // Allgemeine Netzwerk- oder andere Fehler
            print("Network Error: \(error)")
            self.errorMessage = "Netzwerkfehler: \(error.localizedDescription)"
        }
        
        isLoading = false // Ladezustand deaktivieren
    }
    
    /// Startet einen Timer, der alle 60 Sekunden Wetterdaten abruft.
    /// Ungültig macht jeden zuvor gestarteten Timer.
    ///

    func startFetchingDataAutomatically() {
            // Vorhandenen Timer ungültig machen, um doppelte Timer zu vermeiden
            timer?.invalidate()
            
            // Nur starten, wenn automatische Aktualisierung aktiviert ist
            guard autoRefreshEnabled else { return }

            // Neuen Timer erstellen, der alle 60 Sekunden feuert
            // [weak self] in der Timer-Closure verwenden, um Retain-Cycles zu vermeiden
            timer = Timer.scheduledTimer(withTimeInterval: 60.0, repeats: true) { [weak self] _ in
                // Sicherstellen, dass self noch existiert, bevor fetchWeatherData aufgerufen wird
#if swift(>=6.0)
                Task { @MainActor in
                    await self?.fetchForecastData() // Hier self? verwenden
                }
#elseif swift(<5.9)
                Task {
                    await self?.fetchForecastData() // Hier self? verwenden
                }
#else
                Task {
                    await self?.fetchForecastData() // Hier self? verwenden
                }
#endif
            }
            // Sofortigen ersten Abruf starten
            // Auch hier [weak self] verwenden, um Probleme bei der Deallokation von ViewModel zu vermeiden
#if swift(>=6.0)
        Task { @MainActor in
            await self.fetchForecastData() // Hier self? verwenden
            }
#elseif swift(<5.9)
        Task {
            await self.fetchForecastData() // Hier self? verwenden
            }
#else
        Task {
            await self.fetchForecastData() // Hier self? verwenden
            }
        #endif
        }
    
    /// Stoppt den automatischen Datenabruf-Timer.
    func stopFetchingDataAutomatically() {
        timer?.invalidate()
        timer = nil
    }
    
    // Beim Deinitialisieren des ViewModels den Timer stoppen, um Memory Leaks zu vermeiden
    deinit {
        stopFetchingDataAutomatically()
    }
}
