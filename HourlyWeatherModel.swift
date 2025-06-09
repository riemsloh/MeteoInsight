//
//  HourlyWeatherModel.swift
//  MeteoInsight
//
//  Created by Olaf on 09.06.25.
//
// MARK: - Import

import Foundation

// MARK: - HourlyForecastResponse
/// Repräsentiert die gesamte API-Antwort für die stündliche Wettervorhersage.
/// Enthält Arrays von Wetterdaten, die stundenweise gruppiert sind.
struct HourlyForecastResponse: Codable {
    let cloudCover: [Int]?
    let dayOfWeek: [String]?
    let dayOrNight: [String]?
    let expirationTimeUtc: [Int]?
    let iconCode: [Int]?
    let iconCodeExtend: [Int]?
    let precipChance: [Int]?
    let precipType: [String]?
    let pressureMeanSeaLevel: [Double]?
    let qpf: [Double]?
    let qpfSnow: [Double]?
    let relativeHumidity: [Int]?
    let temperature: [Double]?
    let temperatureDewPoint: [Double]?
    let temperatureFeelsLike: [Double]?
    let temperatureHeatIndex: [Double]?
    let temperatureWindChill: [Double]?
    let uvDescription: [String]?
    let uvIndex: [Int]?
    let validTimeLocal: [String]? // String, da es ein ISO 8601 Datum ist
    let validTimeUtc: [Int]?
    let visibility: [Double]?
    let windDirection: [Int]?
    let windDirectionCardinal: [String]?
    let windGust: [Int?]? // Optional, da null Werte vorkommen können
    let windSpeed: [Int]?
    let wxPhraseLong: [String]?
    let wxPhraseShort: [String]?
    let wxSeverity: [Int]?
    let ceiling: [Int]?
    let scatteredCloudBaseHeight: [Int]?
    let pressureAltimeter: [Double]?
    let qpfIce: [Double]?
    let qualifierSet: [[String]]? // Array von Arrays, da es leere Arrays sein können
    let temperatureWetBulbGlobe: [Double]?
    let conditionalProbabilityThunder: [Int]?
    let conditionalProbabilitySleet: [Int]?
    let conditionalProbabilitySnow: [Int]?
    let conditionalProbabilityRain: [Int]?
    let conditionalProbabilityFreezingRain: [Int]?

    /// Eine Helfer-Methode, um die Daten pro Stunde zu strukturieren.
    /// Dies macht das Arbeiten mit den Daten wesentlich einfacher.
    func hourlyData() -> [HourlyForecastData] {
        var hourlyForecasts: [HourlyForecastData] = []
        let count = validTimeLocal?.count ?? 0

        for i in 0..<count {
            let hourly = HourlyForecastData(
                cloudCover: cloudCover?[i],
                dayOfWeek: dayOfWeek?[i],
                dayOrNight: dayOrNight?[i],
                expirationTimeUtc: expirationTimeUtc?[i],
                iconCode: iconCode?[i],
                iconCodeExtend: iconCodeExtend?[i],
                precipChance: precipChance?[i],
                precipType: precipType?[i],
                pressureMeanSeaLevel: pressureMeanSeaLevel?[i],
                qpf: qpf?[i],
                qpfSnow: qpfSnow?[i],
                relativeHumidity: relativeHumidity?[i],
                temperature: temperature?[i],
                temperatureDewPoint: temperatureDewPoint?[i],
                temperatureFeelsLike: temperatureFeelsLike?[i],
                temperatureHeatIndex: temperatureHeatIndex?[i],
                temperatureWindChill: temperatureWindChill?[i],
                uvDescription: uvDescription?[i],
                uvIndex: uvIndex?[i],
                validTimeLocal: validTimeLocal?[i],
                validTimeUtc: validTimeUtc?[i],
                visibility: visibility?[i],
                windDirection: windDirection?[i],
                windDirectionCardinal: windDirectionCardinal?[i],
                windGust: windGust?[i],
                windSpeed: windSpeed?[i],
                wxPhraseLong: wxPhraseLong?[i],
                wxPhraseShort: wxPhraseShort?[i],
                wxSeverity: wxSeverity?[i],
                ceiling: ceiling?[i],
                scatteredCloudBaseHeight: scatteredCloudBaseHeight?[i],
                pressureAltimeter: pressureAltimeter?[i],
                qpfIce: qpfIce?[i],
                qualifierSet: qualifierSet?[i],
                temperatureWetBulbGlobe: temperatureWetBulbGlobe?[i],
                conditionalProbabilityThunder: conditionalProbabilityThunder?[i],
                conditionalProbabilitySleet: conditionalProbabilitySleet?[i],
                conditionalProbabilitySnow: conditionalProbabilitySnow?[i],
                conditionalProbabilityRain: conditionalProbabilityRain?[i],
                conditionalProbabilityFreezingRain: conditionalProbabilityFreezingRain?[i]
            )
            hourlyForecasts.append(hourly)
        }
        return hourlyForecasts
    }
}

