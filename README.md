# CodeAssistProxy

💧 A code assistant proxy service built with the Vapor web framework.

## Project Overview

CodeAssistProxy is an intelligent proxy server that supports both cloud-based and local AI models. It can forward requests in the OpenAI API format to either **Google Gemini API** or **local Gemma3n model** via Ollama. The service includes specialized features for Xcode AI Assistant integration, enabling seamless code completion and generation with proper formatting.

## Core Features

- **Dual Model Support**: Switch between Google Gemini (cloud) and local Gemma3n models
- **Xcode AI Assistant Integration**: Specialized handling for Xcode AI Agent with automatic format correction
- **API Proxy Forwarding**: Converts and forwards API requests in the OpenAI format
- **Streaming Response Processing**: Real-time response streaming with format enhancement

## Getting Started

### Prerequisites
- Swift 5.5+
- Vapor 4.0+

### Option 1: Using Gemini API

1. **Configure API Key**:
   In `Sources/CodeAssistProxy/Constants.swift`, set your Gemini API key:
   ```swift
   static let geminiAPIKey = "your-gemini-api-key"
   static let useLocalModel = false // Use cloud service
   ```

2. **Build and Run**:
   ```bash
   swift build
   swift run
   ```

### Option 2: Using Local Gemma3n

1. **Install Ollama**:
   ```bash
   # macOS
   brew install ollama
   
   # Or download from https://ollama.ai
   ```

2. **Download Gemma3n Model**:
   ```bash
   ollama run gemma3n:e2b
   ```

3. **Configure for Local Model**:
   In `Sources/CodeAssistProxy/Constants.swift`:
   ```swift
   static let useLocalModel = true // Use local model
   static let localModelBaseURL = "http://localhost:11434/v1"
   static let localModelName = "gemma3n:e2b"
   ```

5. **Build and Run**:
   ```bash
   swift build
   swift run
   ```

## Model Switching

To switch between Gemini and Gemma3n models, modify the `useLocalModel` flag in `Constants.swift`:

```swift
// For Google Gemini
static let useLocalModel = false
// For Local Gemma3n
static let useLocalModel = true
```

## Setup for Xcode:
1. Ensure local Gemma3n is running (see Option 2 above)
2. Configure Xcode to use `http://localhost:8080` as the AI service endpoint
3. The proxy will automatically handle format conversion for optimal Xcode compatibility

## API Endpoints

### Core Proxy API

- **GET `/v1/models`**
  - Function: Retrieve the list of available AI models
  - Description: Returns supported model information from either Gemini or local Ollama

- **POST `/v1/chat/completions`**
  - Function: Chat completion endpoint with streaming support
  - Description: Processes chat requests and applies format corrections for Xcode when needed

## Architecture

```
Xcode AI Assistant → CodeAssistProxy → [Gemini API | Local Ollama] → Format Processing → Enhanced Response
```

## Tech Stack

- **Backend Framework**: Vapor
- **Language**: Swift
- **HTTP Client**: AsyncHTTPClient
- **AI Models**: Google Gemini, Local Gemma3n (via Ollama)
- **Streaming**: Server-Sent Events (SSE)
