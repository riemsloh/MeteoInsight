//
//  HourlyForecastSection.swift
//  MeteoInsight
//
//  Created by Olaf Lueg on 08.06.25.
//

import SwiftUI
import Foundation // Für DateFormatter

struct HourlyForecastSection: View {
    let forecastResponse: ForecastResponse?
    let isLoading: Bool
    let errorMessage: String?

    var body: some View {
        VStack(alignment: .leading) {
            Text("Stündliche Vorhersage")
                .font(.headline)
                .padding(.bottom, 5)

            ScrollView(.horizontal, showsIndicators: false) {
                HStack(spacing: 20) {
                    if isLoading {
                        ProgressView("Laden...")
                            .frame(width: 150, height: 100)
                    } else if let error = errorMessage {
                        Text("Fehler: \(error)")
                            .foregroundColor(.red)
                            .frame(width: 250, height: 100)
                    } else if let dayparts = forecastResponse?.daypart {
                        // Iteriere durch die Dayparts, die als stündliche oder 12-stündliche Abschnitte dienen können.
                        // Im Falle der 5-Tages-Vorhersage sind es 12-Stunden-Abschnitte (Tag/Nacht).
                        // Wenn Sie echte stündliche Daten benötigen, bräuchten Sie einen anderen API-Endpunkt.
                        ForEach(0..<dayparts.count, id: \.self) { index in
                            let daypart = dayparts[index]

                            // Hier wird es etwas komplexer, da alle Eigenschaften Arrays sind.
                            // Wir müssen mit dem 'index' auf die richtigen Werte zugreifen.
                            // Stellen Sie sicher, dass der Index für alle Arrays gültig ist.
                            guard let temp = daypart.temperature?[index],
                                  let iconCode = daypart.iconCode?[index],
                                  let timeLocal = forecastResponse?.validTimeLocal?[index], // Uhrzeit vom Top-Level
                                  let precipChance = daypart.precipChance?[index] else {
                                        // Überspringen, wenn grundlegende Daten fehlen
                                        return
                                  }

                            VStack {
                                // Uhrzeit formatieren (z.B. "00:00")
                                Text(timeLocal.formatToHourlyTime() ?? "N/A")
                                    .font(.caption)

                                // Icon laden (Beispiel-URL, anpassen an Ihre WU-Icon-URL-Struktur)
                                // Weather Underground Icons haben oft ein Format wie:
                                // "https://www.weather.com/weather/images/core/forecast/assets/v1/7.svg"
                                // oder "https://www.weather.com/images/web/personal_weather_station/icons/\(iconCode).png"
                                if let iconUrl = URL(string: "https://www.weather.com/weather/images/core/forecast/assets/v1/\(iconCode).svg") {
                                    AsyncImage(url: iconUrl) { image in
                                        image.resizable()
                                            .scaledToFit()
                                            .frame(width: 30, height: 30)
                                    } placeholder: {
                                        ProgressView()
                                            .frame(width: 30, height: 30)
                                    }
                                } else {
                                    Image(systemName: "cloud.fill") // Fallback
                                        .resizable()
                                        .scaledToFit()
                                        .frame(width: 30, height: 30)
                                }

                                Text("\(temp)°")
                                    .font(.subheadline)
                                    .fontWeight(.medium)

                                // Regenwahrscheinlichkeit nur anzeigen, wenn relevant
                                if precipChance > 0 {
                                    Text("\(precipChance)%")
                                        .font(.caption2)
                                        .foregroundColor(.blue)
                                }
                            }
                        }
                    } else {
                        Text("Keine stündlichen Vorhersagedaten verfügbar.")
                            .frame(width: 250, height: 100)
                    }
                }
            }
        }
        .padding()
        .background(Color.white.opacity(0.1))
        .cornerRadius(10)
    }
}

// Hilfs-Erweiterung für die Zeitformatierung
extension String {
    func formatToHourlyTime() -> String? {
        let formatter = DateFormatter()
        formatter.dateFormat = "yyyy-MM-dd'T'HH:mm:ssZ" // Beispiel: "2025-06-07T00:00:00Z"
        formatter.locale = Locale(identifier: "en_US_POSIX") // Wichtig für ISO-Parsing

        if let date = formatter.date(from: self) {
            formatter.dateFormat = "HH:mm" // 24-Stunden-Format
            formatter.locale = Locale.current // Lokale Zeitzone verwenden
            return formatter.string(from: date)
        }
        return nil
    }
}
