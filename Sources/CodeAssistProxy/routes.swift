import Fluent
import Vapor

func routes(_ app: Application) throws {
    app.get { req async throws in
        try await req.view.render("index", ["title": "Hello Vapor!"])
    }

    app.get("hello", ":name") { req async throws -> String in
        let name = try req.parameters.require("name")
        return "Hello, \(name)!"
    }

    app.get("v1", "models") { req async throws -> Response in
        let geminiUrl = APIConstants.getModelsURL()
        
        let clientResponse = try await req.client.get(URI(string: geminiUrl)) { clientReq in
            clientReq.headers.add(name: "Authorization", value: APIConstants.getAuthorizationHeader())
            clientReq.headers.add(name: "Content-Type", value: "application/json")
        }
        
        // create new Response object, forward Gemini API response
        let response = Response(
            status: clientResponse.status,
            headers: clientResponse.headers,
            body: .init(buffer: clientResponse.body ?? ByteBuffer())
        )
        
        return response
    }

    app.post("v1", "chat", "completions") { req async throws -> Response in
        let geminiUrl = APIConstants.getChatCompletionsURL()

        // get the original request body
        guard let originalBody = req.body.data else {
            throw Abort(.badRequest, reason: "Missing request body")
        }

        // replace the string if target pattern exists
        let bodyString = String(buffer: originalBody)
        let targetPattern = "Only include documentation comments. No other Swift code."
        let replacement = "Prefer using inline `//` comments to explain each line of code directly within the code block."
        let modifiedBody: ByteBuffer
        if bodyString.contains(targetPattern) {
            let modifiedString = bodyString.replacingOccurrences(of: targetPattern, with: replacement)
            modifiedBody = ByteBuffer(string: modifiedString)
        } else {
            modifiedBody = originalBody
        }
        
        // transfer request to gemini api, and keep the original header
        let clientResponse = try await req.client.post(URI(string: geminiUrl)) { clientReq in
            clientReq.headers.add(name: "Authorization", value: APIConstants.getAuthorizationHeader())
            clientReq.headers.add(name: "Content-Type", value: "application/json")
            clientReq.body = modifiedBody
        }
        
        // create new Response object
        let response = Response(
            status: clientResponse.status,
            headers: clientResponse.headers,
            body: .init(buffer: clientResponse.body ?? ByteBuffer())
        )
        
        return response
    }

    try app.register(collection: TodoController())
}
