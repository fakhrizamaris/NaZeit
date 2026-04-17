import SwiftUI

extension Color {
    static let circadianTeal = Color(uiColor: .circadianTeal)
    static let adaptOrange = Color(uiColor: .adaptOrange)
    static let bgOnboarding = Color(uiColor: .bgOnboarding)
    static let bgMorning = Color(red: 0.99, green: 0.78, blue: 0.26)
}

struct PrimaryBtn: View {
    let title: String
    var color: Color = .accentColor

    var body: some View {
        Text(title)
            .font(.body)
            .fontWeight(.semibold)
            .foregroundStyle(.white)
            .frame(maxWidth: .infinity)
            .padding(.vertical, 16)
            .background(
                LinearGradient(
                    colors: [color, color.opacity(0.75)],
                    startPoint: .topLeading,
                    endPoint: .bottomTrailing
                ),
                in: RoundedRectangle(cornerRadius: 16)
            )
            .shadow(color: color.opacity(0.30), radius: 10, y: 5)
    }
}

private struct InstructionCardModifier: ViewModifier {
    var isAdjusted: Bool

    func body(content: Content) -> some View {
        content
            .padding(28)
            .frame(maxWidth: .infinity)
            .background(.black.opacity(0.07), in: RoundedRectangle(cornerRadius: 24))
            .overlay(
                RoundedRectangle(cornerRadius: 24)
                    .stroke(isAdjusted ? Color.adaptOrange.opacity(0.45) : .black.opacity(0.08), lineWidth: isAdjusted ? 1.5 : 1)
            )
            .shadow(color: .black.opacity(0.10), radius: 20, y: 8)
    }
}

extension View {
    func instructionCard(isAdjusted: Bool = false) -> some View {
        modifier(InstructionCardModifier(isAdjusted: isAdjusted))
    }
}
