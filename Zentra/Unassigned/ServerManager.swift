import Foundation

/// Manages communication with the Zentra server API
class ServerManager: ObservableObject {
    static let shared = ServerManager()
    
    // Server configuration
    var serverURL: String {
        // Cloudflare Tunnel URL
        return "https://api.zentra-apps.com"
    }
    
    private init() {}
    
    /// Fetch server status (online/offline) with ping measurement
    func fetchServerStatus() async throws -> ServerStatus {
        guard let url = URL(string: "\(serverURL)/api/status") else {
            throw ServerError.invalidURL
        }
        
        // Create URLSession configuration with timeout
        let config = URLSessionConfiguration.default
        config.timeoutIntervalForRequest = 5.0
        config.timeoutIntervalForResource = 10.0
        config.waitsForConnectivity = false
        let session = URLSession(configuration: config)
        
        do {
            // Measure client-side ping time
            let startTime = Date()
            let (data, response) = try await session.data(from: url)
            let clientPingTime = Date().timeIntervalSince(startTime) * 1000  // Convert to ms
            
            guard let httpResponse = response as? HTTPURLResponse else {
                throw ServerError.invalidResponse
            }
            
            guard httpResponse.statusCode == 200 else {
                throw ServerError.httpError(httpResponse.statusCode)
            }
            
            let decoder = JSONDecoder()
            decoder.dateDecodingStrategy = .iso8601
            
            var serverStatus = try decoder.decode(ServerStatus.self, from: data)
            
            // Use client-side ping if server didn't provide it, or combine both
            // For now, we'll use client-side ping as it's more accurate for round-trip time
            if let serverPing = serverStatus.ping_ms {
                // Server provided ping, use client-side round-trip time (more accurate)
                // We could also average them, but round-trip is more meaningful
                return ServerStatus(
                    online: serverStatus.online,
                    timestamp: serverStatus.timestamp,
                    message: serverStatus.message,
                    ping_ms: round(clientPingTime * 100) / 100  // Round to 2 decimal places
                )
            } else {
                // Server didn't provide ping, use client-side measurement
                return ServerStatus(
                    online: serverStatus.online,
                    timestamp: serverStatus.timestamp,
                    message: serverStatus.message,
                    ping_ms: round(clientPingTime * 100) / 100
                )
            }
        } catch let error as ServerError {
            throw error
        } catch {
            // Network errors (connection refused, timeout, etc.) should be treated as offline
            throw ServerError.invalidResponse
        }
    }
    
    /// Fetch detailed server statistics
    func fetchServerStats() async throws -> ServerStats {
        guard let url = URL(string: "\(serverURL)/api/stats") else {
            throw ServerError.invalidURL
        }
        
        // Create URLSession configuration with timeout
        let config = URLSessionConfiguration.default
        config.timeoutIntervalForRequest = 5.0
        config.timeoutIntervalForResource = 10.0
        config.waitsForConnectivity = false
        let session = URLSession(configuration: config)
        
        do {
            let (data, response) = try await session.data(from: url)
            
            guard let httpResponse = response as? HTTPURLResponse else {
                throw ServerError.invalidResponse
            }
            
            guard httpResponse.statusCode == 200 else {
                throw ServerError.httpError(httpResponse.statusCode)
            }
            
            let decoder = JSONDecoder()
            decoder.dateDecodingStrategy = .iso8601
            
            return try decoder.decode(ServerStats.self, from: data)
        } catch {
            throw ServerError.invalidResponse
        }
    }
    
