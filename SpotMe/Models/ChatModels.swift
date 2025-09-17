//
//  ChatModels.swift
//  SpotMe
//
//  Data models for chat functionality
//

import Foundation

// MARK: - Chat Message Model
struct ChatMessage: Identifiable, Codable {
    let id: UUID
    let content: String
    let isFromUser: Bool
    let timestamp: Date
    
    init(id: UUID = UUID(), content: String, isFromUser: Bool, timestamp: Date = Date()) {
        self.id = id
        self.content = content
        self.isFromUser = isFromUser
        self.timestamp = timestamp
    }
}

// MARK: - Chat Session Model
struct ChatSession: Identifiable, Codable {
    let id: UUID
    let title: String
    let date: Date
    let dayType: String?
    var messages: [ChatMessage]
    
    init(id: UUID = UUID(), title: String, date: Date = Date(), dayType: String? = nil) {
        self.id = id
        self.title = title
        self.date = date
        self.dayType = dayType
        self.messages = []
    }
    
    mutating func addMessage(_ message: ChatMessage) {
        messages.append(message)
    }
    
    var displayTitle: String {
        if let dayType = dayType, !dayType.isEmpty {
            let dayEmoji = DayType(rawValue: dayType)?.emoji ?? "💪"
            return "\(dayEmoji) \(dayType)"
        }
        
        let formatter = DateFormatter()
        formatter.dateStyle = .medium
        return formatter.string(from: date)
    }
}
