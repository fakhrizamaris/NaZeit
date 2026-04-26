//
//  Fundamental1.swift
//  NazeitApp
//
//  Created by Fakhri Djamaris on 25/04/26.
//

import SwiftUI
import Combine

// ============================================================
// MARK: - 1. ObservableObject + @Published + didSet + willSet
// ============================================================
// Ini seperti AppState.swift di proyekmu
// Class ini adalah "gudang data" yang bisa diakses semua View

class TripStore: ObservableObject {
    
    // @Published → memberitahu SwiftUI setiap kali nilai berubah
    // didSet     → dipanggil SETELAH nilai berubah
    // willSet    → dipanggil SEBELUM nilai berubah
    
    @Published var cityName: String = "" {
        willSet {
            // newValue = nilai yang AKAN masuk
            print("🟡 willSet → cityName akan berubah dari '\(cityName)' menjadi '\(newValue)'")
        }
        didSet {
            // oldValue = nilai yang BARU SAJA diganti
            print("🟢 didSet  → cityName sudah berubah. Nilai lama: '\(oldValue)'")
            saveToLog()
        }
    }
    
    @Published var passengerCount: Int = 1 {
        didSet {
            print("🟢 didSet  → passengerCount berubah menjadi \(passengerCount)")
            saveToLog()
        }
    }
    
    // Log sederhana — simulasi "simpan ke disk" seperti scheduleSave() di proyekmu
    @Published var activityLog: [String] = []
    
    private func saveToLog() {
        let entry = "Saved → City: '\(cityName)', Passengers: \(passengerCount)"
        activityLog.append(entry)
    }
}

// ============================================================
// MARK: - 2. Root App — tempat inject @EnvironmentObject
// ============================================================

//@main
//struct MiniTripApp: App {
//    // @StateObject → buat instance TripStore sekali di sini
//    // Mirip @StateObject var appState = AppState() di proyekmu
//    @StateObject var store = TripStore()
//    
//    var body: some Scene {
//        WindowGroup {
//            RootView()
//                .environmentObject(store) // inject sekali → semua child bisa akses
//        }
//    }
//}

// ============================================================
// MARK: - 3. RootView — menggunakan @EnvironmentObject
// ============================================================

struct RootView: View {
    // Tidak perlu deklarasi ulang — tinggal "tangkap" dari environment
    // Mirip semua View di proyekmu yang pakai @EnvironmentObject var appState
    @EnvironmentObject var store: TripStore
    
    // @State → milik RootView sendiri, tidak ada View lain yang peduli
    @State private var showSheet = false
    @State private var showPassengerPicker = false
    
    var body: some View {
        NavigationStack {
            VStack(spacing: 24) {
                
                // --- Info Card ---
                VStack(alignment: .leading, spacing: 8) {
                    Text("Trip Summary")
                        .font(.headline)
                    
                    // Langsung baca dari store — otomatis update kalau store berubah
                    Text("Kota Tujuan : \(store.cityName.isEmpty ? "Belum diisi" : store.cityName)")
                        .foregroundStyle(store.cityName.isEmpty ? .secondary : .primary)
                    
                    Text("Penumpang  : \(store.passengerCount) orang")
                }
                .padding()
                .frame(maxWidth: .infinity, alignment: .leading)
                .background(Color(.secondarySystemBackground))
                .clipShape(RoundedRectangle(cornerRadius: 16))
                .padding(.horizontal)
                
                // --- Tombol buka Sheet ---
                // showSheet adalah @State milik RootView
                Button("Isi Kota Tujuan") {
                    showSheet = true
                }
                .buttonStyle(.borderedProminent)
                
                // --- Toggle Passenger Picker ---
                Button(showPassengerPicker ? "Tutup Pilih Penumpang" : "Pilih Jumlah Penumpang") {
                    withAnimation {
                        showPassengerPicker.toggle()
                    }
                }
                .buttonStyle(.bordered)
                
                // PassengerPicker menerima @Binding
                // Kita pass $showPassengerPicker dan $store.passengerCount
                if showPassengerPicker {
                    PassengerPickerView(
                        isShowing: $showPassengerPicker,
                        count: $store.passengerCount  // $ = kasih akses dua arah
                    )
                    .transition(.move(edge: .bottom).combined(with: .opacity))
                }
                
                // --- Log Activity ---
                if !store.activityLog.isEmpty {
                    VStack(alignment: .leading, spacing: 6) {
                        Text("Activity Log (simulasi didSet save)")
                            .font(.caption)
                            .foregroundStyle(.secondary)
                        
                        // ForEach untuk looping — akan kita bahas di sesi berikutnya
                        ForEach(store.activityLog.indices, id: \.self) { i in
                            Text("• \(store.activityLog[i])")
                                .font(.caption2)
                                .foregroundStyle(.secondary)
                        }
                    }
                    .padding()
                    .frame(maxWidth: .infinity, alignment: .leading)
                    .background(Color(.tertiarySystemBackground))
                    .clipShape(RoundedRectangle(cornerRadius: 12))
                    .padding(.horizontal)
                }
                
                Spacer()
            }
            .navigationTitle("Mini Trip App")
            
            // Sheet — akan kita bahas di sesi berikutnya
            // Sekarang cukup tahu: sheet muncul dari bawah seperti modal
            .sheet(isPresented: $showSheet) {
                CityInputView()
                // Tidak perlu pass store — langsung pakai @EnvironmentObject
            }
        }
    }
}