    /// Authenticate user with server
    func login(username: String, password: String) async throws -> AuthResponse {
        guard let url = URL(string: "\(serverURL)/api/auth/login") else {
            throw ServerError.invalidURL
        }
        
        let config = URLSessionConfiguration.default
        config.timeoutIntervalForRequest = 5.0
        config.timeoutIntervalForResource = 10.0
        config.waitsForConnectivity = false
        let session = URLSession(configuration: config)
        
        var request = URLRequest(url: url)
        request.httpMethod = "POST"
        request.setValue("application/json", forHTTPHeaderField: "Content-Type")
        
        let body = ["username": username, "password": password]
        request.httpBody = try JSONSerialization.data(withJSONObject: body)
        
        do {
            let (data, response) = try await session.data(for: request)
            
            guard let httpResponse = response as? HTTPURLResponse else {
                throw ServerError.invalidResponse
            }
            
            let decoder = JSONDecoder()
            
            if httpResponse.statusCode == 200 {
                return try decoder.decode(AuthResponse.self, from: data)
            } else if httpResponse.statusCode == 401 {
                let errorResponse = try decoder.decode(AuthErrorResponse.self, from: data)
                throw ServerError.authenticationError(errorResponse.message)
            } else {
                throw ServerError.httpError(httpResponse.statusCode)
            }
        } catch let error as ServerError {
            throw error
        } catch {
            throw ServerError.invalidResponse
        }
    }
    
    /// Logout user from server
    func logout(token: String) async throws {
        guard let url = URL(string: "\(serverURL)/api/auth/logout") else {
            throw ServerError.invalidURL
        }
        
        let config = URLSessionConfiguration.default
        config.timeoutIntervalForRequest = 5.0
        config.timeoutIntervalForResource = 10.0
        config.waitsForConnectivity = false
        let session = URLSession(configuration: config)
        
        var request = URLRequest(url: url)
        request.httpMethod = "POST"
        request.setValue("Bearer \(token)", forHTTPHeaderField: "Authorization")
        
        do {
            let (_, response) = try await session.data(for: request)
            guard let httpResponse = response as? HTTPURLResponse else {
                throw ServerError.invalidResponse
            }
            guard httpResponse.statusCode == 200 else {
                throw ServerError.httpError(httpResponse.statusCode)
            }
        } catch let error as ServerError {
            throw error
        } catch {
            throw ServerError.invalidResponse
        }
    }
    
    /// Verify authentication token
    func verifyToken(_ token: String) async throws -> TokenVerification {
        guard let url = URL(string: "\(serverURL)/api/auth/verify") else {
            throw ServerError.invalidURL
        }
        
        let config = URLSessionConfiguration.default
        config.timeoutIntervalForRequest = 5.0
        config.timeoutIntervalForResource = 10.0
        config.waitsForConnectivity = false
        let session = URLSession(configuration: config)
        
        var request = URLRequest(url: url)
        request.httpMethod = "POST"
        request.setValue("Bearer \(token)", forHTTPHeaderField: "Authorization")
        
        do {
            let (data, response) = try await session.data(for: request)
            guard let httpResponse = response as? HTTPURLResponse else {
                throw ServerError.invalidResponse
            }
            
            let decoder = JSONDecoder()
            
            if httpResponse.statusCode == 200 {
                return try decoder.decode(TokenVerification.self, from: data)
            } else {
                return try decoder.decode(TokenVerification.self, from: data)
            }
        } catch {
            throw ServerError.invalidResponse
        }
    }
    
    /// Send device activation to server (which forwards to Discord)
    func sendDeviceActivation(
        deviceUUID: String,
        deviceName: String,
        deviceModel: String,
        iosVersion: String,
        appVersion: String,
        buildNumber: String
    ) async throws -> ActivationResponse {
        guard let url = URL(string: "\(serverURL)/api/activation") else {
            throw ServerError.invalidURL
        }
        
        let config = URLSessionConfiguration.default
        config.timeoutIntervalForRequest = 10.0
        config.timeoutIntervalForResource = 15.0
        config.waitsForConnectivity = false
        let session = URLSession(configuration: config)
        
        var request = URLRequest(url: url)
        request.httpMethod = "POST"
        request.setValue("application/json", forHTTPHeaderField: "Content-Type")
        
        let body: [String: Any] = [
            "device_uuid": deviceUUID,
            "device_name": deviceName,
            "device_model": deviceModel,
            "ios_version": iosVersion,
            "app_version": appVersion,
            "build_number": buildNumber
        ]
        
        request.httpBody = try JSONSerialization.data(withJSONObject: body)
        
        do {
            let (data, response) = try await session.data(for: request)
            
            guard let httpResponse = response as? HTTPURLResponse else {
                throw ServerError.invalidResponse
            }
            
            let decoder = JSONDecoder()
            
            if httpResponse.statusCode == 200 {
                return try decoder.decode(ActivationResponse.self, from: data)
            } else {
                let errorResponse = try decoder.decode(ActivationResponse.self, from: data)
                throw ServerError.httpError(httpResponse.statusCode)
            }
        } catch let error as ServerError {
            throw error
        } catch {
            throw ServerError.invalidResponse
        }
    }
    
