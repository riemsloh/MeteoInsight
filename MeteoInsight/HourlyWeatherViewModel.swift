//
//  HourlyWeatherViewModel.swift
//  MeteoInsight
//
//  Created by Olaf on 09.06.25.
//
// MARK: - Import

import Foundation // Für URL, URLSession, JSONDecoder
import SwiftUI // Für ObservableObject, @Published, @MainActor, @AppStorage

// MARK: - HourlyWeatherViewModel
/// Ein ViewModel, das die Logik für den Abruf und die Verwaltung von stündlichen Wetterdaten kapselt.
/// Es ist ein ObservableObject, damit Views auf Änderungen seiner @Published-Eigenschaften reagieren können.
class HourlyWeatherViewModel: ObservableObject {
    // Veröffentlichte Eigenschaften, die die UI aktualisieren, wenn sie sich ändern.
    @Published var hourlyForecasts: [HourlyForecastData] = [] // Das Array der stündlichen Vorhersage-Objekte
    @Published var isLoading: Bool = false // Zeigt an, ob Daten geladen werden
    @Published var errorMessage: String? // Speichert Fehlermeldungen
    
    // Lese die Konfigurationswerte direkt aus AppStorage (Beispielwerte)
    @AppStorage("hourlyPostalKey") private var storedPostalKey: String = "49328:DE" // Ihre Postleitzahl für Melle, Deutschland
    @AppStorage("hourlyApiKey") private var storedApiKey: String = "e1f10a1e78da46f5b10a1e78da96f525" // Ihr API-Schlüssel

    // Die Basis-URL für die Weather Company Hourly Forecast API.
    // Beachten Sie, dass wir hier '12hour' als Beispiel verwenden, wie in Ihrer URL.
    private let baseURL = "https://api.weather.com/v3/wx/forecast/hourly/12hour/enterprise"

    /// Ruft stündliche Wetterdaten asynchron von der Weather Company API ab.
    /// Verwendet die in AppStorage gespeicherten Werte für Postal Key und API-Schlüssel.
    @MainActor // Stellt sicher, dass UI-Updates auf dem Haupt-Thread erfolgen
    func fetchHourlyWeatherData(units: String = "m", language: String = "de-DE") async {
        isLoading = true // Ladezustand aktivieren
        errorMessage = nil // Vorherige Fehlermeldungen zurücksetzen
        
        // Überprüfen, ob API-Schlüssel und Postal Key vorhanden sind
        guard !storedPostalKey.isEmpty, !storedApiKey.isEmpty,
              storedPostalKey != "YOUR_POSTAL_KEY", storedApiKey != "YOUR_WEATHER_API_KEY" else {
            errorMessage = "Bitte geben Sie einen gültigen Postal Key und API-Schlüssel in den Einstellungen ein."
            isLoading = false
            return
        }

        // URL-Komponenten erstellen, um die URL sicher zusammenzusetzen.
        var components = URLComponents(string: baseURL)
        components?.queryItems = [
            URLQueryItem(name: "postalKey", value: storedPostalKey),
            URLQueryItem(name: "format", value: "json"),
            URLQueryItem(name: "units", value: units),
            URLQueryItem(name: "language", value: language),
            URLQueryItem(name: "apiKey", value: storedApiKey)
        ]
        
        // Überprüfen, ob die URL gültig ist.
        guard let url = components?.url else {
            errorMessage = "Ungültige URL-Konfiguration."
            isLoading = false
            return
        }
        
        do {
            // Daten von der URL abrufen.
            let (data, response) = try await URLSession.shared.data(from: url)
            
            // HTTP-Antwort überprüfen.
            guard let httpResponse = response as? HTTPURLResponse,
                  (200...299).contains(httpResponse.statusCode) else {
                let statusCode = (response as? HTTPURLResponse)?.statusCode ?? -1
                errorMessage = "Serverfehler oder ungültige Antwort. Statuscode: \(statusCode)"
                isLoading = false
                return
            }
            
            // JSON-Daten decodieren.
            let decoder = JSONDecoder()
            let hourlyResponse = try decoder.decode(HourlyForecastResponse.self, from: data)
            
            // Die Rohdaten in ein Array von HourlyForecastData-Objekten umwandeln
            hourlyForecasts = hourlyResponse.hourlyData()
            
            // Wenn keine Vorhersagen gefunden wurden, eine entsprechende Meldung setzen.
            if hourlyForecasts.isEmpty {
                errorMessage = "Keine stündlichen Vorhersagedaten für den angegebenen Postal Key gefunden."
            } else {
                print("Stündliche Wetterdaten erfolgreich geladen!")
                // Beispiel: Die erste Stunde ausgeben
                if let firstHour = hourlyForecasts.first {
                    print("Erste Stunde: \(firstHour.formattedTime), Temperatur: \(firstHour.temperature ?? 0.0)°C")
                }
            }
            
        } catch let decodingError as DecodingError {
            // Spezifische Fehler beim Decodieren abfangen.
            print("Decodierungsfehler: \(decodingError)")
            errorMessage = "Fehler beim Decodieren der stündlichen Wetterdaten. Bitte überprüfen Sie das Datenformat."
        } catch {
            // Allgemeine Netzwerk- oder andere Fehler abfangen.
            print("Netzwerkfehler: \(error)")
            errorMessage = "Fehler beim Abrufen der stündlichen Wetterdaten: \(error.localizedDescription)"
        }
        
        isLoading = false // Ladezustand deaktivieren
    }
}

