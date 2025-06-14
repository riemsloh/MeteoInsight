//
//  StatusCardView.swift
//  MeteoInsight
//
//  Created by Olaf on 12.06.25.
//

import Foundation
import SwiftUI

struct MacStatusView: View {
    var body: some View {
        ZStack {
            // MARK: - Hintergrund-Farbverlauf
            LinearGradient(gradient: Gradient(colors: [Color(red: 0.2, green: 0.1, blue: 0.4), Color(red: 0.4, green: 0.1, blue: 0.6)]), startPoint: .topLeading, endPoint: .bottomTrailing)
                .edgesIgnoringSafeArea(.all)

            ScrollView { // Verwenden Sie ScrollView, wenn der Inhalt die Bildschirmhöhe überschreiten könnte
                VStack(alignment: .leading, spacing: 20) {
                    // MARK: - Kopfzeile
                    HStack {
                        VStack(alignment: .leading) {
                            Text("Mac Zustand: Gut")
                                .font(.largeTitle)
                                .fontWeight(.bold)
                                .foregroundColor(.white)
                            Text("iMac Pro")
                                .font(.title3)
                                .foregroundColor(.gray)
                        }
                        Spacer()
                        Image(systemName: "desktopcomputer.fill") // Ersetzen Sie dies ggf. durch das tatsächliche Symbol
                            .resizable()
                            .scaledToFit()
                            .frame(width: 60, height: 60)
                            .foregroundColor(Color.green.opacity(0.7))
                            .background(Color.white.opacity(0.1))
                            .cornerRadius(10)
                    }
                    .padding(.horizontal)

                    // MARK: - Sicherheitsbereich
                    SecurityStatusCard()
                        .padding(.horizontal)

                    // MARK: - Raster der Metrik-Karten
                    VStack(spacing: 15) {
                        HStack(spacing: 15) {
                            MetricCard(
                                title: "Mac Boot",
                                value: "Verfügbar: 40,42 GB",
                                iconName: "macbook", // Beispiel-Symbol
                                buttonText: "Freigeben"
                            )
                            MetricCard(
                                title: "Speicher",
                                value: "Speicherdruck: 12 %",
                                iconName: "memorychip.fill", // Beispiel-Symbol
                                buttonText: "Freigeben"
                            )
                        }
                        HStack(spacing: 15) {
                            MetricCard(
                                title: "CPU",
                                value: "Auslastung: 6 %",
                                iconName: "cpu", // Beispiel-Symbol
                                extraInfo: "-1°C"
                            )
                            MetricCard(
                                title: "Ethernet",
                                value: "↑ 58 KBytes\n↓ 4,3 MB/s",
                                iconName: "network", // Beispiel-Symbol
                                buttonText: "Speedtest"
                            )
                        }
                        // "Verbundene Geräte" ist eine einzelne Karte oder könnte Teil eines VStacks mit den obigen sein
                        MetricCard(
                            title: "Verbundene Geräte",
                            value: "Keine verbundenen Geräte",
                            iconName: "link" // Beispiel-Symbol
                        )
                        .frame(maxWidth: .infinity) // Volle Breite
                    }
                    .padding(.horizontal)

                    // MARK: - Heutige Empfehlung
                    VStack(alignment: .leading) {
                        Text("Heutige Empfehlung")
                            .font(.title2)
                            .fontWeight(.bold)
                            .foregroundColor(.white)
                            .padding(.horizontal)

                        RecommendationCard()
                            .padding(.horizontal)
                    }


                    Spacer() // Drückt den Inhalt nach oben

                    // MARK: - Fußzeile
                    HStack {
                        Spacer()
                        Button(action: {
                            // Aktion zum Öffnen von CleanMyMac
                            print("CleanMyMac öffnen")
                        }) {
                            Text("CleanMyMac öffnen")
                                .font(.headline)
                                .foregroundColor(.white)
                                .padding(.vertical, 10)
                                .padding(.horizontal, 20)
                                .background(Color.white.opacity(0.1))
                                .cornerRadius(8)
                        }
                        Spacer()
                    }
                    .padding(.bottom) // Unten etwas Abstand hinzufügen
                }
                .padding(.vertical) // Gesamter vertikaler Abstand
            }
        }
    }
}

// MARK: - Wiederverwendbare Kartenkomponenten

