import Foundation

struct APIConstants {
    // Configuration for deployment type
    static let useLocalModel = true // Set to true for local Gemma 3n, false for Gemini cloud
    
    // Gemini Cloud API configuration
    static let geminiAPIKey = ""
    static let geminiBaseURL = "https://generativelanguage.googleapis.com/v1beta"
    
    // Local Gemma 3n configuration (using Ollama)
    static let localModelBaseURL = "http://localhost:11434/v1"
    static let localModelName = "gemma3n:e2b"
    
    // Endpoint paths
    static let modelsEndpoint = "/models"
    static let chatCompletionsEndpoint = "/chat/completions"
    static let geminiModelsEndpoint = "/openai/models"
    static let geminiChatCompletionsEndpoint = "/openai/chat/completions"
}

extension APIConstants {
    static func getModelsURL() -> String {
        if useLocalModel {
            return "\(localModelBaseURL)\(modelsEndpoint)"
        } else {
            return "\(geminiBaseURL)\(geminiModelsEndpoint)"
        }
    }

    static func getChatCompletionsURL() -> String {
        if useLocalModel {
            return "\(localModelBaseURL)\(chatCompletionsEndpoint)"
        } else {
            return "\(geminiBaseURL)\(geminiChatCompletionsEndpoint)"
        }
    }

    static func getAuthorizationHeader() -> String {
        if useLocalModel {
            return "" // Local Ollama doesn't require authentication
        } else {
            return "Bearer \(geminiAPIKey)"
        }
    }
    
    static func requiresAuthentication() -> Bool {
        return !useLocalModel
    }
} 