import Foundation

/// Manages communication with the Zentra server API
class ServerManager: ObservableObject {
    static let shared = ServerManager()
    
    // Server configuration
    var serverURL: String {
        // For simulator: use localhost
        // For physical device: use your Mac's local IP (e.g., "http://192.168.0.234:8080")
        #if targetEnvironment(simulator)
        return "http://localhost:8080"
        #else
        // Change this to your Mac's local IP address for physical device testing
        return "http://192.168.0.234:8080"
        #endif
    }
    
    private init() {}
    
    /// Fetch server status (online/offline)
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
            let (data, response) = try await session.data(from: url)
            
            guard let httpResponse = response as? HTTPURLResponse else {
                throw ServerError.invalidResponse
            }
            
            guard httpResponse.statusCode == 200 else {
                throw ServerError.httpError(httpResponse.statusCode)
            }
            
            let decoder = JSONDecoder()
            decoder.dateDecodingStrategy = .iso8601
            
            return try decoder.decode(ServerStatus.self, from: data)
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
}

// MARK: - Data Models

struct ServerStatus: Codable {
    let online: Bool
    let timestamp: String
    let message: String
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

