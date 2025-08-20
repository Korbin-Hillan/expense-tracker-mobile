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

private enum Screen {
    case Home
    case Stats
    case Bills
    case Recent
    case Profile
}

struct UserProfileResponse: Decodable {
    let user: UserProfile
}

struct AppView: View {
    @State private var screen: Screen = .Home
    var onSignOut: () -> Void = {}
    var body: some View {
        switch screen {
        case .Home:
            HomeView()
        case .Stats:
            StatsView()
        case .Bills:
            BillsView()
        case .Recent:
            RecentView()
        case .Profile:
            ProfileView()
        }
        HomeNavBar(screen: $screen)
    }
}

struct HomeView: View {
    var body: some View {
        Text("HomeView")
    }
}

struct ProfileView: View {
    var body: some View {
        Text("Profile")
    }
}

struct StatsView: View {
    var body: some View {
        Text("StatsView")
    }
}

struct BillsView: View {
    var body: some View {
        Text("BillsView")
    }
}

struct RecentView: View {
    var body: some View {
        Text("RecentView")
    }
}

private struct NavTile: View {
    let systemName: String
    let title: String
    let action: () -> Void
    
    var body: some View {
        Button(action: action) {
            VStack(spacing: 6) {
                Image(systemName: systemName)
                    .resizable()
                    .scaledToFit()
                    .frame(height: 22)
                Text(title)
                    .font(.caption)
                    .lineLimit(1)
                    .minimumScaleFactor(0.8)
            }
            .frame(width: 45, height: 45)
            .padding(6)
            .background(Color.blue)
            .cornerRadius(15)
            .foregroundStyle(.white)
            .contentShape(RoundedRectangle(cornerRadius: 15))
        }
        .buttonStyle(.plain)
    }
}

struct HomeNavBar: View {
    @Binding fileprivate var screen: Screen
    @State private var profile: UserProfile?
    @State private var isLoading = true
    @State private var errorMessage: String?
    
    var body: some View {
        ZStack(alignment: .topTrailing) {
            LinearGradient(colors: [Color(hex: "#36D1DC"), Color(hex: "#5B86E5")],
                           startPoint: .topLeading, endPoint: .bottomTrailing)
            .ignoresSafeArea()
        }
            
            VStack(spacing: 20) {
                HStack(spacing: 12) {
                    NavTile(systemName: "house", title: "Home") {
                        screen = .Home
                    }
                    NavTile(systemName: "chart.bar", title: "Stats") {
                        screen = .Stats
                    }
                    NavTile(systemName: "creditcard", title: "Bills") {
                        screen = .Bills
                    }
                    NavTile(systemName: "clock", title: "Recent") {
                        screen = .Recent
                    }
                    NavTile(systemName: "person.crop.circle", title: "Profile") {
                        screen = .Profile
                    }
                }
        }
            .task { await loadProfile() }
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

#Preview {
    AppView()
}
