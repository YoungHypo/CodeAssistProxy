import Foundation

struct RequestAnalyzer {
    let requestBody: String
    
    var hasNoCodeSelected: Bool {
        return requestBody.contains("The user has no code selected")
    }
    
    var currentFileName: String? {
        let pattern = "The user is curently inside this file: ([A-Za-z0-9_]+\\.swift)"
        let regex = try? NSRegularExpression(pattern: pattern)
        let range = NSRange(requestBody.startIndex..., in: requestBody)
        
        if let match = regex?.firstMatch(in: requestBody, range: range) {
            let matchRange = match.range(at: 1)
            if let swiftRange = Range(matchRange, in: requestBody) {
                return String(requestBody[swiftRange])
            }
        }
        return nil
    }
} 