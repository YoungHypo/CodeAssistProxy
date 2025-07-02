import Foundation

struct APIConstants {
    // TODO: vapor can't directly read env variable from .env
    static let geminiAPIKey = ""
    static let geminiBaseURL = "https://generativelanguage.googleapis.com/v1beta"
    
    static let modelsEndpoint = "/openai/models"
    static let chatCompletionsEndpoint = "/openai/chat/completions"
}

// MARK: - Helper Methods
extension APIConstants {
    static func getModelsURL() -> String {
        return "\(geminiBaseURL)\(modelsEndpoint)"
    }

    static func getChatCompletionsURL() -> String {
        return "\(geminiBaseURL)\(chatCompletionsEndpoint)"
    }

    static func getAuthorizationHeader() -> String {
        return "Bearer \(geminiAPIKey)"
    }
} 