//  YourTrip.swift — KamBing
import SwiftUI

struct YourTrip: View {
    @EnvironmentObject var appState: AppState
    @State private var showDatePicker = false

    private var isValid: Bool { !appState.fromCity.isEmpty && !appState.toCity.isEmpty }
    private var dateLabel: String {
        let f = DateFormatter(); f.dateStyle = .medium; return f.string(from: appState.departureDate)
    }

    var body: some View {
        ScrollView {
            VStack(alignment: .leading, spacing: 0) {

                // Header
                HStack(alignment: .top) {
                    VStack(alignment: .leading, spacing: 6) {
                        Text("Your trip").font(.largeTitle).fontWeight(.bold)
                        Text("We'll build your adaptation plan from this")
                            .font(.subheadline).foregroundStyle(.secondary)
                    }
                    Spacer()
                    Label(appState.inputMethod == .watch ? "Watch" : "Manual",
                          systemImage: appState.inputMethod == .watch ? "applewatch" : "hand.tap.fill")
                        .font(.caption2).fontWeight(.semibold).foregroundStyle(Color.accentColor)
                        .padding(.horizontal, 10).padding(.vertical, 5)
                        .background(Color.accentColor.opacity(0.10)).clipShape(Capsule())
                }
                .padding(.horizontal, 24).padding(.top, 20).padding(.bottom, 28)

                // MARK: TextField — From city
                // TextField dipakai bukan Picker karena kota asal jumlahnya tak terbatas
                // dan user sudah tahu nama kota mereka — lebih efisien mengetik (HIG).
                TripField(label: "From", placeholder: "e.g. Jakarta (JKT)", text: $appState.fromCity)
                    .padding(.horizontal, 24).padding(.bottom, 14)

                // MARK: TextField — To city
                TripField(label: "To", placeholder: "e.g. Los Angeles (LAX)", text: $appState.toCity)
                    .padding(.horizontal, 24).padding(.bottom, 14)

                // MARK: DatePicker — Departure date
                // DatePicker (.wheel style) dipilih bukan TextField untuk tanggal karena:
                // 1. Mencegah kesalahan format regional (DD/MM vs MM/DD)
                // 2. in: Date()... memblokir tanggal masa lalu di level UI (HIG: validasi dini)
                // 3. Sesuai mid-fi prototype (wheel/drum roll style)
                VStack(alignment: .leading, spacing: 6) {
                    Text("Departure date")
                        .font(.footnote).fontWeight(.semibold).foregroundStyle(.secondary)
                        .padding(.horizontal, 24)
                    Button {
                        withAnimation(.easeInOut(duration: 0.25)) { showDatePicker.toggle() }
                    } label: {
                        HStack {
                            Label(dateLabel, systemImage: "calendar").font(.body).foregroundStyle(.primary)
                            Spacer()
                            Image(systemName: showDatePicker ? "chevron.up" : "chevron.down")
                                .font(.footnote).foregroundStyle(.secondary)
                        }
                        .padding(.horizontal, 16).padding(.vertical, 14)
                        .background(Color(.systemBackground))
                        .clipShape(RoundedRectangle(cornerRadius: 12))
                        .overlay(RoundedRectangle(cornerRadius: 12).stroke(Color(.systemGray5), lineWidth: 0.5))
                        .padding(.horizontal, 24)
                    }
                    if showDatePicker {
                        DatePicker("", selection: $appState.departureDate,
                                   in: Date()..., displayedComponents: .date)
                            .datePickerStyle(.wheel).labelsHidden()
                            .padding(.horizontal, 24)
                            .transition(.opacity.combined(with: .move(edge: .top)))
                    }
                }
                .padding(.bottom, 14)

                // Time zone shift chip — muncul setelah destinasi diisi
                if !appState.toCity.isEmpty {
                    HStack(spacing: 6) {
                        Image(systemName: "clock.arrow.2.circlepath").font(.caption)
                        Text("+15 hr time zone shift detected").font(.footnote).fontWeight(.medium)
                    }
                    .foregroundStyle(Color.adaptOrange)
                    .padding(.horizontal, 14).padding(.vertical, 8)
                    .background(Color.adaptOrange.opacity(0.10)).clipShape(Capsule())
                    .padding(.horizontal, 24).padding(.bottom, 28)
                    .transition(.scale.combined(with: .opacity))
                }

                // Plan summary card
                if isValid {
                    HStack(spacing: 10) {
                        Image(systemName: "sparkles").foregroundStyle(.accentColor)
                        Text("We'll guide you with \(appState.inputMethod == .watch ? "live watch data" : "your sleep schedule") across the 15-hour shift.")
                            .font(.caption).foregroundStyle(.secondary)
                    }
                    .padding(16)
                    .background(Color.accentColor.opacity(0.06))
                    .clipShape(RoundedRectangle(cornerRadius: 14))
                    .overlay(RoundedRectangle(cornerRadius: 14).stroke(Color.accentColor.opacity(0.15), lineWidth: 0.5))
                    .padding(.horizontal, 24).padding(.bottom, 24)
                    .transition(.opacity.combined(with: .move(edge: .bottom)))
                }

                // MARK: NavigationLink → Screen3 (FIXED — was commented out)
                // Push dipakai karena flow kita sequential (HIG: Push untuk navigasi forward linear).
                NavigationLink {
                    Screen3SleepNow().environmentObject(appState)
                } label: {
                    HStack(spacing: 8) {
                        Text("Start adapting")
                        Image(systemName: "arrow.right").fontWeight(.semibold)
                    }
                    .font(.body).fontWeight(.semibold).foregroundStyle(.white)
                    .frame(maxWidth: .infinity).padding(.vertical, 16)
                    .background(
                        isValid
                        ? LinearGradient(colors: [.accentColor, .accentColor.opacity(0.75)],
                                         startPoint: .topLeading, endPoint: .bottomTrailing)
                        : LinearGradient(colors: [Color(.systemGray4), Color(.systemGray4)],
                                         startPoint: .leading, endPoint: .trailing),
                        in: RoundedRectangle(cornerRadius: 16))
                    .shadow(color: isValid ? Color.accentColor.opacity(0.30) : .clear, radius: 10, y: 5)
                    .animation(.spring(response: 0.4), value: isValid)
                }
                .disabled(!isValid)
                .padding(.horizontal, 24).padding(.bottom, 48)
            }
        }
        .background(Color(.systemGroupedBackground))
        .navigationTitle("").navigationBarTitleDisplayMode(.inline)
        .animation(.spring(response: 0.4), value: appState.toCity.isEmpty)
    }
}

private struct TripField: View {
    let label: String; let placeholder: String; @Binding var text: String
    var body: some View {
        VStack(alignment: .leading, spacing: 6) {
            Text(label).font(.footnote).fontWeight(.semibold).foregroundStyle(.secondary)
            TextField(placeholder, text: $text)
                .font(.body)
                .padding(.horizontal, 16).padding(.vertical, 14)
                .background(Color(.systemBackground))
                .clipShape(RoundedRectangle(cornerRadius: 12))
                .overlay(RoundedRectangle(cornerRadius: 12)
                    .stroke(text.isEmpty ? Color(.systemGray5) : Color.accentColor.opacity(0.4), lineWidth: 0.5))
                .autocorrectionDisabled().textInputAutocapitalization(.words)
                .animation(.easeInOut(duration: 0.2), value: text.isEmpty)
        }
    }
}

#Preview { NavigationStack { YourTrip().environmentObject(AppState()) } }
