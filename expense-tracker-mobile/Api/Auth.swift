// Updated Auth.swift - Store and use app JWT instead of Auth0 JWT

import Foundation
import Auth0
import JWTDecode

let manager = CredentialsManager(authentication: Auth0.authentication())

struct LoginResponse: Codable {
    let token: String // This is your app JWT
    let user: UserInfo
}

struct UserInfo: Codable {
    let id: String
    let email: String?
    let name: String?
}

// Store the app JWT instead of Auth0 credentials
private var appJWTToken: String?

func saveAfterLogin(_ credentials: Credentials) {
    _ = manager.store(credentials: credentials) // Keep Auth0 credentials for logout
}

func saveAppJWT(_ token: String) {
    appJWTToken = token
    // Optionally save to Keychain for persistence
}

func withAppJWT(_ use: @escaping (String) -> Void) {
    guard let token = appJWTToken else {
        print("No app JWT available")
        return
    }
    use(token)
}

func postLoginTokenToBackend(_ auth0Token: String) async throws {
    guard let url = URL(string: "http://192.168.0.251:3000/api/auth/session") else {
        throw URLError(.badURL)
    }
    var req = URLRequest(url: url)
    req.httpMethod = "POST"
    req.addValue("application/json", forHTTPHeaderField: "Content-Type")
    req.addValue("Bearer \(auth0Token)", forHTTPHeaderField: "Authorization") // Send Auth0 JWT
    req.httpBody = try JSONEncoder().encode(["client": "ios"])

    print("➡️ POST \(url.absoluteString)")
    do {
        let (data, resp) = try await URLSession.shared.data(for: req)
        guard let http = resp as? HTTPURLResponse else {
            print("❗️Non-HTTP response")
            throw URLError(.badServerResponse)
        }
        let body = String(data: data, encoding: .utf8) ?? "<non-utf8>"
        print("⬅️ Status: \(http.statusCode)")
        print("⬅️ Body: \(body)")
        
        if !(200...299).contains(http.statusCode) {
            throw URLError(.badServerResponse)
        }
        
        let response = try JSONDecoder().decode(LoginResponse.self, from: data)
        saveAppJWT(response.token) // Save the app JWT for future requests
        print("✅ App JWT saved: \(response.token)")
    } catch {
        print("❌ Network error: \(error)")
        throw error
    }
}

func get<T: Decodable>(_ path: String, as type: T.Type = T.self) async throws -> T {
    try await withCheckedThrowingContinuation { cont in
        withAppJWT { token in // Use app JWT instead of Auth0 JWT
            Task {
                do {
                    guard let url = URL(string: "http://192.168.0.251:3000\(path)") else {
                        throw URLError(.badURL)
                    }
                    var req = URLRequest(url: url)
                    req.httpMethod = "GET"
                    req.addValue("application/json", forHTTPHeaderField: "Accept")
                    req.addValue("Bearer \(token)", forHTTPHeaderField: "Authorization") // Use app JWT

                    print("🔗 GET \(url.absoluteString) with app JWT")
                    let (data, resp) = try await URLSession.shared.data(for: req)
                    guard let http = resp as? HTTPURLResponse, (200...299).contains(http.statusCode) else {
                        print("❌ HTTP Error: \(resp)")
                        throw URLError(.badServerResponse)
                    }
                    let decoded = try JSONDecoder().decode(T.self, from: data)
                    cont.resume(returning: decoded)
                } catch {
                    print("❌ Request failed: \(error)")
                    cont.resume(throwing: error)
                }
            }
        }
    }
}
