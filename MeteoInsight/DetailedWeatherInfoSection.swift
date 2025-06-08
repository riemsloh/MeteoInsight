//
//  DetailedWeatherInfoSection.swift
//  MeteoInsight
//
//  Created by Olaf Lueg on 08.06.25.
//

import SwiftUI

struct DetailedWeatherInfoSection: View {
    let currentObservation: Observation?
    let locationInfo: ForecastResponse? // Enthält sunriseTimeLocal / sunsetTimeLocal

    var body: some View {
        VStack(alignment: .leading, spacing: 10) {
            Text("Details")
                .font(.headline)
                .padding(.bottom, 5)

            Grid(horizontalSpacing: 20, verticalSpacing: 10) {
                GridRow {
                    DetailItem(label: "Gefühlt", value: (currentObservation?.metric?.heatIndex).map { "\(Int($0))°" } ?? "N/A", icon: "thermometer")
                    DetailItem(label: "Wind", value: (currentObservation?.metric?.windSpeed).map { "\(Int($0)) km/h" } ?? "N/A", icon: "wind")
                    DetailItem(label: "Feuchtigkeit", value: (currentObservation?.humidity).map { "\($0)%" } ?? "N/A", icon: "humidity.fill")
                }
                GridRow {
                    DetailItem(label: "Druck", value: (currentObservation?.metric?.pressure).map { "\($0) mb" } ?? "N/A", icon: "gauge")
                    DetailItem(label: "Sichtweite", value: (currentObservation?.metric?.vis).map { "\(Int($0)) km" } ?? "N/A", icon: "eye.fill") // Annahme vis in UnitsData
                    DetailItem(label: "UV Index", value: (currentObservation?.uv).map { "\(Int($0))" } ?? "N/A", icon: "sun.max.fill")
                }
                GridRow {
                    DetailItem(label: "Sonnenaufgang", value: (locationInfo?.sunriseTimeLocal?.first).map { $0.formatToHourMinute() ?? "N/A" } ?? "N/A", icon: "sunrise.fill")
                    DetailItem(label: "Sonnenuntergang", value: (locationInfo?.sunsetTimeLocal?.first).map { $0.formatToHourMinute() ?? "N/A" } ?? "N/A", icon: "sunset.fill")
                    DetailItem(label: "Niederschlag", value: (currentObservation?.metric?.precipTotal).map { "\($0) mm" } ?? "N/A", icon: "drop.fill")
                }
            }
        }
        .padding()
        .background(Color.white.opacity(0.1))
        .cornerRadius(10)
    }
}

// Hilfsansicht für einzelne Detail-Items (unverändert)
struct DetailItem: View {
    let label: String
    let value: String
    let icon: String // SFSymbol-Name

    var body: some View {
        HStack {
            Image(systemName: icon)
                .font(.caption)
                .frame(width: 20)
            VStack(alignment: .leading) {
                Text(label)
                    .font(.caption)
                    .foregroundColor(.gray)
                Text(value)
                    .font(.subheadline)
                    .fontWeight(.medium)
            }
            Spacer()
        }
    }
}

// Hilfs-Erweiterung für die Zeitformatierung
extension String {
    func formatToHourMinute() -> String? {
        let formatter = DateFormatter()
        formatter.dateFormat = "HH:mm" // Oder "h:mm a" für AM/PM, je nach API-Format
        formatter.locale = Locale(identifier: "de_DE") // Für deutsche Uhrzeit
        
        // Versuchen, Datum von verschiedenen möglichen Formaten zu parsen (z.B. "HH:mm", "yyyy-MM-dd HH:mm:ss")
        // Dies ist eine Vereinfachung. Besser wäre es, das exakte API-Format zu kennen.
        if let date = formatter.date(from: self) {
            return formatter.string(from: date)
        }
        
        // Wenn das Format nicht "HH:mm" ist, versuchen Sie ISO8601, falls die API es so liefert
        let isoFormatter = ISO8601DateFormatter()
        isoFormatter.formatOptions = [.withFullDate, .withTime, .withDashSeparatorInDate, .withColonSeparatorInTime, .withTimeZone]
        if let date = isoFormatter.date(from: self) {
            formatter.dateFormat = "HH:mm"
            return formatter.string(from: date)
        }
        
        return nil
    }
}
