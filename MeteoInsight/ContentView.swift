import SwiftUI
import CoreLocation // Für den LocationManager

struct ContentView: View {
    // Hier verwenden wir @StateObject, da WeatherViewModel und ForecastViewModel ObservableObject sind.
    // Für @Observable (ab iOS 17/macOS 14) würde @State ausreichen.
    @StateObject var weatherViewModel = WeatherViewModel()
    @StateObject var forecastViewModel = ForecastViewModel()
    @StateObject var locationManager = LocationManager() // Wir brauchen den LocationManager, um die Breiten- und Längengrade für die Vorhersage zu erhalten.

    @State private var selectedTabIndex: Int = 0 // Für zukünftige Tab-Navigation, falls gewünscht

    var body: some View {
        // Haupt-VStack für das Layout
        VStack(spacing: 20) {
            // MARK: - Kopfbereich (Ort, aktuelle Temperatur)
            HeaderView(
                currentObservation: weatherViewModel.observation,
                isLoading: weatherViewModel.isLoading,
                errorMessage: weatherViewModel.errorMessage
            )
            .padding(.horizontal)

            // MARK: - Aktueller Zustand und Warnungen (optional)
            CurrentStatusAndAlertsView(
                currentObservation: weatherViewModel.observation
            )
            .padding(.horizontal)

            // MARK: - Horizontale Stündliche Vorhersage
            HourlyForecastSection(
                forecastResponse: forecastViewModel.forecastResponse,
                isLoading: forecastViewModel.isLoading,
                errorMessage: forecastViewModel.errorMessage
            )
            .padding(.horizontal)

            // MARK: - Detaillierte Wetterinformationen
            DetailedWeatherInfoSection(
                currentObservation: weatherViewModel.observation,
                locationInfo: forecastViewModel.forecastResponse // Sonnenzeiten kommen hierher
            )
            .padding(.horizontal)

            // MARK: - Tägliche Vorhersage
            DailyForecastSection(
                forecastResponse: forecastViewModel.forecastResponse,
                isLoading: forecastViewModel.isLoading,
                errorMessage: forecastViewModel.errorMessage
            )
            .padding(.horizontal)

            Spacer()

            // MARK: - Ladeindikatoren und Fehleranzeige
            if weatherViewModel.isLoading || forecastViewModel.isLoading {
                ProgressView("Wetterdaten werden geladen...")
                    .controlSize(.large)
                    .tint(.white)
            } else if let error = weatherViewModel.errorMessage {
                Text("Fehler (Aktuell): \(error)")
                    .foregroundColor(.red)
                    .multilineTextAlignment(.center)
            } else if let error = forecastViewModel.errorMessage {
                Text("Fehler (Vorhersage): \(error)")
                    .foregroundColor(.red)
                    .multilineTextAlignment(.center)
            }
        }
        .padding(.vertical)
        .background(Color.black.ignoresSafeArea()) // Dunkler Hintergrund
        .foregroundColor(.white) // Weiße Schrift
        .onAppear {
            // Standortberechtigung anfordern
            locationManager.requestLocationAuthorization()

            // Starten Sie den automatischen Abruf für aktuelle und Vorhersagedaten
            weatherViewModel.startFetchingDataAutomatically()
            forecastViewModel.startFetchingDataAutomatically()
        }
        .onChange(of: locationManager.currentLocation) { oldLocation, newLocation in
            // Wenn der Standort aktualisiert wird, rufen Sie die Vorhersagedaten für diesen Standort ab.
            // Die aktuelle Beobachtung wird über stationId abgerufen, nicht über Geo-Koordinaten.
            if let newLocation = newLocation {
                // Nur wenn die gespeicherten Breiten- und Längengrade sich ändern, was in der Praxis bedeutet,
                // dass wir den aktuellen Standort des Geräts verwenden möchten, um die Vorhersage zu erhalten.
                // Die PWS-Daten (aktuelle Beobachtung) sind stationär.
                // Aktualisieren Sie die AppStorage-Werte im ForecastViewModel
                forecastViewModel.storedLatitude = newLocation.coordinate.latitude
                forecastViewModel.storedLongitude = newLocation.coordinate.longitude

                Task {
                    await forecastViewModel.fetchForecastData()
                }
            }
        }
        // Fehler-Alert für LocationManager
        .alert("Standortfehler", isPresented: Binding(
            get: { locationManager.lastError != nil },
            set: { _ in locationManager.lastError = nil }
        )) {
            Button("OK") { }
        } message: {
            if let error = locationManager.lastError {
                Text(error.localizedDescription)
            }
        }
    }
}
