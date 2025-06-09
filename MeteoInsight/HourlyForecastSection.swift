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
                    } else if let response = forecastResponse,
                              let dayparts = response.daypart,
                              let validTimeLocals = response.validTimeLocal {
                        
                        // Filtern der Dayparts für Tag und Nacht, um eine konsistente Ansicht zu erhalten
                        // Die 5-Tages-Vorhersage liefert oft 12-Stunden-Abschnitte (Tag/Nacht).
                        // Wenn echte stündliche Daten benötigt werden, bräuchte man einen anderen API-Endpunkt.
                        let relevantDayparts = dayparts.prefix(20) // Beispiel: Zeige die nächsten 20 Perioden (ca. 10 Tage Tag/Nacht)

                        ForEach(0..<min(relevantDayparts.count, validTimeLocals.count), id: \.self) { index in
                            let daypart = relevantDayparts[index]
                            let timeString = validTimeLocals[index]

                            // Hier wird die neue Sub-View verwendet
                            HourlyForecastItemView(daypart: daypart, timeString: timeString, index: index)
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

// Hilfs-Erweiterung für die Zeitformatierung (kann global sein oder hier bleiben)
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

// MARK: - Neue Sub-View: HourlyForecastItemView
struct HourlyForecastItemView: View {
    let daypart: Daypart
    let timeString: String
    let index: Int // Benötigt, um auf die optionalen Arrays im Daypart zuzugreifen

    var body: some View {
        VStack {
            Text(timeString.formatToHourlyTime() ?? "N/A")
                .font(.caption)

            // Icon laden
            if let iconCode = daypart.iconCode?[index], // Zugriff auf den Wert im Array
               let iconUrl = URL(string: "https://www.weather.com/weather/images/core/forecast/assets/v1/\(iconCode).svg") {
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

            Text("\(Int(daypart.temperature?[index] ?? 0))°") // Zugriff auf den Wert im Array
                .font(.subheadline)
                .fontWeight(.medium)

            // Regenwahrscheinlichkeit nur anzeigen, wenn relevant
            if let precipChance = daypart.precipChance?[index], precipChance > 0 { // Zugriff auf den Wert im Array
                Text("\(precipChance)%")
                    .font(.caption2)
                    .foregroundColor(.blue)
            } else {
                Text("") // Platzhalter
                    .font(.caption2)
                    .frame(height: 15) // Platzhalter, um Layout-Verschiebungen zu vermeiden
            }
        }
    }
}
