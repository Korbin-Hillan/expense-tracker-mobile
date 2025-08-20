//
//  HomeView.swift
//  expense-tracker-mobile
//
//  Created by Korbin Hillan on 8/19/25.
//

import SwiftUI
import Auth0

struct UserProfile: Decodable {
    let id: String
    let email: String?
    let name: String?
    let provider: String?
}

struct UserProfileResponse: Decodable {
    let user: UserProfile
}

struct HomeView: View {
    var onSignOut: () -> Void = {}
    @State private var profile: UserProfile?
    @State private var isLoading = true
    @State private var errorMessage: String?
    var body: some View {
        VStack(spacing: 20) {
            Text("Home").font(.largeTitle.bold())
            if isLoading {
                ProgressView("Loading profile…")
            } else if let errorMessage {
                Text(errorMessage).foregroundColor(.red)
            } else if let p = profile {
                VStack(spacing: 6) {
                    Text(p.name ?? "Guest").font(.title2.weight(.semibold))
                    Text(p.email ?? "No email").foregroundStyle(.secondary)
                    Text("ID: \(p.id)").font(.footnote.monospaced())
                }
            }
            Button("Sign Out") {
                onSignOut()
                Auth0
                    .webAuth()
                    .useHTTPS() // Use a Universal Link logout URL on iOS 17.4+ / macOS 14.4+
                    .clearSession { result in
                        switch result {
                        case .success:
                            print("Logged out")
                        case .failure(let error):
                            print("Failed with: \(error)")
                        }
                    }
            }
        }
        .padding()
        .task {
            await loadProfile()
        }
    }
    
    @MainActor
    private func loadProfile() async {
        do {
            isLoading = true
            errorMessage = nil
            let response: UserProfileResponse = try await get("/api/user/me")
            profile = response.user
        } catch {
            errorMessage = "Failed to load profile: \(error.localizedDescription)"
        }
        isLoading = false
    }
}
