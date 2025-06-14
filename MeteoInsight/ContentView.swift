import SwiftUI

struct ContentView: View {
    // Instanz des HourlyWeatherViewModel, die die Daten verwaltet
    // Dies ist analog zur Verwendung in der HourlyWeatherView
    @StateObject var hourlyViewModel = HourlyWeatherViewModel()
    @StateObject var pwsViewModel = WeatherViewModel()

    var body: some View {
        ZStack {
            // MARK: - Hintergrund-Farbverlauf
            LinearGradient(gradient: Gradient(colors: [Color(red: 0.2, green: 0.1, blue: 0.4), Color(red: 0.4, green: 0.1, blue: 0.6)]), startPoint: .topLeading, endPoint: .bottomTrailing)
                .edgesIgnoringSafeArea(.all)
            // Überprüfen, ob Beobachtungsdaten und metrische Daten verfügbar sind.
            if let obs = pwsViewModel.observation, let metricData = obs.metric {
                ScrollView { // Verwenden Sie ScrollView, wenn der Inhalt die Bildschirmhöhe überschreiten könnte
                    VStack(alignment: .leading, spacing: 20) {
                        PWSInfoCard(pwsViewModel: pwsViewModel)
                        .padding([.top, .leading, .trailing])
                        HStack{
                            TemperaturCard(title: "Temperatur", value: metricData.temp.map { String(format: "%.0f", $0) } ?? "N/A", iconName: "thermometer.sun.circle")
                            LuftdruckCard(title: "Luftdruck", value: metricData.pressure.map { String(format: "%.0f", $0) } ?? "N/A", iconName: "barometer")
                        }
                        .padding(.horizontal)
                    }
                    .padding()
                }
            }
        }
        // WICHTIG: Starte den Datenabruf und den Timer, sobald dieses View erscheint.
        .onAppear {
            // stationId und apiKey Parameter entfernt, da ViewModel sie direkt aus AppStorage liest.
            pwsViewModel.startFetchingDataAutomatically()
            // Daten für die stündliche Vorhersage beim Erscheinen der ContentView laden
            // Nur laden, wenn noch keine Daten vorhanden sind und nicht bereits geladen wird
            if hourlyViewModel.hourlyForecasts.isEmpty && !hourlyViewModel.isLoading {
                Task {
                    await hourlyViewModel.fetchHourlyWeatherData()
                }
            }
        }
        .onDisappear {
            // Stoppe den Timer, wenn das Menüleisten-Pop-over geschlossen wird.
            pwsViewModel.stopFetchingDataAutomatically()
            
        }
    }
 
}

// MARK: - ContentView_Previews
struct ContentView_Previews: PreviewProvider {
    static var previews: some View {
        ContentView()
    }
}

struct PWSInfoCard: View {
    @ObservedObject var pwsViewModel = WeatherViewModel()
    var body: some View {
        let currentStatusColor: Color = pwsViewModel.isLoading ? Color.yellow : Color.green
        let automaticLoading: String = pwsViewModel.autoRefreshEnabled ? "EIN" : "AUS"
        let obs = pwsViewModel.observation
        VStack(alignment: .leading, spacing: 10) { // Ein VStack, um die zwei Textzeilen zu gruppieren
            HStack {
                Image(systemName: "checkmark.circle.fill")
                    .foregroundColor(currentStatusColor)
                    .font(.title2)
                Text("Wetterstation")
                    .foregroundColor(.white)
                    .font(.headline)
                Image(systemName: "lock.fill") // Platzhalter für Moonlock-Symbol
                    .foregroundColor(.white)
                Text("\(obs?.neighborhood ?? "N/A")")
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
                Text("Echtzeit-Wetterüberwachung \(automaticLoading)")
                    .font(.subheadline)
                    .foregroundColor(.white.opacity(0.8))
                Text("Letztes update: \(obs?.formattedDayAndDate ?? "N/A")")
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

// MARK: - Die Info Karte
struct TemperaturCard: View {
    let title: String
    let value: String
    let iconName: String

    var body: some View {
        VStack(alignment: .leading, spacing: 10) {
            HStack {
                Image(systemName: iconName)
                    .foregroundColor(.white.opacity(0.7))
                Text(title)
                    .font(.caption)
                    .foregroundColor(.white)
                Spacer()
            }
            Spacer()
            HStack(alignment: .center){
                Spacer()
                Text("\(value)°")
                    .font(.largeTitle)
                    .fontWeight(.bold)
                    .foregroundColor(.white)
                    .multilineTextAlignment(.center)
                    .lineLimit(2) // Erlaubt den Zeilenumbruch, falls nötig
                Spacer()
            }
            Spacer()
        }
        .padding()
        .frame(maxWidth: .infinity, alignment: .leading)
        .frame(width: 150, height: 150) // Feste Höhe für ein konsistentes Raster
        .background(Color.white.opacity(0.1))
        .cornerRadius(15)
        .overlay(
            RoundedRectangle(cornerRadius: 15)
                .stroke(Color.white.opacity(0.2), lineWidth: 1)
        )
    }
}
// MARK: - Die Luftfeuchtigkeits Karte
struct LuftdruckCard: View {
    let title: String
    let value: String
    let iconName: String

    var body: some View {
        VStack(alignment: .leading, spacing: 10) {
            HStack {
                Image(systemName: iconName)
                    .foregroundColor(.white.opacity(0.7))
                Text(title)
                    .font(.footnote)
                    .foregroundColor(.white)
                Spacer()
            }
            Spacer()
            HStack(alignment: .center){
                Spacer()
                Text("\(value)")
                    .font(.title)
                    .fontWeight(.bold)
                    .foregroundColor(.white)
                    .multilineTextAlignment(.center)
                    .lineLimit(2) // Erlaubt den Zeilenumbruch, falls nötig
                Spacer()
            }
            Spacer()
        }
        .padding()
        .frame(maxWidth: .infinity, alignment: .leading)
        .frame(width: 150, height: 150) // Feste Höhe für ein konsistentes Raster
        .background(Color.white.opacity(0.1))
        .cornerRadius(15)
        .overlay(
            RoundedRectangle(cornerRadius: 15)
                .stroke(Color.white.opacity(0.2), lineWidth: 1)
        )
    }
}

