//
//  ContentView.swift
//  expense-tracker-mobile
//
//  Created by Korbin Hillan on 7/13/25.
//

import SwiftUI

private enum Screen {
    case signIn
    case home
}

struct ContentView: View {
    @State private var screen: Screen = .signIn

    var body: some View {
        switch screen {
        case .signIn:
            LandingView(onAuthenticated: { screen = .home })
        case .home:
            AppView()
        }
    }
}
#Preview {
    ContentView()
}
