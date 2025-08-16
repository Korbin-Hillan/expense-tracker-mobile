//
//  ContentView.swift
//  expense-tracker-mobile
//
//  Created by Korbin Hillan on 7/13/25.
//

import SwiftUI

enum Screen {
    case signIn
    case signUp
    case home
}

struct ContentView: View {
    @State private var screen: Screen = .signIn

    @ViewBuilder
    private var currentScreen: some View {
        switch screen {
        case .signIn:
            SignInView(
                onSignIn: { screen = .home },
                onTapSignUp: { screen = .signUp }
            )
        case .signUp:
            SignUpView(
                onFinished: { screen = .home },
                onCancel: { screen = .signIn }
            )
        case .home:
            HomeView(onSignOut: { screen = .signIn })
        }

    }
    var body: some View {
        currentScreen
    }
}

struct SignInView: View {
    var onSignIn: () -> Void = {}
    var onTapSignUp: () -> Void = {}
    
    @State private var email = ""
    @State private var password = ""
    
    var body: some View {
        ZStack {
            LinearGradient(
                gradient: Gradient(stops: [
                    .init(color: Color(hex: "#36D1DC"), location: 0.0),
                    .init(color: Color(hex: "#2AB8E6"), location: 0.5),
                    .init(color: Color(hex: "#5B86E5"), location: 1.0)
                ]),
                startPoint: UnitPoint(x: -0.25, y: 1.0),
                endPoint: UnitPoint(x: -0.25, y: 0)
            )
            .ignoresSafeArea()
            
            VStack(spacing: 16) {
                Text("Welcome to Expense Tracker")
                    .foregroundColor(.white)
                    .font(.largeTitle.bold())
                    .multilineTextAlignment(.center)
                
                Spacer().frame(height: 10)

                TextField(text: $email, prompt: Text("Email").foregroundColor(Color(.secondaryLabel))
                ) {}
                .foregroundStyle(Color(.label))
                .textInputAutocapitalization(.never)
                .disableAutocorrection(true)
                .font(.system(size: 18))
                .padding(.horizontal, 16)
                .frame(height: 54)
                .background(Color(.secondarySystemBackground))
                .cornerRadius(10)

                SecureField("", text: $password, prompt: Text("Password")
                        .foregroundColor(Color(.secondaryLabel)))
                .foregroundStyle(Color(.label))
                .textInputAutocapitalization(.never)
                .disableAutocorrection(true)
                .font(.system(size: 18))
                .padding(.horizontal, 16)
                .frame(height: 54)
                .background(Color(.secondarySystemBackground))
                .cornerRadius(10)
                
                Button(action: {
                    // Apple sign in
                    onSignIn()
                }) {
                    HStack {
                        Text("Sign In")
                            .font(.system(size: 24, weight: .semibold))
                    }
                    .frame(width: 354, height: 54)
                    .background(Color(hex: "#E0D500"))
                    .foregroundColor(.black)
                    .cornerRadius(.infinity)
                }
                
                HStack {
                    Divider()
                        .frame(width: 100, height: 1)
                        .background(Color.white)

                    Text("OR")
                        .foregroundColor(.white)
                        .padding(.horizontal, 8)
                        .font(.system(size: 18))

                    Divider()
                        .frame(width: 100, height: 1)
                        .background(Color.white)
                }
                Button(action: {
                    // Apple sign in
                }) {
                    HStack {
                        Image("facebook")
                            .renderingMode(.original)
                            .resizable()
                            .scaledToFit()
                            .frame(width: 40, height: 40)

                        Text("Sign In with Facebook")
                            .font(.system(size: 24, weight: .semibold))
                    }
                    .frame(width: 354, height: 61)
                    .background(.blue)
                    .foregroundColor(.white)
                    .cornerRadius(16)
                }
                Button(action: {
                    // Apple sign in
                }) {
                    HStack {
                        Image("google")
                            .renderingMode(.original)
                            .resizable()
                            .scaledToFit()
                            .frame(width: 40, height: 40)

                        Text("Sign In with Google")
                            .font(.system(size: 24, weight: .semibold))
                    }
                    .frame(width: 354, height: 61)
                    .background(.white)
                    .foregroundColor(.black)
                    .cornerRadius(16)
                }
                Button(action: {
                    // Apple sign in
                }) {
                    HStack {
                        Image(systemName: "apple.logo")
                            .font(.system(size: 40))

                        Text("Sign In with Apple")
                            .font(.system(size: 24, weight: .semibold))
                    }
                    .frame(width: 354, height: 61)
                    .background(.black)
                    .foregroundColor(.white)
                    .cornerRadius(16)
                }
                Spacer()
                    .frame(height: 10)
                VStack(spacing: 4) {
                    Text("Don’t have an account yet?")
                        
                    Button(action: {
                        onTapSignUp()
                    }) {
                        Text("Sign Up")
                            .font(.system(size: 18, weight: .bold))
                            .foregroundColor(.white)
                            .underline()
                    }
                }
            }
            .frame(width: 354)
            .padding()
        }
    }
}

struct SignUpView: View {
    var onFinished: () -> Void = {}
    var onCancel: () -> Void = {}
    var body: some View {
        VStack(spacing: 20) {
            Text("Sign Up").font(.largeTitle.bold())
            Button("Finish Sign Up") { onFinished() }
            Button("Cancel") { onCancel() }
        }
        .padding()
    }
}

struct HomeView: View {
    var onSignOut: () -> Void = {}
    var body: some View {
        VStack(spacing: 20) {
            Text("Home").font(.largeTitle.bold())
            Button("Sign Out") { onSignOut() }
        }
        .padding()
    }
}


extension Color {
    init(hex: String) {
        let hex = hex.trimmingCharacters(in: CharacterSet.alphanumerics.inverted)
        var int: UInt64 = 0
        Scanner(string: hex).scanHexInt64(&int)
        
        let r, g, b, a: UInt64
        switch hex.count {
        case 3: // RGB (12-bit)
            (r, g, b, a) = ((int >> 8) * 17, (int >> 4 & 0xF) * 17, (int & 0xF) * 17, 255)
        case 6: // RGB (24-bit)
            (r, g, b, a) = (int >> 16, int >> 8 & 0xFF, int & 0xFF, 255)
        case 8: // ARGB (32-bit)
            (a, r, g, b) = (int >> 24, int >> 16 & 0xFF, int >> 8 & 0xFF, int & 0xFF)
        default:
            (r, g, b, a) = (0, 0, 0, 255)
        }
        
        self.init(
            .sRGB,
            red: Double(r) / 255,
            green: Double(g) / 255,
            blue: Double(b) / 255,
            opacity: Double(a) / 255
        )
    }
}


#Preview {
    ContentView()
}
