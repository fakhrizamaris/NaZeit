//
//  Fundamental2.swift
//  NazeitApp
//
//  Created by Fakhri Djamaris on 25/04/26.
//

import SwiftUI
import Combine


// ============================================================
// MARK: - Store
// ============================================================

class NavStore: ObservableObject {
    @Published var username: String = "" {
        didSet { print("🟢 username berubah → \(username)") }
    }
    @Published var destination: String = "" {
        didSet { print("🟢 destination berubah → \(destination)") }
    }
}

// ============================================================
// MARK: - Halaman 1 (Root) — NavigationStack ada di sini
// ============================================================

struct F2_RootView: View {
    @StateObject var store = NavStore()
    
    // @State untuk kontrol sheet
    @State private var showSheet = false
    
    var body: some View {
        // NavigationStack = wadah untuk semua push navigation
        // Harus ada di ROOT, tidak perlu di setiap halaman
        NavigationStack {
            VStack(spacing: 24) {
                
                // Tampilkan data dari store
                VStack(spacing: 8) {
                    Text("Username   : \(store.username.isEmpty ? "-" : store.username)")
                    Text("Destination: \(store.destination.isEmpty ? "-" : store.destination)")
                }
                .padding()
                .frame(maxWidth: .infinity)
                .background(Color(.secondarySystemBackground))
                .clipShape(RoundedRectangle(cornerRadius: 16))
                .padding(.horizontal)
                
                // ✅ PUSH → pakai NavigationLink
                // Mirip OnboardingChoice → ConnectAppleWatch di proyekmu
                NavigationLink {
                    F2_PageTwo()
                        .environmentObject(store)
                } label: {
                    Label("Push ke Halaman 2", systemImage: "arrow.right.circle.fill")
                        .frame(maxWidth: .infinity)
                        .padding()
                        .background(Color.blue)
                        .foregroundStyle(.white)
                        .clipShape(RoundedRectangle(cornerRadius: 16))
                        .padding(.horizontal)
                }
                
                // ✅ SHEET → pakai .sheet modifier + @State boolean
                // Mirip HealthScreeningModal di proyekmu
                Button {
                    showSheet = true   // buka sheet
                } label: {
                    Label("Buka Sheet", systemImage: "arrow.up.circle.fill")
                        .frame(maxWidth: .infinity)
                        .padding()
                        .background(Color.indigo)
                        .foregroundStyle(.white)
                        .clipShape(RoundedRectangle(cornerRadius: 16))
                        .padding(.horizontal)
                }
                
                Spacer()
            }
            .navigationTitle("Halaman 1")
            
            // Sheet didefinisikan di sini
            // isPresented terhubung ke @State showSheet
            .sheet(isPresented: $showSheet) {
                F2_SheetView()
                    .environmentObject(store)
            }
        }
        .environmentObject(store)
    }
}

// ============================================================
// MARK: - Halaman 2 — hasil dari Push
// ============================================================
// Tidak ada NavigationStack di sini
// Tombol Back otomatis muncul di kiri atas

struct F2_PageTwo: View {
    @EnvironmentObject var store: NavStore
    
    // @State lokal untuk input
    @State private var inputUsername = ""
    
    var body: some View {
        VStack(spacing: 20) {
            Text("Kamu di-push ke sini dari Halaman 1")
                .font(.subheadline)
                .foregroundStyle(.secondary)
                .multilineTextAlignment(.center)
                .padding(.horizontal)
            
            // Input username
            TextField("Masukkan username", text: $inputUsername)
                .textFieldStyle(.roundedBorder)
                .padding(.horizontal)
            
            Button("Simpan & Kembali") {
                store.username = inputUsername  // ubah store
                // Tidak perlu navigate manual
                // Tombol Back otomatis kembali ke Halaman 1
            }
            .buttonStyle(.borderedProminent)
            .disabled(inputUsername.isEmpty)
            
            // Push lagi ke Halaman 3 — menumpuk lebih dalam
            NavigationLink {
                F2_PageThree()
                    .environmentObject(store)
            } label: {
                Text("Push ke Halaman 3")
                    .foregroundStyle(.blue)
            }
            
            Spacer()
        }
        .navigationTitle("Halaman 2")
        .navigationBarTitleDisplayMode(.inline)
        .padding(.top, 24)
    }
}

// ============================================================
// MARK: - Halaman 3 — push paling dalam
// ============================================================

struct F2_PageThree: View {
    @EnvironmentObject var store: NavStore
    @State private var inputDestination = ""
    
    var body: some View {
        VStack(spacing: 20) {
            Text("Ini halaman paling dalam")
                .font(.subheadline)
                .foregroundStyle(.secondary)
            
            TextField("Kota tujuan", text: $inputDestination)
                .textFieldStyle(.roundedBorder)
                .padding(.horizontal)
            
            Button("Simpan") {
                store.destination = inputDestination
            }
            .buttonStyle(.borderedProminent)
            .disabled(inputDestination.isEmpty)
            
            // Kalau sudah isi keduanya — tampilkan ringkasan
            if !store.username.isEmpty && !store.destination.isEmpty {
                VStack(spacing: 8) {
                    Text("✅ Semua terisi!")
                        .font(.headline)
                    Text("\(store.username) → \(store.destination)")
                        .foregroundStyle(.secondary)
                }
                .padding()
                .background(Color(.secondarySystemBackground))
                .clipShape(RoundedRectangle(cornerRadius: 12))
                .padding(.horizontal)
            }
            
            Spacer()
        }
        .navigationTitle("Halaman 3")
        .navigationBarTitleDisplayMode(.inline)
        .padding(.top, 24)
    }
}

// ============================================================
// MARK: - Sheet View
// ============================================================
// Ini muncul dari bawah — bukan hasil push
// Mirip HealthScreeningModal di proyekmu

struct F2_SheetView: View {
    @EnvironmentObject var store: NavStore
    
    // Untuk tutup sheet dari dalam
    @Environment(\.dismiss) var dismiss
    
    @State private var inputDestination = ""
    
    var body: some View {
        NavigationStack {
            VStack(spacing: 20) {
                Text("Ini adalah Sheet")
                    .font(.subheadline)
                    .foregroundStyle(.secondary)
                
                Text("Perhatikan — tidak ada tombol Back\nTapi bisa di-swipe ke bawah untuk tutup")
                    .font(.caption)
                    .foregroundStyle(.secondary)
                    .multilineTextAlignment(.center)
                
                TextField("Kota tujuan", text: $inputDestination)
                    .textFieldStyle(.roundedBorder)
                    .padding(.horizontal)
                
                Button("Simpan & Tutup Sheet") {
                    store.destination = inputDestination
                    dismiss()  // tutup sheet — mirip dismiss() di HealthScreeningModal
                }
                .buttonStyle(.borderedProminent)
                .disabled(inputDestination.isEmpty)
                
                Spacer()
            }
            .padding(.top, 32)
            .navigationTitle("Isi Destinasi")
            .navigationBarTitleDisplayMode(.inline)
            // Tombol X di kanan atas — opsional
            .toolbar {
                ToolbarItem(placement: .topBarTrailing) {
                    Button("Tutup") { dismiss() }
                }
            }
        }
    }
}

// ============================================================
// MARK: - Preview
// ============================================================

#Preview {
    F2_RootView()
}