struct SecurityStatusCard: View {
    var body: some View {
        VStack(alignment: .leading, spacing: 10) { // Ein VStack, um die zwei Textzeilen zu gruppieren
            HStack {
                Image(systemName: "checkmark.circle.fill")
                    .foregroundColor(.green)
                    .font(.title2)
                Text("Geschützt durch")
                    .foregroundColor(.white)
                    .font(.headline)
                Image(systemName: "lock.fill") // Platzhalter für Moonlock-Symbol
                    .foregroundColor(.white)
                Text("Moonlock")
                    .foregroundColor(.white)
                    .font(.headline)
                Spacer()
                Image(systemName: "checkmark.shield.fill")
                    .foregroundColor(.green)
                Text("Geschützt")
                    .foregroundColor(.white)
            }
            .padding([.top, .horizontal]) // Padding nur oben und horizontal für diese HStack

            VStack(alignment: .leading) {
                Text("Echtzeit-Malwareüberwachung EIN")
                    .font(.subheadline)
                    .foregroundColor(.white.opacity(0.8))
                Text("Letzte gescannte Datei: GPUToolsCompatService")
                    .font(.caption)
                    .foregroundColor(.gray)
            }
            .padding([.bottom, .horizontal]) // Padding nur unten und horizontal für diese VStack
        }
        .background(Color.white.opacity(0.1))
        .cornerRadius(15)
        .overlay(
            RoundedRectangle(cornerRadius: 15)
                .stroke(Color.white.opacity(0.2), lineWidth: 1)
        )
    }
}

struct MetricCard: View {
    let title: String
    let value: String
    let iconName: String
    var buttonText: String? = nil
    var extraInfo: String? = nil // Für CPU-Temperatur

    var body: some View {
        VStack(alignment: .leading, spacing: 10) {
            HStack {
                Image(systemName: iconName)
                    .foregroundColor(.white.opacity(0.7))
                Text(title)
                    .font(.caption)
                    .foregroundColor(.white)
                Spacer()
                if let info = extraInfo {
                    Text(info)
                        .font(.caption)
                        .foregroundColor(.gray)
                }
            }
            Text(value)
                .font(.caption)
                .fontWeight(.bold)
                .foregroundColor(.white)
                .lineLimit(2) // Erlaubt den Zeilenumbruch, falls nötig

            if let button = buttonText {
                Spacer() // Drückt den Button nach unten, wenn die Kartenhöhe variiert
                Button(action: {
                    print("\(title) Button getippt")
                }) {
                    Text(button)
                        .font(.subheadline)
                        .foregroundColor(.blue) // Ein helleres Blau könnte besser passen
                        .padding(.vertical, 5)
                        .padding(.horizontal, 10)
                        .background(Color.white.opacity(0.1))
                        .cornerRadius(5)
                }
            }
        }
        .padding()
        .frame(maxWidth: .infinity, alignment: .leading)
        .frame(height: 140) // Feste Höhe für ein konsistentes Raster
        .background(Color.white.opacity(0.1))
        .cornerRadius(15)
        .overlay(
            RoundedRectangle(cornerRadius: 15)
                .stroke(Color.white.opacity(0.2), lineWidth: 1)
        )
    }
}

struct RecommendationCard: View {
    var body: some View {
        VStack(alignment: .leading, spacing: 15) {
            HStack(alignment: .top) {
                Image(systemName: "exclamationmark.triangle.fill")
                    .resizable()
                    .scaledToFit()
                    .frame(width: 30, height: 30)
                    .foregroundColor(.orange) // Oder die rosa Farbe aus dem Bild
                VStack(alignment: .leading) {
                    Text("Ausführlicher Scan empfohlen")
                        .font(.title3)
                        .fontWeight(.semibold)
                        .foregroundColor(.white)
                    Text("Führen Sie einen ausführlichen Scan nach Malware aus, damit Ihr System geschützt und frei von möglichen Gefahrenquellen ist.")
                        .font(.subheadline)
                        .foregroundColor(.gray)
                }
            }

            Button(action: {
                print("Malware Scan ausführen")
            }) {
                Text("Malware Scan ausführen")
                    .font(.headline)
                    .foregroundColor(.white)
                    .padding(.vertical, 10)
                    .padding(.horizontal, 20)
                    .background(Color.blue.opacity(0.7)) // Ein dunkleres Blau für den Button
                    .cornerRadius(8)
            }
            .frame(maxWidth: .infinity, alignment: .trailing) // Button rechts ausrichten
        }
        .padding()
        .background(Color.white.opacity(0.1))
        .cornerRadius(15)
        .overlay(
            RoundedRectangle(cornerRadius: 15)
                .stroke(Color.white.opacity(0.2), lineWidth: 1)
        )
    }
}


// MARK: - Preview Provider (für Xcode Canvas)
struct MacStatusView_Previews: PreviewProvider {
    static var previews: some View {
        MacStatusView()
            .previewLayout(.sizeThatFits) // Passt die Vorschau an den Inhalt an
    }
}
