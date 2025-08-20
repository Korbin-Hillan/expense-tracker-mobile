//
//  AuthOptionsSheet.swift
//  expense-tracker-mobile
//
//  Created by Korbin Hillan on 8/19/25.
//

import SwiftUI

struct AuthOptionsSheet: View {
    var onApple: () -> Void
    var onGoogle: () -> Void
    var onFacebook: () -> Void
    var onEmail: () -> Void

    var body: some View {
        VStack(spacing: 16) {
            Capsule().frame(width: 40, height: 5).foregroundColor(.secondary).padding(.top, 8)
            Text("Sign in or Create an Account").font(.headline).padding(.top, 8)

            ProviderButton(
                title: "Continue with Apple",
                icon: Image(systemName: "apple.logo"),
                foreground: .white,
                background: .black,
                border: .black.opacity(0.1),
                action: onApple
            )
            .frame(height: 52)
            .clipShape(RoundedRectangle(cornerRadius: 12))

            ProviderButton(
                title: "Continue with Google",
                icon: Image("google"),
                foreground: .black,
                background: .white,
                border: .black.opacity(0.1),
                action: onGoogle
            )

            ProviderButton(
                title: "Continue with Facebook",
                icon: Image("facebook"),
                foreground: .white,
                background: .blue,
                action: onFacebook
            )

            HStack {
                Rectangle().frame(height: 1).foregroundColor(.secondary.opacity(0.3))
                Text("or").foregroundColor(.secondary)
                Rectangle().frame(height: 1).foregroundColor(.secondary.opacity(0.3))
            }
            .padding(.vertical, 8)

            ProviderButton(
                title: "Continue with Email",
                icon: Image(systemName: "envelope.fill"),
                foreground: .white,
                background: .accentColor,
                action: onEmail
            )

            Text("By continuing, you agree to our Terms and Privacy Policy.")
                .font(.footnote)
                .foregroundColor(.secondary)
                .multilineTextAlignment(.center)
                .padding(.horizontal, 24)
                .padding(.top, 4)

            Spacer(minLength: 8)
        }
        .padding(.horizontal, 20)
        .padding(.bottom, 16)
    }
}

struct ProviderButton: View {
    let title: String
    let icon: Image?
    let foreground: Color
    let background: Color
    var border: Color? = nil
    let action: () -> Void

    var body: some View {
        Button(action: action) {
            HStack(spacing: 12) {
                if let icon {
                    icon
                        .resizable()
                        .scaledToFit()
                        .frame(width: 24, height: 24)
                        // If you want the icon to match text color, remove this:
                        //.foregroundColor(.white)
                }
                Text(title).font(.system(size: 17, weight: .semibold))
                Spacer()
            }
            .padding(.horizontal, 16)
            .frame(height: 52)
            .background(background)
            .foregroundColor(foreground)
            .overlay {
                if let border {
                    RoundedRectangle(cornerRadius: 12)
                        .stroke(border, lineWidth: 1)
                }
            }
            .clipShape(RoundedRectangle(cornerRadius: 12))
        }
    }
}
