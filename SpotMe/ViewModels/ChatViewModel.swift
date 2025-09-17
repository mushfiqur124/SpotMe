//
//  ChatViewModel.swift
//  SpotMe
//
//  ViewModel for managing chat state and AI interactions
//  Referenced from Cursor Rules: MVVM pattern, include historical context
//

import SwiftUI
import Combine

@MainActor
class ChatViewModel: ObservableObject {
    @Published var sessions: [ChatSession] = []
    @Published var selectedSession: ChatSession?
    @Published var isTyping = false
    @Published var errorMessage: String?
    
    private let aiService: AIServiceProtocol
    private let coreDataManager = CoreDataManager.shared
    private var cancellables = Set<AnyCancellable>()
    
    init(aiService: AIServiceProtocol = AIService.shared) {
        self.aiService = aiService
    }
    
    // MARK: - Computed Properties
    
    var currentMessages: [ChatMessage] {
        selectedSession?.messages ?? []
    }
    
    var currentSessionTitle: String {
        selectedSession?.displayTitle ?? "New Workout"
    }
    
    // MARK: - Public Methods
    
    func loadSessions() {
        // Load sessions from UserDefaults or CoreData in the future
        // For now, start with empty sessions
        if sessions.isEmpty {
            startNewSession()
        }
    }
    
    func startNewSession() {
        let newSession = ChatSession(title: "New Workout")
        sessions.insert(newSession, at: 0)
        selectedSession = newSession
    }
    
    func deleteSession(_ session: ChatSession) {
        sessions.removeAll { $0.id == session.id }
        
        if selectedSession?.id == session.id {
            selectedSession = sessions.first
        }
        
        if sessions.isEmpty {
            startNewSession()
        }
    }
    
    func sendMessage(_ messageText: String) {
        guard !messageText.trimmingCharacters(in: .whitespacesAndNewlines).isEmpty else {
            return
        }
        
        // Ensure we have a current session
        if selectedSession == nil {
            startNewSession()
        }
        
        // Add user message
        let userMessage = ChatMessage(content: messageText, isFromUser: true)
        selectedSession?.addMessage(userMessage)
        updateSessions()
        
        // Show typing indicator
        isTyping = true
        
        // Get AI response
        Task {
            await getAIResponse(for: messageText)
        }
    }
    
    // MARK: - Private Methods
    
    private func updateSessions() {
        // Trigger UI update
        objectWillChange.send()
        
        // Save sessions (implement persistence later)
        saveSessions()
    }
    
    private func getAIResponse(for message: String) async {
        do {
            // Get recent workouts for context
            let recentWorkouts = coreDataManager.fetchRecentWorkouts(days: 7)
            
            // Call AI service
            let response = try await aiService.sendMessage(message, context: recentWorkouts)
            
            // Process AI response
            await processAIResponse(response)
            
        } catch {
            await handleError(error)
        }
    }
    
    private func processAIResponse(_ response: AIResponse) async {
        // Stop typing indicator
        isTyping = false
        
        // Add AI message to current session
        let aiMessage = ChatMessage(content: response.message, isFromUser: false)
        selectedSession?.addMessage(aiMessage)
        
        // Process workout data if present
        if let workoutData = response.workoutData {
            await processWorkoutData(workoutData)
        }
        
        // Update session title based on day type
        if let dayType = response.workoutData?.dayType,
           !dayType.isEmpty,
           selectedSession?.dayType == nil {
            selectedSession?.dayType = dayType
        }
        
        updateSessions()
    }
    
    private func processWorkoutData(_ workoutData: AIResponse.WorkoutData) async {
        guard !workoutData.exercises.isEmpty else { return }
        
        // Create workout in CoreData
        let workout = coreDataManager.createWorkout(
            dayType: workoutData.dayType ?? "",
            notes: workoutData.notes ?? ""
        )
        
        // Add exercises
        for exerciseData in workoutData.exercises {
            _ = coreDataManager.addExercise(
                to: workout,
                name: exerciseData.name,
                sets: Int16(exerciseData.sets),
                reps: Int16(exerciseData.reps),
                weight: exerciseData.weight
            )
        }
    }
    
    private func handleError(_ error: Error) async {
        isTyping = false
        
        let errorMessage = "Sorry, I had trouble processing that. Could you try again? 💪"
        let aiMessage = ChatMessage(content: errorMessage, isFromUser: false)
        
        selectedSession?.addMessage(aiMessage)
        updateSessions()
        
        // Log error for debugging
        print("ChatViewModel Error: \(error)")
        self.errorMessage = error.localizedDescription
    }
    
    private func saveSessions() {
        // TODO: Implement session persistence
        // For now, sessions are only kept in memory
        
        // Future: Save to UserDefaults or CoreData
        // let encoder = JSONEncoder()
        // if let data = try? encoder.encode(sessions) {
        //     UserDefaults.standard.set(data, forKey: "chat_sessions")
        // }
    }
    
    private func loadPersistedSessions() {
        // TODO: Load sessions from persistence
        // For now, return empty array
        
        // Future: Load from UserDefaults or CoreData
        // if let data = UserDefaults.standard.data(forKey: "chat_sessions"),
        //    let savedSessions = try? JSONDecoder().decode([ChatSession].self, from: data) {
        //     sessions = savedSessions
        // }
    }
}