// ============================================================
// MARK: - 4. CityInputView — pakai @EnvironmentObject langsung
// ============================================================
// View ini tidak menerima parameter apapun dari RootView
// Tapi tetap bisa akses dan UBAH store.cityName
// Inilah kekuatan @EnvironmentObject

struct CityInputView: View {
    @EnvironmentObject var store: TripStore  // tangkap dari environment
    @Environment(\.dismiss) var dismiss      // untuk tutup sheet
    
    // @State lokal — hanya untuk input sementara sebelum disimpan ke store
    @State private var inputText = ""
    
    var body: some View {
        NavigationStack {
            VStack(spacing: 20) {
                Text("Ketik nama kota tujuanmu")
                    .font(.subheadline)
                    .foregroundStyle(.secondary)
                
                TextField("Contoh: Tokyo", text: $inputText)
                    .textFieldStyle(.roundedBorder)
                    .padding(.horizontal)
                
                Button("Simpan") {
                    store.cityName = inputText  // ubah store langsung
                    // didSet di store akan otomatis dipanggil
                    // RootView akan otomatis update karena @Published
                    dismiss()
                }
                .buttonStyle(.borderedProminent)
                .disabled(inputText.isEmpty)
                
                Spacer()
            }
            .padding(.top, 32)
            .navigationTitle("Pilih Kota")
            .navigationBarTitleDisplayMode(.inline)
        }
    }
}

// ============================================================
// MARK: - 5. PassengerPickerView — pakai @Binding
// ============================================================
// View ini BERBEDA dengan CityInputView
// Dia menerima data lewat @Binding, bukan @EnvironmentObject
// Kenapa? Karena data ini di-pass langsung dari parent (RootView)
// dan lebih tepat untuk komponen kecil yang spesifik

struct PassengerPickerView: View {
    
    // @Binding → data ini MILIK RootView, bukan milik kita
    // Kita hanya "meminjam" — kalau kita ubah, RootView ikut berubah
    @Binding var isShowing: Bool
    @Binding var count: Int
    
    var body: some View {
        VStack(spacing: 12) {
            Text("Jumlah Penumpang")
                .font(.headline)
            
            HStack(spacing: 24) {
                // Tombol kurang
                Button {
                    if count > 1 { count -= 1 }  // langsung ubah @Binding
                } label: {
                    Image(systemName: "minus.circle.fill")
                        .font(.title)
                        .foregroundStyle(count > 1 ? .blue : .gray)
                }
                .disabled(count <= 1)
                
                Text("\(count)")
                    .font(.system(.title, design: .rounded).weight(.bold))
                    .frame(width: 40)
                
                // Tombol tambah
                Button {
                    if count < 9 { count += 1 }  // langsung ubah @Binding
                } label: {
                    Image(systemName: "plus.circle.fill")
                        .font(.title)
                        .foregroundStyle(count < 9 ? .blue : .gray)
                }
                .disabled(count >= 9)
            }
            
            Button("Selesai") {
                isShowing = false  // ubah @Binding isShowing milik RootView
            }
            .font(.subheadline)
            .foregroundStyle(.secondary)
        }
        .padding()
        .background(Color(.secondarySystemBackground))
        .clipShape(RoundedRectangle(cornerRadius: 20))
        .padding(.horizontal)
    }
}

#Preview {
    RootView()
        .environmentObject(TripStore())
}
