import Foundation
import Vapor

class SSEResponseProcessor {
    private var previousChunk = ""
    private var isInCodeBlock = false
    private var needsFormatFix = false
    private let targetFileName: String
    
    init(targetFileName: String) {
        self.targetFileName = targetFileName
        self.needsFormatFix = true
    }
    
    func processChunk(_ chunk: String) -> String {
        defer { previousChunk = chunk }
        
        if needsFormatFix && !isInCodeBlock {
            // check if the previous chunk is ``` and the current chunk is swift
            if previousChunk == "```" && chunk == "swift" {
                isInCodeBlock = true
                needsFormatFix = false
                return "swift:\(targetFileName)"
            }
        }
        
        return chunk
    }
}

func handleWithFormatFix(_ req: Request, fileName: String) async throws -> Response {
    print("🔧 [FORMAT FIX] enable format fix mode, target file: \(fileName)")
    
    let geminiUrl = APIConstants.getChatCompletionsURL()
    let processor = SSEResponseProcessor(targetFileName: fileName)
    
    let clientResponse = try await req.client.post(URI(string: geminiUrl)) { clientReq in
        // set request header and body
        if APIConstants.requiresAuthentication() {
            clientReq.headers.add(name: "Authorization", value: APIConstants.getAuthorizationHeader())
        }
        clientReq.headers.add(name: "Content-Type", value: "application/json")
        
        // forward request body
        if let body = req.body.data {
            clientReq.body = body
        }
    }
    
    // process stream response
    return try await processStreamResponse(clientResponse, processor: processor, req: req)
}

func handleNormal(_ req: Request) async throws -> Response {
    print("🔄 [NORMAL] use normal mode")
    
    let geminiUrl = APIConstants.getChatCompletionsURL()
    
    let clientResponse = try await req.client.post(URI(string: geminiUrl)) { clientReq in
        if APIConstants.requiresAuthentication() {
            clientReq.headers.add(name: "Authorization", value: APIConstants.getAuthorizationHeader())
        }
        clientReq.headers.add(name: "Content-Type", value: "application/json")
        
        if let body = req.body.data {
            clientReq.body = body
        }
    }
    
    // if let body = clientResponse.body {
    //     let bodyString = String(buffer: body)
    //     print("📤 [POST /v1/chat/completions] Response body:")
    //     print(bodyString)
    // }
    
    return Response(
        status: clientResponse.status,
        headers: clientResponse.headers,
        body: .init(buffer: clientResponse.body ?? ByteBuffer())
    )
}

func processStreamResponse(_ clientResponse: ClientResponse, processor: SSEResponseProcessor, req: Request) async throws -> Response {
    guard let body = clientResponse.body else {
        return Response(status: .internalServerError)
    }
    
    let originalData = String(buffer: body)
    let lines = originalData.components(separatedBy: "\n")
    
    var processedBuffer = ByteBuffer()
    
    for line in lines {
        if line.hasPrefix("data: ") {
            let jsonData = String(line.dropFirst(6))
            
            // parse JSON and process content field
            if let data = jsonData.data(using: .utf8),
               let json = try? JSONSerialization.jsonObject(with: data) as? [String: Any],
               let choices = json["choices"] as? [[String: Any]],
               let delta = choices.first?["delta"] as? [String: Any],
               let content = delta["content"] as? String {
                
                let processedContent = processor.processChunk(content)
                
                // reconstruct JSON
                var newDelta = delta
                newDelta["content"] = processedContent
                
                var newChoice = choices.first!
                newChoice["delta"] = newDelta
                
                var newJson = json
                newJson["choices"] = [newChoice]
                
                // serialize back to JSON
                if let newData = try? JSONSerialization.data(withJSONObject: newJson),
                   let newJsonString = String(data: newData, encoding: .utf8) {
                    processedBuffer.writeString("data: \(newJsonString)\n")
                }
            } else {
                processedBuffer.writeString("\(line)\n")
            }
        } else {
            processedBuffer.writeString("\(line)\n")
        }
    }
    
    let processedString = String(buffer: processedBuffer)
    // print("📤 [POST /v1/chat/completions] Processed response body:")
    // print(processedString)
    
    return Response(
        status: clientResponse.status,
        headers: clientResponse.headers,
        body: .init(buffer: processedBuffer)
    )
} 