    /// Register new user account
    func register(
        username: String,
        email: String,
        password: String,
        deviceUUID: String,
        deviceName: String,
        deviceModel: String,
        iosVersion: String,
        appVersion: String,
        buildNumber: String
    ) async throws -> RegisterResponse {
        guard let url = URL(string: "\(serverURL)/api/auth/register") else {
            throw ServerError.invalidURL
        }
        
        let config = URLSessionConfiguration.default
        config.timeoutIntervalForRequest = 15.0
        config.timeoutIntervalForResource = 20.0
        config.waitsForConnectivity = false
        let session = URLSession(configuration: config)
        
        var request = URLRequest(url: url)
        request.httpMethod = "POST"
        request.setValue("application/json", forHTTPHeaderField: "Content-Type")
        
        let body: [String: Any] = [
            "username": username,
            "email": email,
            "password": password,
            "device_uuid": deviceUUID,
            "device_name": deviceName,
            "device_model": deviceModel,
            "ios_version": iosVersion,
            "app_version": appVersion,
            "build_number": buildNumber
        ]
        
        request.httpBody = try JSONSerialization.data(withJSONObject: body)
        
        do {
            let (data, response) = try await session.data(for: request)
            
            guard let httpResponse = response as? HTTPURLResponse else {
                throw ServerError.invalidResponse
            }
            
            let decoder = JSONDecoder()
            
            if httpResponse.statusCode == 200 || httpResponse.statusCode == 201 {
                return try decoder.decode(RegisterResponse.self, from: data)
            } else if httpResponse.statusCode == 400 || httpResponse.statusCode == 409 {
                // Bad request or conflict (email already exists)
                return try decoder.decode(RegisterResponse.self, from: data)
            } else {
                throw ServerError.httpError(httpResponse.statusCode)
            }
        } catch let error as ServerError {
            throw error
        } catch {
            throw ServerError.invalidResponse
        }
    }
    
    /// Check if device has reached registration limit
    func checkRegistrationLimit(deviceUUID: String) async throws -> RegistrationLimitResponse {
        guard let url = URL(string: "\(serverURL)/api/auth/check-limit") else {
            throw ServerError.invalidURL
        }
        
        let config = URLSessionConfiguration.default
        config.timeoutIntervalForRequest = 5.0
        config.timeoutIntervalForResource = 10.0
        config.waitsForConnectivity = false
        let session = URLSession(configuration: config)
        
        var request = URLRequest(url: url)
        request.httpMethod = "POST"
        request.setValue("application/json", forHTTPHeaderField: "Content-Type")
        
        let body = ["device_uuid": deviceUUID]
        request.httpBody = try JSONSerialization.data(withJSONObject: body)
        
        do {
            let (data, response) = try await session.data(for: request)
            
            guard let httpResponse = response as? HTTPURLResponse else {
                throw ServerError.invalidResponse
            }
            
            let decoder = JSONDecoder()
            
            if httpResponse.statusCode == 200 {
                return try decoder.decode(RegistrationLimitResponse.self, from: data)
            } else {
                throw ServerError.httpError(httpResponse.statusCode)
            }
        } catch let error as ServerError {
            throw error
        } catch {
            throw ServerError.invalidResponse
        }
    }
    
