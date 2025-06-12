import SwiftUI

struct ContentView: View {
    // Instanz des HourlyWeatherViewModel, die die Daten verwaltet
    // Dies ist analog zur Verwendung in der HourlyWeatherView
    @StateObject var hourlyViewModel = HourlyWeatherViewModel()

    var body: some View {
        MacStatusView()
        NavigationView {
            VStack(spacing: 20) {
                Text("Willkommen bei AuraCast")
                    .font(.largeTitle)
                    .fontWeight(.bold)
                    .padding(.bottom, 20)

                // Anzeige des Ladezustands oder Fehlers für die stündliche Vorhersage
                if hourlyViewModel.isLoading {
                    ProgressView("Stündliche Wetterdaten werden geladen...")
                } else if let error = hourlyViewModel.errorMessage {
                    Text("Fehler beim Abrufen der stündlichen Vorhersage: \(error)")
                        .foregroundColor(.red)
                        .multilineTextAlignment(.center)
                        .padding()
                } else if let firstForecast = hourlyViewModel.hourlyForecasts.first {
                    // Anzeige einer Zusammenfassung der ersten stündlichen Vorhersage
                    VStack(alignment: .leading, spacing: 10) {
                        Text("Aktuelle stündliche Vorhersage:")
                            .font(.title2)
                            .fontWeight(.semibold)
                        Text("Zeit: \(firstForecast.formattedTime) Uhr (\(firstForecast.dayOfWeek ?? ""))")
                        Text("Temperatur: \(firstForecast.temperature?.formatted(.number.precision(.fractionLength(1))) ?? "N/A")°C")
                        Text("Beschreibung: \(firstForecast.wxPhraseLong ?? "N/A")")
                        Text("Niederschlagswahrscheinlichkeit: \(firstForecast.precipChance ?? 0)%")
                    }
                    .padding()
                    .background(RoundedRectangle(cornerRadius: 15).fill(Color.blue.opacity(0.1)))
                    .shadow(radius: 5)
                } else {
                    Text("Keine stündlichen Vorhersagedaten verfügbar.")
                        .foregroundColor(.secondary)
                        .padding()
                }

                Spacer()

                // NavigationLink zur detaillierten HourlyWeatherView
                NavigationLink(destination: HourlyWeatherView()) {
                    Label("Detaillierte stündliche Vorhersage anzeigen", systemImage: "clock.fill")
                        .font(.headline)
                        .padding()
                        .frame(maxWidth: .infinity)
                        .background(Color.accentColor)
                        .foregroundColor(.white)
                        .cornerRadius(10)
                }
                .padding(.horizontal)

                Spacer()
            }
            .navigationTitle("Übersicht")
           // .navigationBarTitleDisplayMode(.inline)
            .onAppear {
                // Daten für die stündliche Vorhersage beim Erscheinen der ContentView laden
                // Nur laden, wenn noch keine Daten vorhanden sind und nicht bereits geladen wird
                if hourlyViewModel.hourlyForecasts.isEmpty && !hourlyViewModel.isLoading {
                    Task {
                        await hourlyViewModel.fetchHourlyWeatherData()
                    }
                }
            }
        }
    }
}

// MARK: - ContentView_Previews
struct ContentView_Previews: PreviewProvider {
    static var previews: some View {
        ContentView()
    }
}
