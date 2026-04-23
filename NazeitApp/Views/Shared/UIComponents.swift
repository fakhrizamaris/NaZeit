import SwiftUI

extension Color {
    static let circadianTeal = Color(uiColor: .circadianTeal)
    static let bgOnboarding = Color(uiColor: .bgOnboarding)
    static let bgMorning = Color(red: 0.99, green: 0.78, blue: 0.26)
    static let nazeitTeal = Color(uiColor: .nazeitTeal)
}

enum AppVisual {
    static let primaryCornerRadius: CGFloat = 16
    static let cardCornerRadius: CGFloat = 24
    static let primaryGradient = LinearGradient(
        colors: [Color.teal, Color.nazeitTeal],
        startPoint: .topLeading,
        endPoint: .bottomTrailing
    )
}

private struct PrimaryCTAStyle: ViewModifier {
    var isEnabled: Bool

    func body(content: Content) -> some View {
        content
            .font(.headline)
            .foregroundStyle(.white)
            .frame(maxWidth: .infinity)
            .padding(.vertical, 16)
            .background(
                isEnabled
                ? AnyShapeStyle(AppVisual.primaryGradient)
                : AnyShapeStyle(Color(uiColor: .quaternaryLabel)),
                in: RoundedRectangle(cornerRadius: AppVisual.primaryCornerRadius, style: .continuous)
            )
            .shadow(color: isEnabled ? Color.teal.opacity(0.20) : .clear, radius: 10, y: 5)
            .accessibilityAddTraits(.isButton)
    }
}

extension View {
    func appPrimaryCTAStyle(isEnabled: Bool = true) -> some View {
        modifier(PrimaryCTAStyle(isEnabled: isEnabled))
    }
}

private struct InteractiveTextLinkStyle: ViewModifier {
    var isEnabled: Bool

    func body(content: Content) -> some View {
        content
            .font(.subheadline.weight(.semibold))
            .foregroundStyle(isEnabled ? Color.blue : Color(uiColor: .tertiaryLabel))
            .frame(maxWidth: .infinity)
            .padding(.vertical, 10)
    }
}

extension View {
    func appInteractiveTextStyle(isEnabled: Bool = true) -> some View {
        modifier(InteractiveTextLinkStyle(isEnabled: isEnabled))
    }
}

struct PrimaryBtn: View {
    let title: String
    var isEnabled: Bool = true
    
    var body: some View {
        Text(title)
            .appPrimaryCTAStyle(isEnabled: isEnabled)
    }
}

private struct InstructionCardModifier: ViewModifier {
    var isAdjusted: Bool
    
    func body(content: Content) -> some View {
        content
            .padding(28)
            .frame(maxWidth: .infinity)
            .background(Color(uiColor: .secondarySystemBackground), in: RoundedRectangle(cornerRadius: 24))
            .overlay(
                RoundedRectangle(cornerRadius: 24)
                    .stroke(isAdjusted ? Color.mint.opacity(0.45) : Color(uiColor: .quaternaryLabel), lineWidth: isAdjusted ? 1.5 : 1)
            )
            .shadow(color: Color.black.opacity(0.05), radius: 20, y: 8)
    }
}

extension View {
    func instructionCard(isAdjusted: Bool = false) -> some View {
        modifier(InstructionCardModifier(isAdjusted: isAdjusted))
    }
}
