import SwiftUI

struct HeaderView: View {
    let currentObservation: Observation?
    let isLoading: Bool
    let errorMessage: String?

    var body: some View {
        HStack {
            VStack(alignment: .leading) {
                // Ort (Neighborhood oder ein Fallback)
                if isLoading {
                    ProgressView()
                } else if let error = errorMessage {
                    Text("Ort konnte nicht geladen werden.")
                        .foregroundColor(.red)
                } else {
                    Text(currentObservation?.neighborhood ?? "Melle") // Beispiel: "Melle"
                        .font(.largeTitle)
                        .fontWeight(.bold)
                }

                // Aktuelle Beschreibung (nicht direkt in Observation, muss abgeleitet werden)
                // In WeatherModels.swift gibt es keine direkte 'conditionText' Eigenschaft.
                // Sie müssten diese entweder aus 'wxPhraseLong' oder 'wxPhraseShort' ableiten.
                // Für dieses Beispiel verwenden wir 'wxPhraseShort'
                Text(currentObservation?.neighborhood ?? "Wetter wird geladen...")
                    .font(.title2)
                    .foregroundColor(.gray)
            }
            Spacer()
            // Aktuelle Temperatur
            if isLoading {
                ProgressView()
            } else if let temp = currentObservation?.metric?.temp {
                Text("\(Int(temp))°")
                    .font(.system(size: 80))
                    .fontWeight(.thin)
            } else {
                Text("N/A")
                    .font(.system(size: 80))
                    .fontWeight(.thin)
            }
        }
    }
}
