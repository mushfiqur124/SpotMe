//
//  AIService.swift
//  SpotMe
//
//  AI service layer for workout parsing and chat responses
//  Referenced from Cursor Rules: Modular AI logic, secure API key management
//

import Foundation
import Combine

// MARK: - AI Service Protocol
protocol AIServiceProtocol {
    func sendMessage(_ message: String, context: [Workout]) async throws -> AIResponse
}

// MARK: - AI Response Model
struct AIResponse {
    let message: String
    let workoutData: WorkoutData?
    let suggestions: [String]
    
    struct WorkoutData {
        let exercises: [ExerciseData]
        let dayType: String?
        let notes: String?
        
        struct ExerciseData {
            let name: String
            let sets: Int
            let reps: Int 
            let weight: Double
            let isPR: Bool
        }
    }
}

// MARK: - AI Configuration
struct AIConfiguration {
    let modelName: String
    let apiEndpoint: String
    let maxTokens: Int
    let temperature: Double
    
    static let `default` = AIConfiguration(
        modelName: "gpt-4o-mini",
        apiEndpoint: "https://api.openai.com/v1/chat/completions",
        maxTokens: 150,
        temperature: 0.7
    )
}

// MARK: - AI Service Implementation
class AIService: AIServiceProtocol, ObservableObject {
    static let shared = AIService()
    
    private let configuration: AIConfiguration
    private let urlSession: URLSession
    
    @Published var isLoading = false
    @Published var errorMessage: String?
    
    private init(configuration: AIConfiguration = .default) {
        self.configuration = configuration
        self.urlSession = URLSession.shared
    }
    
    // MARK: - Public Methods
    
    func sendMessage(_ message: String, context: [Workout]) async throws -> AIResponse {
        isLoading = true
        defer { isLoading = false }
        
        let systemPrompt = generateSystemPrompt(with: context)
        let requestBody = createRequestBody(message: message, systemPrompt: systemPrompt)
        
        do {
            let response = try await makeAPICall(requestBody: requestBody)
            return parseResponse(response)
        } catch {
            errorMessage = "Failed to get AI response: \(error.localizedDescription)"
            throw error
        }
    }
    
    // MARK: - Private Methods
    
    private func generateSystemPrompt(with workouts: [Workout]) -> String {
        var prompt = """
        You are a Gen Z fitness coach and accountability buddy. Be casual, motivational, and slightly playful. 
        Use short, chatty messages with occasional emojis. Track user workouts (reps/sets/exercises) and suggest 
        new ones based on recent history.
        
        """
        
        // Add recent workout context
        if !workouts.isEmpty {
            prompt += "Recent workouts:\n"
            for workout in workouts.prefix(3) {
                let dateFormatter = DateFormatter()
                dateFormatter.dateStyle = .short
                prompt += "- \(dateFormatter.string(from: workout.date ?? Date())): \(workout.dayType ?? "") "
                
                if let exercises = workout.exercises?.allObjects as? [Exercise] {
                    let exerciseNames = exercises.compactMap { $0.name }.joined(separator: ", ")
                    prompt += "(\(exerciseNames))\n"
                }
            }
        }
        
        prompt += """
        
        Parse user messages and extract workout data in this format:
        WORKOUT_DATA: {
          "exercises": [
            {"name": "Exercise Name", "sets": 3, "reps": 8, "weight": 135.0, "isPR": false}
          ],
          "dayType": "Push/Pull/Legs/etc",
          "notes": "Any additional notes"
        }
        
        Always respond with motivation and context from their history!
        """
        
        return prompt
    }
    
    private func createRequestBody(message: String, systemPrompt: String) -> [String: Any] {
        return [
            "model": configuration.modelName,
            "messages": [
                ["role": "system", "content": systemPrompt],
                ["role": "user", "content": message]
            ],
            "max_tokens": configuration.maxTokens,
            "temperature": configuration.temperature
        ]
    }
    
    private func makeAPICall(requestBody: [String: Any]) async throws -> [String: Any] {
        guard let url = URL(string: configuration.apiEndpoint) else {
            throw AIError.invalidURL
        }
        
        var request = URLRequest(url: url)
        request.httpMethod = "POST"
        request.addValue("application/json", forHTTPHeaderField: "Content-Type")
        
        // API Key should come from environment variables or Keychain
        if let apiKey = getAPIKey() {
            request.addValue("Bearer \(apiKey)", forHTTPHeaderField: "Authorization")
        } else {
            throw AIError.missingAPIKey
        }
        
        request.httpBody = try JSONSerialization.data(withJSONObject: requestBody)
        
        let (data, response) = try await urlSession.data(for: request)
        
        guard let httpResponse = response as? HTTPURLResponse,
              200...299 ~= httpResponse.statusCode else {
            throw AIError.apiError("Invalid response")
        }
        
        guard let json = try JSONSerialization.jsonObject(with: data) as? [String: Any] else {
            throw AIError.invalidResponse
        }
        
        return json
    }
    
    private func parseResponse(_ json: [String: Any]) -> AIResponse {
        // Extract message from API response
        var message = "Sorry, I couldn't understand that. Could you try again? 💪"
        
        if let choices = json["choices"] as? [[String: Any]],
           let firstChoice = choices.first,
           let messageContent = firstChoice["message"] as? [String: Any],
           let content = messageContent["content"] as? String {
            message = content
        }
        
        // Parse workout data if present
        let workoutData = extractWorkoutData(from: message)
        
        // Generate suggestions (stub for now)
        let suggestions = ["Try increasing weight by 5 lbs", "Add one more set", "Focus on form"]
        
        return AIResponse(message: message, workoutData: workoutData, suggestions: suggestions)
    }
    
    private func extractWorkoutData(from message: String) -> AIResponse.WorkoutData? {
        // This is a simplified parser - in production, use more robust JSON parsing
        // Look for WORKOUT_DATA: {...} pattern in the message
        
        if message.contains("WORKOUT_DATA:") {
            // For now, return nil - implement JSON parsing in KDM-15
            return nil
        }
        
        return nil
    }
    
    private func getAPIKey() -> String? {
        // TODO: Implement secure API key retrieval from Keychain or environment
        // For now, return nil to prevent compilation issues
        return ProcessInfo.processInfo.environment["OPENAI_API_KEY"]
    }
}

// MARK: - Error Types
enum AIError: Error, LocalizedError {
    case invalidURL
    case missingAPIKey
    case apiError(String)
    case invalidResponse
    
    var errorDescription: String? {
        switch self {
        case .invalidURL:
            return "Invalid API URL"
        case .missingAPIKey:
            return "API key not found. Please set your API key in environment variables."
        case .apiError(let message):
            return "API Error: \(message)"
        case .invalidResponse:
            return "Invalid response from AI service"
        }
    }
}

// MARK: - Mock AI Service for Testing
class MockAIService: AIServiceProtocol {
    func sendMessage(_ message: String, context: [Workout]) async throws -> AIResponse {
        // Simulate network delay
        try await Task.sleep(nanoseconds: 1_000_000_000)
        
        return AIResponse(
            message: "Nice! I logged that workout for you. Keep pushing! 💪",
            workoutData: nil,
            suggestions: ["Try increasing weight next time", "Great form!", "Add cardio tomorrow"]
        )
    }
}
