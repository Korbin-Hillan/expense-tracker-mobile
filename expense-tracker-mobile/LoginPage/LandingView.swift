//
//  LandingView.swift
//  expense-tracker-mobile
//
//  Created by Korbin Hillan on 8/19/25.
//

import SwiftUI
import Auth0

struct LandingView: View {
    @State private var showingAuthSheet = false
    // ⬅️ Make this required so the parent MUST provide it
    var onAuthenticated: () -> Void

    var body: some View {
        ZStack(alignment: .topTrailing) {
            LinearGradient(colors: [Color(hex: "#36D1DC"), Color(hex: "#5B86E5")],
                           startPoint: .topLeading, endPoint: .bottomTrailing)
                .ignoresSafeArea()

            VStack(spacing: 24) {
                Text("Welcome to Expense Tracker")
                    .font(.system(size: 36, weight: .bold))
                    .multilineTextAlignment(.center)
                    .foregroundColor(.white)
                    .shadow(color: .black.opacity(0.3), radius: 2, x: 0, y: 1)
                    .padding(.top, 40)
                    .padding(.horizontal, 24)

                Spacer()

                Image("logo")
                    .resizable()
                    .scaledToFit()
                    .frame(width: 256, height: 256)
                    .accessibilityHidden(true)

                Spacer()

                Button {
                    showingAuthSheet = true
                } label: {
                    Text("Continue")
                        .font(.system(size: 20, weight: .semibold))
                        .frame(maxWidth: .infinity, minHeight: 56)
                        .background(Color.white)
                        .foregroundColor(.black)
                        .clipShape(Capsule())
                        .padding(.horizontal, 24)
                        .padding(.bottom, 24)
                }
            }
        }
        .sheet(isPresented: $showingAuthSheet) {
            AuthOptionsSheet(
                onApple:   { startUniversalLogin() },
                onGoogle:  { startUniversalLogin() },
                onFacebook:{ startUniversalLogin() },
                onEmail:   { startUniversalLogin() }
            )
            .presentationDetents([.medium, .large])
        }
    }

    private func startUniversalLogin() {
        Auth0
            .webAuth()
            .useHTTPS()
            .audience("https://expense-tracker.api") // must match your API Identifier in Auth0
            .scope("openid profile email offline_access")
            .start { result in
                switch result {
                case .success(let credentials):
                    print("Obtained credentials: \(credentials)")
                    saveAfterLogin(credentials)

                    let accessToken = credentials.accessToken
                    let idToken = credentials.idToken
                    print("Access Token: \(accessToken)")
                    print("Id Token: \(idToken)")
                    if !accessToken.isEmpty {
                        Task {
                            try? await postLoginTokenToBackend(accessToken)
                            showingAuthSheet = false
                            onAuthenticated()
                        }
                    } else if !idToken.isEmpty {
                        Task {
                            try? await postLoginTokenToBackend(idToken)
                            showingAuthSheet = false
                            onAuthenticated()
                            
                        }
                    } else {
                        print("No token available to send to backend")
                    }

                case .failure(let error):
                    print("Failed with: \(error)")
                }
            }
    }
}
