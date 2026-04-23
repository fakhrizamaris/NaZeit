//
//  HealthScreeningModal.swift
//  NazeitApp
//
//  Created by Fakhri Djamaris on 17/04/26.
//

import SwiftUI

struct HealthScreeningModal: View {
    @EnvironmentObject var appState: AppState
    @Binding var isAccepted: Bool
    @State private var selectedCondition: String? = nil
    
    var body: some View {
        NavigationStack {
            VStack(spacing: 24) {
                VStack(spacing: 10) {
                    Text("Health Profile")
                        .font(.system(.title2, design: .rounded).weight(.bold))
                        .foregroundStyle(Color(uiColor: .label))
                    
                    Text("Our circadian algorithm works best on standard sleep patterns.")
                        .font(.body)
                        .foregroundStyle(Color(uiColor: .secondaryLabel))
                        .multilineTextAlignment(.center)
                }
                .padding(.top, 24)
                
                VStack(spacing: 12) {
                    ScreeningOptionRow(title: "Clinical Insomnia", icon: "moon.zzz", selected: $selectedCondition)
                    ScreeningOptionRow(title: "Elderly (>65 years)", icon: "figure.walk", selected: $selectedCondition)
                    ScreeningOptionRow(title: "Normal Sleep Pattern", icon: "checkmark.shield", selected: $selectedCondition)
                }
                
                if let condition = selectedCondition, condition != "Normal Sleep Pattern" {
                    MedicalWarningView()
                }
                
                Spacer(minLength: 16)
                
                Button {
                    // Map selection to AdaptationProfile
                    switch selectedCondition {
                    case "Clinical Insomnia":
                        appState.adaptationProfile = .insomnia
                        appState.isSleepDisorder = true
                        appState.selectedDisorder = "Clinical Insomnia"
                    case "Elderly (>65 years)":
                        appState.adaptationProfile = .gentle
                    default:
                        appState.adaptationProfile = .normal
                    }
                    isAccepted = true
                } label: {
                    Text("Continue Setup")
                        .appPrimaryCTAStyle(isEnabled: selectedCondition != nil)
                }
                .disabled(selectedCondition == nil)
                .padding(.bottom, 16)
            }
            .padding(.horizontal, 20)
            .background(Color(uiColor: .secondarySystemBackground))
            .interactiveDismissDisabled()
            .sensoryFeedback(.selection, trigger: selectedCondition)
        }
    }
}

struct MedicalWarningView: View {
    var body: some View {
        VStack(alignment: .leading, spacing: 8) {
            HStack {
                Image(systemName: "exclamationmark.triangle.fill")
                    .imageScale(.large)
                Text("Adaptation Notice")
                    .font(.subheadline)
                    .fontWeight(.bold)
            }
            .foregroundStyle(Color.orange)
            
            Text("Light exposure instructions may not be as effective because your biological clock has special characteristics.")
                .font(.footnote)
                .foregroundStyle(Color(uiColor: .secondaryLabel))
                .multilineTextAlignment(.leading)
        }
        .padding(16)
        .frame(maxWidth: .infinity, alignment: .leading)
        .background(Color.yellow.opacity(0.10))
        .clipShape(RoundedRectangle(cornerRadius: 16, style: .continuous))
        .overlay(
            RoundedRectangle(cornerRadius: 16, style: .continuous)
                .stroke(Color.orange.opacity(0.3), lineWidth: 1)
        )
        .transition(.scale(scale: 0.95).combined(with: .opacity))
    }
}

struct ScreeningOptionRow: View {
    let title: String
    let icon: String
    @Binding var selected: String?
    
    var isSelected: Bool { selected == title }
    
    var body: some View {
        Button {
            withAnimation(.spring(response: 0.3, dampingFraction: 0.7)) {
                selected = title
            }
        } label: {
            HStack(spacing: 16) {
                Image(systemName: icon)
                    .font(.title2)
                    .frame(width: 32)
                    .foregroundStyle(isSelected ? Color.nazeitTeal : Color(uiColor: .secondaryLabel))
                
                Text(title)
                    .font(.body)
                    .fontWeight(.medium)
                
                Spacer()
                
                if isSelected {
                    Image(systemName: "checkmark.circle.fill")
                        .font(.title3)
                }
            }
            .padding(16)
            .background(isSelected ? Color.nazeitTeal.opacity(0.12) : Color(uiColor: .tertiarySystemBackground))
            .foregroundStyle(isSelected ? Color.nazeitTeal : Color(uiColor: .label))
            .clipShape(RoundedRectangle(cornerRadius: 16, style: .continuous))
            .overlay(
                RoundedRectangle(cornerRadius: 16, style: .continuous)
                    .stroke(isSelected ? Color.nazeitTeal : Color(uiColor: .quaternaryLabel), lineWidth: isSelected ? 2 : 1)
            )
        }
    }
}

#Preview {
    HealthScreeningModal(isAccepted: .constant(false))
        .environmentObject(AppState())
}