    /// Get all accounts for a specific device UUID
    func getAccountsByUUID(deviceUUID: String) async throws -> AccountsByUUIDResponse {
        guard let url = URL(string: "\(serverURL)/api/accounts/by-uuid?uuid=\(deviceUUID.addingPercentEncoding(withAllowedCharacters: .urlQueryAllowed) ?? "")") else {
            throw ServerError.invalidURL
        }
        
        let config = URLSessionConfiguration.default
        config.timeoutIntervalForRequest = 5.0
        config.timeoutIntervalForResource = 10.0
        config.waitsForConnectivity = false
        let session = URLSession(configuration: config)
        
        var request = URLRequest(url: url)
        request.httpMethod = "GET"
        
        do {
            let (data, response) = try await session.data(for: request)
            
            guard let httpResponse = response as? HTTPURLResponse else {
                throw ServerError.invalidResponse
            }
            
            let decoder = JSONDecoder()
            
            if httpResponse.statusCode == 200 {
                return try decoder.decode(AccountsByUUIDResponse.self, from: data)
            } else {
                throw ServerError.httpError(httpResponse.statusCode)
            }
        } catch let error as ServerError {
            throw error
        } catch {
            throw ServerError.invalidResponse
        }
    }
    
    /// Get user number for a specific device UUID
    func getUserNumber(deviceUUID: String) async throws -> UserNumberResponse {
        guard let url = URL(string: "\(serverURL)/api/user-number?uuid=\(deviceUUID.addingPercentEncoding(withAllowedCharacters: .urlQueryAllowed) ?? "")") else {
            throw ServerError.invalidURL
        }
        
        let config = URLSessionConfiguration.default
        config.timeoutIntervalForRequest = 5.0
        config.timeoutIntervalForResource = 10.0
        config.waitsForConnectivity = false
        let session = URLSession(configuration: config)
        
        var request = URLRequest(url: url)
        request.httpMethod = "GET"
        
        do {
            let (data, response) = try await session.data(for: request)
            
            guard let httpResponse = response as? HTTPURLResponse else {
                throw ServerError.invalidResponse
            }
            
            let decoder = JSONDecoder()
            
            if httpResponse.statusCode == 200 {
                return try decoder.decode(UserNumberResponse.self, from: data)
            } else {
                throw ServerError.httpError(httpResponse.statusCode)
            }
        } catch let error as ServerError {
            throw error
        } catch {
            throw ServerError.invalidResponse
        }
    }
}

// MARK: - Data Models

struct ServerStatus: Codable {
    let online: Bool
    let timestamp: String
    let message: String
    let ping_ms: Double?  // Ping in milliseconds (optional for backward compatibility)
}

struct ActivationResponse: Codable {
    let success: Bool
    let message: String
    let device_uuid: String?
}

struct RegisterResponse: Codable {
    let success: Bool
    let token: String?
    let message: String?
    let device_uuid: String?
}

struct RegistrationLimitResponse: Codable {
    let success: Bool
    let limit_reached: Bool
    let account_count: Int
    let remaining_registrations: Int
    let max_accounts: Int
}

struct AccountsByUUIDResponse: Codable {
    let success: Bool
    let device_uuid: String
    let account_count: Int
    let accounts: [AccountInfo]
    let message: String?
}

struct AccountInfo: Codable {
    let username: String
    let email: String
    let device_uuid: String
    let created_at: String
}

struct UserNumberResponse: Codable {
    let success: Bool
    let device_uuid: String
    let user_number: Int?
    let message: String?
}

struct ServerStats: Codable {
    let online: Bool
    let onlinePlayers: Int
    let maxPlayers: Int
    let uptime: String
    let avgResponse: Int
    let peakPlayers: Int
    let peakTime: String
    let cpuUsage: Double
    let memoryUsage: Double
    let memoryTotal: Double
    let networkTraffic: Double
    let diskUsage: Double
    let diskTotal: Double
    let timestamp: String
}

// MARK: - Error Types

enum ServerError: LocalizedError {
    case invalidURL
    case invalidResponse
    case httpError(Int)
    case decodingError
    case authenticationError(String)
    
    var errorDescription: String? {
        switch self {
        case .invalidURL:
            return "Invalid server URL"
        case .invalidResponse:
            return "Invalid server response"
        case .httpError(let code):
            return "HTTP error: \(code)"
        case .decodingError:
            return "Failed to decode server response"
        case .authenticationError(let message):
            return message
        }
    }
}

// MARK: - Authentication Models

struct AuthResponse: Codable {
    let success: Bool
    let token: String?
    let username: String?
    let message: String
}

struct AuthErrorResponse: Codable {
    let success: Bool
    let message: String
}

struct TokenVerification: Codable {
    let success: Bool
    let username: String?
    let valid: Bool
    let message: String?
}

