import SwiftUI

struct HourlyWeatherView: View {
    // Instanz des HourlyWeatherViewModel, die die Daten verwaltet
    @StateObject var viewModel = HourlyWeatherViewModel()

    var body: some View {
        NavigationView {
            VStack {
                if viewModel.isLoading {
                    // Ladeanzeige, während Daten abgerufen werden
                    ProgressView("Stündliche Wetterdaten werden geladen...")
                } else if let error = viewModel.errorMessage {
                    // Anzeige von Fehlermeldungen
                    Text("Fehler beim Abrufen der stündlichen Vorhersage: \(error)")
                        .foregroundColor(.red)
                        .padding()
                } else {
                    // Liste der stündlichen Vorhersagen, wenn Daten verfügbar sind
                    List(viewModel.hourlyForecasts) { forecast in
                        VStack(alignment: .leading) {
                            Text("\(forecast.formattedTime) (\(forecast.dayOfWeek ?? ""))")
                                .font(.headline)
                            Text("Temperatur: \(forecast.temperature?.formatted(.number.precision(.fractionLength(1))) ?? "N/A")°C")
                            Text("Gefühlte Temperatur: \(forecast.temperatureFeelsLike?.formatted(.number.precision(.fractionLength(1))) ?? "N/A")°C")
                            Text("Wind: \(forecast.windSpeed ?? 0) km/h \(forecast.windDirectionCardinal ?? "")")
                            Text("Bewölkung: \(forecast.cloudCover ?? 0)%")
                            Text("Niederschlagswahrscheinlichkeit: \(forecast.precipChance ?? 0)%")
                            Text("Beschreibung: \(forecast.wxPhraseLong ?? "N/A")")
                        }
                        .padding(.vertical, 4)
                    }
                }
            }
            .navigationTitle("Stündliche Vorhersage")
            .toolbar {
                ToolbarItem(placement: .primaryAction) { // Geändert von .navigationBarTrailing
                    // Der Button, der die Daten der stündlichen API abruft
                    Button("Stündliche Daten aktualisieren") {
                        // Aufruf der asynchronen Methode in einem Task
                        Task {
                            await viewModel.fetchHourlyWeatherData()
                        }
                    }
                }
            }
            .onAppear {
                // Optional: Daten beim ersten Erscheinen der Ansicht laden
                // Wenn Sie möchten, dass die Daten nur über den Button geladen werden,
                // können Sie diesen .onAppear-Block entfernen.
                // Wenn Sie es beibehalten, rufen die Daten beim Start und beim Button-Klick ab.
                if viewModel.hourlyForecasts.isEmpty && !viewModel.isLoading {
                    Task {
                        await viewModel.fetchHourlyWeatherData()
                    }
                }
            }
        }
    }
}

// MARK: - HourlyWeatherView_Previews
struct HourlyWeatherView_Previews: PreviewProvider {
    static var previews: some View {
        HourlyWeatherView()
    }
}
