//
//  HealthScreeningModal.swift
//  NazeitApp
//
//  Created by Fakhri Djamaris on 17/04/26.
//

import SwiftUI

struct HealthScreeningModal: View {
    @Binding var isAccepted: Bool
    @State private var selectedCondition: String? = nil
    
    var body: some View {
        NavigationStack {
            VStack(spacing: 24) {
                // Header
                VStack(spacing: 10) {
                    Text("Routine Check")
                        .font(.system(.title2, design: .rounded).weight(.bold))
                        .foregroundStyle(Color(uiColor: .label))
                    
                    Text("Our circadian algorithm works best on standard sleep patterns.")
                        .font(.body)
                        .foregroundStyle(Color(uiColor: .secondaryLabel))
                        .multilineTextAlignment(.center)
                }
                .padding(.top, 24) 

                // Options
                VStack(spacing: 12) {
                    ScreeningOptionRow(title: "Clinical Insomnia", icon: "moon.zzz", selected: $selectedCondition)
                    ScreeningOptionRow(title: "Elderly (>65 years)", icon: "figure.walk", selected: $selectedCondition)
                    ScreeningOptionRow(title: "Normal Sleep Pattern", icon: "checkmark.shield", selected: $selectedCondition)
                }

                // Medical Warning
                if let condition = selectedCondition, condition != "Normal Sleep Pattern" {
                    MedicalWarningView()
                }

                Spacer(minLength: 16)

                // Action Button
                Button {
                    isAccepted = true
                } label: {
                    Text("Continue Setup")
                        .font(.headline)
                        .frame(maxWidth: .infinity)
                        .padding(.vertical, 16)
                        .foregroundStyle(.white)
                        .background(
                            LinearGradient(colors: [Color.teal, Color(uiColor: .nazeitTeal)],
                                           startPoint: .topLeading, endPoint: .bottomTrailing),
                            in: RoundedRectangle(cornerRadius: 16, style: .continuous)
                        )
                        .shadow(color: Color.teal.opacity(0.20), radius: 10, y: 5)
                }
                .opacity(selectedCondition == nil ? 0.20 : 1)
                .disabled(selectedCondition == nil)
                .padding(.bottom, 16)
            }
            .padding(.horizontal, 20)
            .background(Color(uiColor: .secondarySystemBackground))
            .interactiveDismissDisabled()
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
            .foregroundStyle(Color.mint)
            
            Text("Light exposure instructions may not be as effective because your biological clock has special characteristics.")
                .font(.footnote)
                .foregroundStyle(Color(uiColor: .secondaryLabel))
                .multilineTextAlignment(.leading)
        }
        .padding(16)
        .frame(maxWidth: .infinity, alignment: .leading)
        .background(Color.mint.opacity(0.12))
        .clipShape(RoundedRectangle(cornerRadius: 16, style: .continuous))
        .overlay(
            RoundedRectangle(cornerRadius: 16, style: .continuous)
                .stroke(Color.mint.opacity(0.3), lineWidth: 1)
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
            .background(isSelected ? Color(uiColor: .nazeitTeal).opacity(0.12) : Color(uiColor: .tertiarySystemBackground))
            .foregroundStyle(isSelected ? Color(uiColor: .nazeitTeal) : Color(uiColor: .label))
            .clipShape(RoundedRectangle(cornerRadius: 16, style: .continuous))
            .overlay(
                RoundedRectangle(cornerRadius: 16, style: .continuous)
                    .stroke(isSelected ? Color(uiColor: .nazeitTeal) : Color(uiColor: .quaternaryLabel), lineWidth: isSelected ? 2 : 1)
            )
        }
    }
}

#Preview {
    HealthScreeningModal(isAccepted: .constant(false))
}
