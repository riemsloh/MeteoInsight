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
                
                // Filtern nach den "Tag"-Dayparts für die tägliche Vorhersage
                let dailyDayparts = dayparts.filter { $0.dayOrNight?.first == "D" }

                // min() verwenden, um sicherzustellen, dass wir nicht über die Array-Grenzen hinausgehen
                ForEach(0..<min(dayOfWeeks.count, maxTemps.count, minTemps.count, dailyDayparts.count), id: \.self) { index in
                    let dayOfWeek = dayOfWeeks[index]
                    let minTemp = minTemps[index]
                    let maxTemp = maxTemps[index]
                    let dailyDaypart = dailyDayparts[index]

                    // Hier wird die neue Sub-View verwendet
                    DailyForecastRowView(
                        dayOfWeek: dayOfWeek,
                        minTemp: minTemp,
                        maxTemp: maxTemp,
                        dailyDaypart: dailyDaypart,
                        index: index // Übergeben Sie den Index, falls für daypart-Arrays benötigt
                    )
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

// MARK: - Neue Sub-View: DailyForecastRowView
struct DailyForecastRowView: View {
    let dayOfWeek: String
    let minTemp: Int
    let maxTemp: Int
    let dailyDaypart: Daypart
    let index: Int // Benötigt, um auf die optionalen Arrays im Daypart zuzugreifen

    var body: some View {
        HStack {
            // Wochentag
            Text(dayOfWeek.prefix(2).uppercased()) // "Mo", "Di" etc.
                .frame(width: 40, alignment: .leading)

            // Wetter-Icon für den Tag
            if let iconCode = dailyDaypart.iconCode?.first, // .first, da iconCode ein Array ist
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
            if let precipChance = dailyDaypart.precipChance?.first, precipChance ?? 0 > 0 { // .first, da precipChance ein Array ist
                Text("\(precipChance)%")
                    .font(.subheadline)
                    .foregroundColor(.blue)
            } else {
                Text("") // Wichtig: Auch hier muss eine View zurückgegeben werden
                    .font(.subheadline)
                    .frame(width: 40) // Platzhalter, um Layout zu stabilisieren
            }

            Spacer()

            // Min/Max Temperatur mit "Balken" - Ausgelagert in eigene Sub-View
            TemperatureBarView(minTemp: minTemp, maxTemp: maxTemp)
                .frame(width: 150, alignment: .trailing) // Feste Breite für Temp-Anzeige
        }
        .padding(.vertical, 5)
    }
}

// MARK: - Neue Sub-View: TemperatureBarView
struct TemperatureBarView: View {
    let minTemp: Int
    let maxTemp: Int

    var body: some View {
        HStack(spacing: 10) {
            Text("\(minTemp)°")
                .font(.subheadline)
                .foregroundColor(.gray)

            GeometryReader { geometry in
                ZStack(alignment: .leading) {
                    // Grauer Hintergrundbalken
                    Capsule()
                        .fill(Color.gray.opacity(0.3))
                        .frame(height: 6)

                    // Farbiges Segment für den Temperaturbereich
                    let minVal = -10.0 // Unterster Wert der Skala (anpassen!)
                    let maxVal = 35.0 // Oberster Wert der Skala (anpassen!)
                    let totalRange = maxVal - minVal
                    
                    // Sicherstellen, dass die Werte im Bereich der Skala liegen
                    let clampedMinTemp = Double(minTemp).clamped(to: minVal...maxVal)
                    let clampedMaxTemp = Double(maxTemp).clamped(to: minVal...maxVal)

                    let normalizedMin = (clampedMinTemp - minVal) / totalRange
                    let normalizedMax = (clampedMaxTemp - minVal) / totalRange

                    let startOffset = geometry.size.width * normalizedMin
                    let width = geometry.size.width * (normalizedMax - normalizedMin)

                    Capsule()
                        .fill(LinearGradient(gradient: Gradient(colors: [.blue, .orange, .red]), startPoint: .leading, endPoint: .trailing))
                        .frame(width: max(0, width), height: 6) // `max(0, width)` gegen negative Breiten
                        .offset(x: max(0, startOffset)) // `max(0, startOffset)` gegen negative Offsets
                }
            }
            .frame(width: 100, height: 6) // Feste Größe für die Kapsel

            Text("\(maxTemp)°")
                .font(.subheadline)
                .fontWeight(.medium)
        }
    }
}

// Hilfs-Erweiterung für Double, um Werte in einen Bereich zu klemmen (kann global sein)
extension Double {
    func clamped(to range: ClosedRange<Self>) -> Self {
        max(range.lowerBound, min(self, range.upperBound))
    }
}
