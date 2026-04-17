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
                // 🧠 [Design Principle: Hierarchy]
                // Judul besar agar user tahu ini hal penting.
                VStack(spacing: 8) {
                    Text("Pengecekan Keamanan")
                        .font(.title2).fontWeight(.bold)
                    Text("Algoritma sirkadian kami bekerja paling baik pada pola tidur normal.")
                        .font(.subheadline)
                        .foregroundStyle(.secondary)
                        .multilineTextAlignment(.center)
                }
                .padding(.top)

                // 🧠 [Gestalt: Similarity]
                // Opsi screening dengan bentuk yang sama.
                VStack(spacing: 12) {
                    ScreeningOptionRow(title: "Insomnia Klinis", icon: "moon.zzz", selected: $selectedCondition)
                    ScreeningOptionRow(title: "Lansia (>65 tahun)", icon: "figure.walk", selected: $selectedCondition)
                    ScreeningOptionRow(title: "Pola Tidur Normal", icon: "checkmark.shield", selected: $selectedCondition)
                }

                // 🧠 [Design Principle: Contrast (Warning Card)]
                // Menggunakan warna orange untuk menarik perhatian pada risiko medis.
                if selectedCondition != nil && selectedCondition != "Pola Tidur Normal" {
                    VStack(alignment: .leading, spacing: 8) {
                        HStack {
                            Image(systemName: "exclamationmark.triangle.fill")
                            Text("Peringatan Medis").fontWeight(.bold)
                        }
                        .foregroundStyle(.orange)
                        
                        Text("Instruksi cahaya mungkin tidak seefektif biasanya karena jam biologis Anda memiliki karakteristik khusus.")
                            .font(.caption)
                            .foregroundStyle(.secondary)
                    }
                    .padding()
                    .background(Color.orange.opacity(0.1))
                    .clipShape(RoundedRectangle(cornerRadius: 12))
                    .padding(.horizontal)
                }

                Spacer()

                // Tombol Aksi
                Button {
                    isAccepted = true
                } label: {
                    Text("Lanjutkan ke Aplikasi")
                        .fontWeight(.bold)
                        .frame(maxWidth: .infinity)
                        .padding()
                        .background(selectedCondition == nil ? Color.gray : Color(uiColor: .nazeitTeal))
                        .foregroundStyle(.white)
                        .clipShape(RoundedRectangle(cornerRadius: 16))
                }
                .disabled(selectedCondition == nil)
                .padding()
            }
            .padding()
            .background(Color(uiColor: .secondarySystemBackground))
        }
    }
}

// Sub-component untuk opsi
struct ScreeningOptionRow: View {
    let title: String; let icon: String
    @Binding var selected: String?
    
    var body: some View {
        Button { selected = title } label: {
            HStack {
                Image(systemName: icon).frame(width: 30)
                Text(title)
                Spacer()
                if selected == title { Image(systemName: "checkmark.circle.fill") }
            }
            .padding()
            .background(selected == title ? Color(uiColor: .nazeitTeal).opacity(0.1) : Color(uiColor: .tertiarySystemBackground))
            .foregroundStyle(selected == title ? Color(uiColor: .nazeitTeal) : .primary)
            .clipShape(RoundedRectangle(cornerRadius: 12))
            .overlay(RoundedRectangle(cornerRadius: 12).stroke(selected == title ? Color(uiColor: .nazeitTeal) : Color.clear, lineWidth: 2))
        }
    }
}
