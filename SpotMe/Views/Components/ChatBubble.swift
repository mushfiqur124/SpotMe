//
//  ChatBubble.swift
//  SpotMe
//
//  Chat message bubble component matching ChatGPT iOS app design
//  User messages: Dark bubbles on right, AI messages: Plain text on left
//  Referenced from Cursor Rules: Reusable components, ChatGPT-like UI
//

import SwiftUI

struct ChatBubble: View {
    let message: ChatMessage
    let isTyping: Bool
    
    init(message: ChatMessage, isTyping: Bool = false) {
        self.message = message
        self.isTyping = isTyping
    }
    
    var body: some View {
        HStack(alignment: .top, spacing: 0) {
            if message.isFromUser {
                // User message - bubble on right side
                Spacer(minLength: 60) // More space on left for user messages
                
                userMessageBubble
                    .padding(.leading, 8)
            } else {
                // AI message - plain text on left side
                aiMessageContent
                    .padding(.trailing, 60) // More space on right for AI messages
                
                Spacer()
            }
        }
        .padding(.horizontal, 20)
        .padding(.vertical, 6)
    }
    
    // MARK: - Private Views
    
    @ViewBuilder
    private var userMessageBubble: some View {
        Text(message.content)
            .font(.body)
            .foregroundColor(.white)
            .padding(.horizontal, 16)
            .padding(.vertical, 12)
            .background(userBubbleBackground)
            .clipShape(RoundedRectangle(cornerRadius: 20))
            .multilineTextAlignment(.leading)
    }
    
    @ViewBuilder
    private var aiMessageContent: some View {
        HStack {
            if isTyping {
                TypingIndicator()
                    .padding(.leading, 4)
            } else {
                Text(message.content)
                    .font(.body)
                    .foregroundColor(.primary)
                    .multilineTextAlignment(.leading)
                    .fixedSize(horizontal: false, vertical: true)
            }
            
            Spacer()
        }
    }
    
    // MARK: - Private Computed Properties
    
    private var userBubbleBackground: some View {
        // ChatGPT-style user bubble - dark gray in both light and dark mode
        RoundedRectangle(cornerRadius: 20)
            .fill(Color(.systemGray2)) // Darker gray to match ChatGPT
    }
}

// MARK: - ChatGPT-Style Colors Extension
extension Color {
    /// ChatGPT user message bubble color - dark gray like ChatGPT
    static var chatGPTUserBubble: Color {
        Color(.systemGray2)
    }
    
    /// ChatGPT background color - matches system background
    static var chatGPTBackground: Color {
        Color(.systemBackground)
    }
    
    /// ChatGPT text color for user messages - white text on dark bubble
    static var chatGPTUserText: Color {
        .white
    }
    
    /// ChatGPT text color for AI messages - adapts to light/dark mode
    static var chatGPTAIText: Color {
        .primary
    }
}

// MARK: - ChatGPT-Style Typing Indicator
struct TypingIndicator: View {
    @State private var animationOffset: CGFloat = 0
    @State private var opacity: Double = 0.3
    
    var body: some View {
        HStack(spacing: 6) {
            ForEach(0..<3, id: \.self) { index in
                Circle()
                    .fill(Color.secondary.opacity(0.6))
                    .frame(width: 8, height: 8)
                    .scaleEffect(animationOffset == 0 ? 1.0 : 1.2)
                    .opacity(opacity)
                    .animation(
                        Animation.easeInOut(duration: 0.8)
                            .repeatForever(autoreverses: true)
                            .delay(Double(index) * 0.15),
                        value: animationOffset
                    )
                    .animation(
                        Animation.easeInOut(duration: 0.8)
                            .repeatForever(autoreverses: true)
                            .delay(Double(index) * 0.15),
                        value: opacity
                    )
            }
        }
        .padding(.vertical, 12)
        .onAppear {
            animationOffset = 1
            opacity = 1.0
        }
    }
}

// MARK: - Preview
#Preview("Light Mode") {
    VStack(spacing: 0) {
        ChatBubble(message: ChatMessage(
            content: "Hey! I just finished my workout. Did bench press, 3 sets of 8 reps at 135 lbs. How's that looking?",
            isFromUser: true
        ))
        
        ChatBubble(message: ChatMessage(
            content: "Nice work! That's solid progress from last week. You were at 130 lbs then, so this is a great 5lb jump! 💪 How did the reps feel?",
            isFromUser: false
        ))
        
        ChatBubble(message: ChatMessage(
            content: "Felt pretty good! Last rep was a bit of a grind but I got it clean",
            isFromUser: true
        ))
        
        ChatBubble(message: ChatMessage(
            content: "",
            isFromUser: false
        ), isTyping: true)
    }
    .background(Color.chatGPTBackground)
    .preferredColorScheme(.light)
}

#Preview("Dark Mode") {
    VStack(spacing: 0) {
        ChatBubble(message: ChatMessage(
            content: "Hey! I just finished my workout. Did bench press, 3 sets of 8 reps at 135 lbs. How's that looking?",
            isFromUser: true
        ))
        
        ChatBubble(message: ChatMessage(
            content: "Nice work! That's solid progress from last week. You were at 130 lbs then, so this is a great 5lb jump! 💪 How did the reps feel?",
            isFromUser: false
        ))
        
        ChatBubble(message: ChatMessage(
            content: "Felt pretty good! Last rep was a bit of a grind but I got it clean",
            isFromUser: true
        ))
        
        ChatBubble(message: ChatMessage(
            content: "",
            isFromUser: false
        ), isTyping: true)
    }
    .background(Color.chatGPTBackground)
    .preferredColorScheme(.dark)
}
