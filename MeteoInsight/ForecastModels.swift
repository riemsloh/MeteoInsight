//
//  ForecastDataModels.swift
//  AuraCast
//
//  Created by Olaf Lueg on 04.06.25.
//
// Copyright by Olaf Lueg

import Foundation

// MARK: - Top-Level Forecast Response
/// Repräsentiert die gesamte API-Antwort für die 5-Tages-Vorhersage.
struct ForecastResponse: Codable {
    // NEU: Diese Felder enthalten die zuverlässigeren täglichen Max/Min-Temperaturen
    let calendarDayTemperatureMax: [Int]?
    let calendarDayTemperatureMin: [Int]?

    let dayOfWeek: [String]?
    let expirationTimeUtc: [Int]?
    let moonPhase: [String]?
    let moonPhaseCode: [String]?
    let moonPhaseDay: [Int]?
    let moonriseTimeLocal: [String]?
    let moonriseTimeUtc: [Int?]?
    let moonsetTimeLocal: [String]?
    let moonsetTimeUtc: [Int?]?
    let narrative: [String]?
    let qpf: [Double]? // Gesamtniederschlag
    let qpfSnow: [Double]? // Gesamtschneemenge
    let sunriseTimeLocal: [String]?
    let sunriseTimeUtc: [Int?]?
    let sunsetTimeLocal: [String]?
    let sunsetTimeUtc: [Int?]?
    
    // temperatureMax/Min auf Top-Level können null sein (siehe API-Doku nach 15 Uhr)
    let temperatureMax: [Int?]? // Geändert zu optionalem Array von optionalen Ints
    let temperatureMin: [Int?]? // Geändert zu optionalem Array von optionalen Ints
    
    let validTimeUtc: [Int]?
    let validTimeLocal: [String]?
    
    // Das 'daypart'-Objekt, das Tag- und Nachtvorhersagen enthält
    let daypart: [Daypart]?

    // CodingKeys, falls JSON-Schlüssel nicht mit Swift-Namen übereinstimmen
    enum CodingKeys: String, CodingKey {
        case calendarDayTemperatureMax
        case calendarDayTemperatureMin
        case dayOfWeek
        case expirationTimeUtc
        case moonPhase
        case moonPhaseCode
        case moonPhaseDay
        case moonriseTimeLocal
        case moonriseTimeUtc
        case moonsetTimeLocal
        case moonsetTimeUtc
        case narrative
        case qpf
        case qpfSnow
        case sunriseTimeLocal
        case sunriseTimeUtc
        case sunsetTimeLocal
        case sunsetTimeUtc
        case temperatureMax
        case temperatureMin
        case validTimeUtc
        case validTimeLocal
        case daypart
    }
}

// MARK: - Daypart
/// Repräsentiert die Vorhersagedaten für einen Tag- oder Nachtabschnitt.
struct Daypart: Codable {
    let cloudCover: [Int?]? // Kann null sein
    let dayOrNight: [String?]? // "D" für Tag, "N" für Nacht, kann null sein
    let daypartName: [String?]? // "Today", "Tonight", "Monday", etc., kann null sein
    let iconCode: [Int?]? // Kann null sein
    let iconCodeExtend: [Int?]? // Kann null sein
    let narrative: [String?]? // Kann null sein
    let precipChance: [Int?]? // Wahrscheinlichkeit für Niederschlag, kann null sein
    let precipType: [String?]? // Art des Niederschlags (rain, snow, precip), kann null sein
    let qpf: [Double?]? // Niederschlag für den 12-Stunden-Zeitraum, kann null sein
    let qpfSnow: [Double?]? // Schneemenge für den 12-Stunden-Zeitraum, kann null sein
    let qualifierCode: [String?]? // NEU: Code für spezielle Wetterkriterien, kann null sein
    let qualifierPhrase: [String?]? // Kann null sein
    let relativeHumidity: [Int?]? // Kann null sein
    let snowRange: [String?]? // Schneemenge als String-Bereich (z.B. "<1", "1-3"), kann null sein
    let temperature: [Int?]? // Temperatur für den Zeitabschnitt, kann null sein
    let temperatureHeatIndex: [Int?]? // Kann null sein
    let temperatureWindChill: [Int?]? // Kann null sein
    let thunderCategory: [String?]? // Kann null sein
    let thunderIndex: [Int?]? // Kann null sein
    let uvDescription: [String?]? // Kann null sein
    let uvindex: [Int?]? // Kann null sein
    let windDirection: [Int?]? // Kann null sein
    let windDirectionCardinal: [String?]? // Kann null sein
    let windPhrase: [String?]? // Kann null sein
    let windSpeed: [Int?]? // Kann null sein
    let wxPhraseLong: [String?]? // Kann null sein
    let wxPhraseShort: [String?]? // Kann null sein

    // CodingKeys, falls JSON-Schlüssel nicht mit Swift-Namen übereinstimmen
    enum CodingKeys: String, CodingKey {
        case cloudCover
        case dayOrNight
        case daypartName
        case iconCode
        case iconCodeExtend
        case narrative
        case precipChance
        case precipType
        case qpf
        case qpfSnow
        case qualifierCode // NEU
        case qualifierPhrase
        case relativeHumidity
        case snowRange
        case temperature
        case temperatureHeatIndex
        case temperatureWindChill
        case thunderCategory
        case thunderIndex
        case uvDescription
        case uvindex
        case windDirection
        case windDirectionCardinal = "wind Direction Cardinal" // JSON-Schlüssel mit Leerzeichen
        case windPhrase
        case windSpeed
        case wxPhraseLong
        case wxPhraseShort
    }
}
