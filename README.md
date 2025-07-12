# CodeAssistProxy

💧 A code assistant proxy service built with the Vapor web framework.

## Project Overview

CodeAssistProxy is an intelligent proxy server whose main function is to forward requests in the OpenAI API format to the Google Gemini API. It also supports hack operations for Xcode's Code Assistant, enabling prompt injection and modification.

## Core Features

- **API Proxy Forwarding**: Converts and forwards API requests in the OpenAI format to the Google Gemini API
- **Model Information Retrieval**: Provides information about available AI models
- **Chat Completion Service**: Supports multi-turn conversations and code generation
- **Header Forwarding**: Preserves the integrity of the original request, ensuring correct transmission of authentication and content type

## API Endpoints

### Core Proxy API

- **GET `/v1/models`**
  - Function: Retrieve the list of available AI models
  - Description: Proxies the request to the Gemini API and returns supported model information

- **POST `/v1/chat/completions`**
  - Function: Chat completion endpoint, supporting code generation and Q&A
  - Description: Receives chat requests in the OpenAI format and forwards them to the Gemini API for processing

## Workflow

```
Client Request →  CodeAssistProxy        →       Google Gemini API   →   Response Returned to Client
    ↓                ↓                                  ↓                          ↑
OpenAI Format   Format Conversion & Forwarding     AI Processing         Return in Original Format
```

## Getting Started

### Requirements
- Swift 5.5+
- Vapor 4.0+

### Build the Project

In Sources/CodeAssistProxy/Constants.swift, replace the value of geminiAPIKey with your own API key:

```swift
  static let geminiAPIKey = "your-own-gemini-api-key"
```

Use Swift Package Manager to build the project:
```bash
swift build
```

### Run the Server
Start the development server:
```bash
swift run
```

## Configuration

The project uses the `Constants.swift` file to manage API configuration:
- Gemini API Key
- API Base URL
- Endpoint path configuration

## Tech Stack

- **Backend Framework**: Vapor 4.x
- **Language**: Swift
- **HTTP Client**: AsyncHTTPClient