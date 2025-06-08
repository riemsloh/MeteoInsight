//
//  SettingsView.swift
//  AuraCast
//
//  Created by Olaf Lueg on 04.06.25.
//
// Copyright by Olaf Lueg

import SwiftUI

/// Ein View zur Verwaltung der App-Einstellungen.
/// Verwendet @AppStorage für die persistente Speicherung von Benutzereinstellungen.
struct SettingsView: View {
    // Beispiel-Einstellungen, die mit @AppStorage gespeichert werden.
    // Der String-Key muss eindeutig sein.
    @AppStorage("autoRefreshEnabled") var autoRefreshEnabled: Bool = true
    @AppStorage("selectedStationId") var selectedStationId: String = "YOUR_STATION_ID" // Standard-Station ID
    @AppStorage("apiKey") var apiKey: String = "YOUR_WEATHER_API_KEY" // <-- Hinzugefügt: API-Schlüssel
    @AppStorage("displayTemperatureUnit") var displayTemperatureUnit: String = "Celsius" // z.B. "Celsius" oder "Fahrenheit"
    
    // Hinzugefügte @AppStorage-Variablen für Längen- und Breitengrad,
    // um sie in den Einstellungen verfügbar zu machen.
    @AppStorage("latitude") private var storedLatitude: Double = 52.2039 // Beispiel: Melle Latitude
    @AppStorage("longitude") private var storedLongitude: Double = 8.3374 // Beispiel: Melle Longitude

    var body: some View {
        Form {
            Section(header: Text("Wetterdaten-Einstellungen")) {
                Toggle(isOn: $autoRefreshEnabled) {
                    Text("Automatische Aktualisierung")
                }
                Text("Aktualisiert alle 60 Sekunden.")
                    .font(.caption)
                    .foregroundColor(.gray)

                // Textfeld für die Station ID
                TextField("Station ID", text: $selectedStationId)
                    .textFieldStyle(.roundedBorder)
                    .disableAutocorrection(true) // Keine Autokorrektur
                Text("Geben Sie die ID Ihrer Personal Weather Station (PWS) ein.")
                    .font(.caption)
                    .foregroundColor(.gray)
                
                // Textfeld für den API-Schlüssel
                TextField("API-Schlüssel", text: $apiKey) // <-- Hinzugefügt: Textfeld für API-Schlüssel
                    .textFieldStyle(.roundedBorder)
                    .disableAutocorrection(true)
                Text("Geben Sie Ihren API-Schlüssel für die Wetterdaten ein.")
                    .font(.caption)
                    .foregroundColor(.gray)
                
                // Hinzugefügte Textfelder für Längen- und Breitengrad
                TextField("Breitengrad (Latitude)", value: $storedLatitude, formatter: NumberFormatter())
                    .textFieldStyle(.roundedBorder)
                Text("Geben Sie den Breitengrad für die Wettervorhersage ein (z.B. 52.2039).")
                    .font(.caption)
                    .foregroundColor(.gray)

                TextField("Längengrad (Longitude)", value: $storedLongitude, formatter: NumberFormatter())
                    .textFieldStyle(.roundedBorder)
                Text("Geben Sie den Längengrad für die Wettervorhersage ein (z.B. 8.3374).")
                    .font(.caption)
                    .foregroundColor(.gray)
                
                Picker("Temperatureinheit", selection: $displayTemperatureUnit) {
                    Text("Celsius (°C)").tag("Celsius")
                    Text("Fahrenheit (°F)").tag("Fahrenheit")
                }
                .pickerStyle(.segmented) // Segmentierter Picker für Einheiten
            }
            
            Section(header: Text("Allgemeine Einstellungen")) {
                // Beispiel für eine weitere Einstellung
                Toggle(isOn: .constant(true)) { // Beispiel: Eine nicht-persistente Einstellung
                    Text("Benachrichtigungen aktivieren")
                }
                .disabled(true) // Deaktiviert, da nur ein Beispiel
                Text("Diese Funktion ist derzeit nicht verfügbar.")
                    .font(.caption)
                    .foregroundColor(.gray)
            }
        }
        .formStyle(.grouped) // Gruppierter Stil für macOS-Einstellungen
        .padding()
        .frame(minWidth: 350, minHeight: 300) // Mindestgröße für das Einstellungsfenster
        .navigationTitle("Einstellungen") // Titel für das Fenster
    }
}

// MARK: - SettingsView_Previews
struct SettingsView_Previews: PreviewProvider {
    static var previews: some View {
        SettingsView()
    }
}
