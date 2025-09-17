//
//  Constants.swift
//  SpotMe
//
//  App constants and configuration values
//  Referenced from Cursor Rules: Minimize hard-coded strings, use constants/enums
//

import Foundation
import SwiftUI

// MARK: - App Constants
enum AppConstants {
    static let appName = "SpotMe"
    static let version = "0.1"
    static let maxMessageLength = 500
    static let maxChatSessions = 50
    static let contextWorkoutDays = 7
}

// MARK: - API Configuration
enum APIConfig {
    static let openAIBaseURL = "https://api.openai.com/v1/chat/completions"
    static let geminiBaseURL = "https://generativelanguage.googleapis.com/v1beta"
    static let requestTimeoutInterval: TimeInterval = 30
    static let maxRetries = 3
}

// MARK: - UI Constants
enum UIConstants {
    static let cornerRadius: CGFloat = 12
    static let borderRadius: CGFloat = 16
    static let padding: CGFloat = 16
    static let spacing: CGFloat = 8
    
    enum ChatBubble {
        static let maxWidth: CGFloat = 0.75 // Percentage of screen width
        static let cornerRadius: CGFloat = 16
        static let padding = EdgeInsets(top: 10, leading: 12, bottom: 10, trailing: 12)
    }
    
    enum InputBar {
        static let minHeight: CGFloat = 40
        static let maxHeight: CGFloat = 120
        static let cornerRadius: CGFloat = 20
    }
}

// MARK: - Colors
extension Color {
    static let spotMeBlue = Color.blue
    static let spotMeGray = Color(.systemGray6)
    static let messageBackground = Color(.systemGray5)
    static let userMessageBackground = Color.blue
}

// MARK: - System Prompts
enum SystemPrompts {
    static let fitnessCoach = """
    You are a Gen Z fitness coach and accountability buddy named SpotMe. Be casual, motivational, and slightly playful. 
    Use short, chatty messages with occasional emojis. Your personality:
    - Encouraging but not over-the-top
    - Uses fitness slang naturally 
    - Remembers past workouts and celebrates progress
    - Gives practical advice about weights, sets, reps
    - Suggests rest days when needed
    - Celebrates PRs and milestones
    
    When users log workouts, extract this information:
    - Exercise names (handle synonyms/variations)
    - Sets and reps
    - Weight used
    - Day type (push/pull/legs/shoulders/etc)
    - Whether it's a personal record
    
    Always respond with the extracted data in this format:
    WORKOUT_DATA: {
      "exercises": [
        {"name": "Exercise Name", "sets": 3, "reps": 8, "weight": 135.0, "isPR": false}
      ],
      "dayType": "Push",
      "notes": "Optional notes"
    }
    
    Keep responses under 100 words. Be helpful but concise.
    """
}

// MARK: - Error Messages
enum ErrorMessages {
    static let networkError = "Connection issue - check your internet! 📶"
    static let aiServiceError = "AI coach is taking a break. Try again in a sec! 🤖"
    static let coreDataError = "Couldn't save your workout. Let me try again! 💾"
    static let invalidInput = "I didn't catch that. Could you describe your workout differently? 🤔"
    static let apiKeyMissing = "Missing API key. Check your configuration! 🔑"
}

// MARK: - Notifications
enum NotificationNames {
    static let workoutSaved = "WorkoutSavedNotification"
    static let personalRecordAchieved = "PersonalRecordAchievedNotification"
    static let newChatSession = "NewChatSessionNotification"
}

// MARK: - UserDefaults Keys
enum UserDefaultsKeys {
    static let chatSessions = "chat_sessions"
    static let selectedAIModel = "selected_ai_model"
    static let apiProvider = "api_provider"
    static let onboardingCompleted = "onboarding_completed"
}

// MARK: - Keychain Keys
enum KeychainKeys {
    static let openAIAPIKey = "openai_api_key"
    static let geminiAPIKey = "gemini_api_key"
}