// MARK: - HourlyForecastData
/// Diese Struktur repräsentiert die Daten für eine einzelne Stunde der Vorhersage.
struct HourlyForecastData: Codable, Identifiable {
    let id = UUID() // Für die Verwendung in SwiftUI Listen

    let cloudCover: Int?
    let dayOfWeek: String?
    let dayOrNight: String?
    let expirationTimeUtc: Int?
    let iconCode: Int?
    let iconCodeExtend: Int?
    let precipChance: Int?
    let precipType: String?
    let pressureMeanSeaLevel: Double?
    let qpf: Double?
    let qpfSnow: Double?
    let relativeHumidity: Int?
    let temperature: Double?
    let temperatureDewPoint: Double?
    let temperatureFeelsLike: Double?
    let temperatureHeatIndex: Double?
    let temperatureWindChill: Double?
    let uvDescription: String?
    let uvIndex: Int?
    let validTimeLocal: String?
    let validTimeUtc: Int?
    let visibility: Double?
    let windDirection: Int?
    let windDirectionCardinal: String?
    let windGust: Int?
    let windSpeed: Int?
    let wxPhraseLong: String?
    let wxPhraseShort: String?
    let wxSeverity: Int?
    let ceiling: Int?
    let scatteredCloudBaseHeight: Int?
    let pressureAltimeter: Double?
    let qpfIce: Double?
    let qualifierSet: [String]?
    let temperatureWetBulbGlobe: Double?
    let conditionalProbabilityThunder: Int?
    let conditionalProbabilitySleet: Int?
    let conditionalProbabilitySnow: Int?
    let conditionalProbabilityRain: Int?
    let conditionalProbabilityFreezingRain: Int?

    // Optional: Eine formatierte Zeit für die Anzeige
    var formattedTime: String {
        guard let timeString = validTimeLocal else { return "N/A" }
        let formatter = DateFormatter()
        formatter.dateFormat = "yyyy-MM-dd'T'HH:mm:ssZ"
        if let date = formatter.date(from: timeString) {
            formatter.dateFormat = "HH:mm" // z.B. "14:00"
            return formatter.string(from: date)
        }
        return "N/A"
    }

    // Optional: Formatierter Tag und Datum für die Anzeige
    var formattedDayAndDate: String {
        guard let timeString = validTimeLocal else { return "N/A" }
        let formatter = DateFormatter()
        formatter.dateFormat = "yyyy-MM-dd'T'HH:mm:ssZ"
        if let date = formatter.date(from: timeString) {
            formatter.dateFormat = "EEEE, dd.MM." // z.B. "Montag, 09.06."
            formatter.locale = Locale(identifier: "de_DE") // Für deutschen Wochentag
            return formatter.string(from: date)
        }
        return "N/A"
    }
}
