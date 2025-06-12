//
//  TemperaturBarView.swift
//  MeteoInsight
//
//  Created by Olaf Lueg on 12.06.25.
//
import SwiftUI

// Hilfs-Erweiterung für Double, um Werte in einen Bereich zu klemmen
// Diese Erweiterung kann in einer separaten Datei (z.B. Extensions.swift) oder in einer Ihrer View-Dateien liegen.
extension Double {
    func clamped(to range: ClosedRange<Self>) -> Self {
        max(range.lowerBound, min(self, range.upperBound))
    }
}

// MARK: - TemperatureBarView
/// Eine wiederverwendbare View zur Darstellung eines Temperaturbalkens mit Min- und Max-Werten.
struct TemperatureBarView: View {
    let minTemp: Int
    let maxTemp: Int

    var body: some View {
        HStack(spacing: 10) {
            // Text für die minimale Temperatur
            Text("\(minTemp)°")
                .font(.subheadline)
                .foregroundColor(.gray)

            // Der eigentliche Temperaturbalken, der seine Größe vom Elternteil bekommt
            GeometryReader { geometry in
                ZStack(alignment: .leading) {
                    // 1. Grauer Hintergrundbalken (Die gesamte Breite der verfügbaren Fläche)
                    Capsule()
                        .fill(Color.gray.opacity(0.3)) // Ein leicht transparenter grauer Hintergrund
                        .frame(height: 6) // Feste Höhe des Balkens

                    // 2. Farbiges Segment für den Temperaturbereich
                    // Definieren Sie die Skala für Ihre Temperaturwerte.
                    // Diese Werte sollten dem erwarteten minimalen und maximalen Temperaturbereich entsprechen,
                    // den Ihre App anzeigen soll, unabhängig von den aktuellen Daten.
                    // Beispiel: -10°C bis +35°C
                    let minScaleValue = -10.0 // Unterster Wert der gesamten Skala (z.B. kältester Punkt)
                    let maxScaleValue = 35.0  // Oberster Wert der gesamten Skala (z.B. heißester Punkt)
                    let totalRange = maxScaleValue - minScaleValue // Die Gesamtspanne der Skala

                    // Clamped-Werte, um sicherzustellen, dass die Temperaturen innerhalb der definierten Skala liegen
                    // Verhindert, dass die Balken über die Ränder hinausgehen, wenn Daten außerhalb der Skala liegen.
                    let clampedMinTemp = Double(minTemp).clamped(to: minScaleValue...maxScaleValue)
                    let clampedMaxTemp = Double(maxTemp).clamped(to: minScaleValue...maxScaleValue)

                    // Normalisieren der Min- und Max-Temperaturen auf einen Wert zwischen 0 und 1
                    // 0 entspricht minScaleValue, 1 entspricht maxScaleValue
                    let normalizedMin = (clampedMinTemp - minScaleValue) / totalRange
                    let normalizedMax = (clampedMaxTemp - minScaleValue) / totalRange

                    // Berechnen der Startposition (Offset) des farbigen Segments
                    // Multipliziert mit der Gesamtbreite des Balkens
                    let startOffset = geometry.size.width * normalizedMin

                    // Berechnen der Breite des farbigen Segments (Temperaturspanne)
                    let width = geometry.size.width * (normalizedMax - normalizedMin)

                    // Der farbige Balken
                    Capsule()
                        // Linearer Farbverlauf von Blau (kalt) über Orange zu Rot (heiß)
                        .fill(LinearGradient(gradient: Gradient(colors: [.blue, .orange, .red]), startPoint: .leading, endPoint: .trailing))
                        .frame(width: max(0, width), height: 6) // `max(0, width)` stellt sicher, dass die Breite nicht negativ wird
                        .offset(x: max(0, startOffset)) // `max(0, startOffset)` stellt sicher, dass der Offset nicht negativ wird
                }
            }
            .frame(width: 100, height: 6) // Feste Größe für die Kapsel, dies bestimmt die Gesamtbreite des Balkens

            // Text für die maximale Temperatur
            Text("\(maxTemp)°")
                .font(.subheadline)
                .fontWeight(.medium)
        }
    }
}
