//
//  CurrentStatusAndAlertsView.swift
//  MeteoInsight
//
//  Created by Olaf Lueg on 08.06.25.
//

import SwiftUI

struct CurrentStatusAndAlertsView: View {
    let currentObservation: Observation?

    var body: some View {
        VStack(alignment: .leading, spacing: 5) {
            // Hier könnten Sie Logik für Warnungen oder besondere Hinweise einfügen.
            // Die "Regen erwartet..." Nachricht ist sehr spezifisch und müsste aus der API
            // intelligent abgeleitet werden, z.B. aus dem Narrative der Vorhersage.
            Text("Regen erwartet um ca. 05:00 Uhr. Die niedrigste gefühlte Temperatur wird 5° um ca. 23:00 betragen.")
                .font(.subheadline)
                .foregroundColor(.white.opacity(0.8))
                .padding()
                .background(Color.white.opacity(0.1))
                .cornerRadius(10)
        }
    }
}
