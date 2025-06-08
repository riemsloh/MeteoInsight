//
//  DailyForecastSection.swift
//  MeteoInsight
//
//  Created by Olaf Lueg on 08.06.25.
//

import SwiftUI

struct DailyForecastSection: View {
    let forecastResponse: ForecastResponse?
    let isLoading: Bool
    let errorMessage: String?

    var body: some View {
        VStack(alignment: .leading) {
            Text("10-Tage Vorhersage") // Ihr Bild zeigt 10 Tage, das Modell 5
                .font(.headline)
                .padding(.bottom, 5)

            if isLoading {
                ProgressView("Laden...")
                    .frame(height: 200) // Platzhalter
            } else if let error = errorMessage {
                Text("Fehler: \(error)")
                    .foregroundColor(.red)
                    .frame(height: 200)
            } else if let response = forecastResponse,
                      let dayOfWeeks = response.dayOfWeek,
                      let maxTemps = response.calendarDayTemperatureMax,
                      let minTemps = response.calendarDayTemperatureMin,
                      let dayparts = response.daypart {
                
                // Wir müssen hier das daypart-Array intelligent mit den Tages-Arrays verknüpfen.
                // Das daypart-Array hat oft 2 Einträge pro Tag (Tag und Nacht).
                // Für die tägliche Vorhersage brauchen wir typischerweise nur die "Tag"-Dayparts.
                let dailyDayparts = dayparts.filter { $0.dayOrNight?.first == "D" }

                ForEach(0..<min(dayOfWeeks.count, maxTemps.count, minTemps.count, dailyDayparts.count), id: \.self) { index in
                    let dayOfWeek = dayOfWeeks[index]
                    let minTemp = minTemps[index]
                    let maxTemp = maxTemps[index]
                    let dailyDaypart = dailyDayparts[index]

                    HStack {
                        // Wochentag
                        Text(dayOfWeek.prefix(2).uppercased()) // "Mo", "Di" etc.
                            .frame(width: 40, alignment: .leading)

                        // Wetter-Icon für den Tag
                        if let iconCode = dailyDaypart.iconCode?.first,
                           let iconUrl = URL(string: "https://www.weather.com/weather/images/core/forecast/assets/v1/\(iconCode).svg") { // Beispiel URL
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

                        Spacer()

                        // Regenwahrscheinlichkeit
                        if let precipChance = dailyDaypart.precipChance?.first, precipChance > 0 {
                            Text("\(precipChance)%")
                                .font(.subheadline)
                                .foregroundColor(.blue)
                        } else {
                            Text("") // Oder "0%", je nach Präferenz
                        }

                        Spacer()

                        // Min/Max Temperatur mit "Balken"
                        HStack(spacing: 10) {
                            Text("\(minTemp ?? 0)°")
                                .font(.subheadline)
                                .foregroundColor(.gray)

                            // Temperatur-Visualisierung: Grauer Balken mit farbigem Bereich
                            GeometryReader { geometry in
                                ZStack(alignment: .leading) {
                                    // Grauer Hintergrundbalken
                                    Capsule()
                                        .fill(Color.gray.opacity(0.3))
                                        .frame(height: 6)

                                    // Farbiges Segment für den Temperaturbereich
                                    // Annahme: Temperaturen liegen typischerweise zwischen -10 und 35 Grad Celsius.
                                    // Skalierung muss eventuell angepasst werden, um realistische Darstellung zu erzielen.
                                    let minVal = -10.0 // Unterster Wert der Skala
                                    let maxVal = 35.0 // Oberster Wert der Skala
                                    let totalRange = maxVal - minVal
                                    
                                    let normalizedMin = (Double(minTemp ?? 0) - minVal) / totalRange
                                    let normalizedMax = (Double(maxTemp ?? 0) - minVal) / totalRange

                                    let startOffset = geometry.size.width * normalizedMin
                                    let width = geometry.size.width * (normalizedMax - normalizedMin)

                                    Capsule()
                                        .fill(LinearGradient(gradient: Gradient(colors: [.blue, .orange, .red]), startPoint: .leading, endPoint: .trailing))
                                        .frame(width: max(0, width), height: 6)
                                        .offset(x: max(0, startOffset)) // Sicherstellen, dass Offset nicht negativ ist
                                }
                            }
                            .frame(width: 100, height: 6) // Feste Größe für die Kapsel

                            Text("\(maxTemp ?? 0)°")
                                .font(.subheadline)
                                .fontWeight(.medium)
                        }
                        .frame(width: 150, alignment: .trailing) // Feste Breite für Temp-Anzeige
                    }
                    .padding(.vertical, 5)
                    Divider() // Trennlinie zwischen den Tagen
                }
            } else {
                Text("Keine täglichen Vorhersagedaten verfügbar.")
                    .frame(height: 200)
            }
        }
        .padding()
        .background(Color.white.opacity(0.1))
        .cornerRadius(10)
    }
}
