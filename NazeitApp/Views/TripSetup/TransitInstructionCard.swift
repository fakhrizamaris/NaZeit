import SwiftUI
import Combine

struct TransitInstructionCard: View {
    @ObservedObject var appState: AppState
        // The View should only read state and render UI, never perform complex calculations inside the body.
    private var isDaytime: Bool {
        var calendar = Calendar.current
        calendar.timeZone = appState.transitTimeZone
        
        let hour = calendar.component(.hour, from: Date())
        return hour >= 6 && hour < 22 // 06:00 to 21:59
    }
    
    var body: some View {
        VStack(alignment: .leading, spacing: 16) {
            
            // MARK: - Header
            HStack {
                Image(systemName: isDaytime ? "sun.max.fill" : "moon.stars.fill")
                    .foregroundStyle(isDaytime ? .orange : .indigo)
                    .font(.title2)
                
                Text(appState.transitCity.isEmpty ? "Transit Instruction" : "Transit in \(appState.transitCity)")
                    .font(.headline)
                    .foregroundStyle(Color(uiColor: .label))
                
                Spacer()
            }
            
            // MARK: - Instructions
            VStack(alignment: .leading, spacing: 6) {
                Text(isDaytime ? "Stay Active & Hydrated" : "Relax & Dim Lights")
                    .font(.subheadline).bold()
                    .foregroundStyle(Color(uiColor: .label))
                
                Text(isDaytime ? "Walk around the terminal and seek natural light." : "Find a quiet spot. Avoid screens and bright lights.")
                    .font(.footnote)
                    .foregroundStyle(Color(uiColor: .secondaryLabel))
                    .fixedSize(horizontal: false, vertical: true)
            }
            
            // MARK: - Warning Banner
            // 🧠 [UX/Circadian Logic]: Analogous Harmony. Orange inherently commands attention for safety/warnings (sleep inertia prevention).
            HStack(alignment: .top, spacing: 12) {
                Image(systemName: "exclamationmark.triangle.fill")
                    .foregroundStyle(.orange)
                    .font(.subheadline)
                
                Text("Strict Power Nap Limit: 20-30 mins max to avoid deep sleep inertia.")
                    .font(.footnote).bold()
                    .foregroundStyle(Color(uiColor: .label))
                    .fixedSize(horizontal: false, vertical: true)
            }
            .padding(12)
            .frame(maxWidth: .infinity, alignment: .leading)
            .background(Color.orange.opacity(0.15))
            .clipShape(RoundedRectangle(cornerRadius: 8, style: .continuous))
        }
        .padding(16)
        // 💡 [Junior Developer Note]: True Dark Mode Native Colors. By using semantic UIColors, iOS handles the light/dark mode transitions perfectly.
        .background(Color(uiColor: .secondarySystemBackground))
        .clipShape(RoundedRectangle(cornerRadius: 16, style: .continuous))
        .overlay(
            RoundedRectangle(cornerRadius: 16, style: .continuous)
                .stroke(Color(uiColor: .quaternaryLabel), lineWidth: 0.5)
        )
    }
}

// MARK: - Previews
// 💡 [Junior Developer Note]: Previews are living documentation. Always provide them to let others test edge cases quickly.
#Preview("Transit Card - Light") {
    ZStack {
        Color(uiColor: .systemBackground).ignoresSafeArea()
        TransitInstructionCard(appState: {
            let state = AppState()
            state.transitCity = "Doha"
            return state
        }())
            .padding()
    }
    .preferredColorScheme(.light)
}

#Preview("Transit Card - Dark") {
    ZStack {
        Color(uiColor: .systemBackground).ignoresSafeArea()
        TransitInstructionCard(appState: {
            let state = AppState()
            state.transitCity = "Doha"
            return state
        }())
            .padding()
    }
    .preferredColorScheme(.dark)
}
