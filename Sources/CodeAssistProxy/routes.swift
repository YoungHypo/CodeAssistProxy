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
            // Only add authorization header if required (for cloud service)
            if APIConstants.requiresAuthentication() {
                clientReq.headers.add(name: "Authorization", value: APIConstants.getAuthorizationHeader())
            }
            clientReq.headers.add(name: "Content-Type", value: "application/json")
        }
        
        // Print response body to terminal
        // if let body = clientResponse.body {
        //     let bodyString = String(buffer: body)
        //     print("📤 [GET /v1/models] Response body:")
        //     print(bodyString)
        // }
        
        let response = Response(
            status: clientResponse.status,
            headers: clientResponse.headers,
            body: .init(buffer: clientResponse.body ?? ByteBuffer())
        )
        
        return response
    }

    app.post("v1", "chat", "completions") { req async throws -> Response in
        guard let body = req.body.data else {
            throw Abort(.badRequest)
        }
        let requestBodyString = String(buffer: body)
        
        // print("💬 [POST /v1/chat/completions] Client request body:")
        // print(requestBodyString)
        
        let analyzer = RequestAnalyzer(requestBody: requestBodyString)
        
        // check if format fix is needed
        let needsFormatFix = analyzer.hasNoCodeSelected
        let fileName = analyzer.currentFileName
        
        if needsFormatFix && fileName != nil {
            // use format fix mode
            return try await handleWithFormatFix(req, fileName: fileName!)
        } else {
            // use normal mode
            return try await handleNormal(req)
        }
    }

    try app.register(collection: TodoController())
}
