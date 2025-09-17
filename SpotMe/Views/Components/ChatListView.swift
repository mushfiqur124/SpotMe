//
//  ChatListView.swift
//  SpotMe
//
//  Scrollable list of chat messages
//  Referenced from Cursor Rules: Support dynamic height, auto-scroll to latest
//

import SwiftUI

struct ChatListView: View {
    let messages: [ChatMessage]
    let isTyping: Bool
    
    var body: some View {
        ScrollViewReader { proxy in
            ScrollView(.vertical, showsIndicators: false) {
                LazyVStack(spacing: 8) {
                    // Welcome message if no messages
                    if messages.isEmpty {
                        welcomeMessage
                            .id("welcome")
                    }
                    
                    // Chat messages
                    ForEach(messages) { message in
                        ChatBubble(message: message)
                            .id(message.id)
                    }
                    
                    // Typing indicator
                    if isTyping {
                        ChatBubble(
                            message: ChatMessage(content: "", isFromUser: false),
                            isTyping: true
                        )
                        .id("typing")
                    }
                    
                    // Bottom spacer for natural scrolling
                    Spacer(minLength: 20)
                        .id("bottom")
                }
                .padding(.top, 16)
            }
            .onChange(of: messages.count) { _ in
                scrollToBottom(proxy: proxy)
            }
            .onChange(of: isTyping) { _ in
                if isTyping {
                    scrollToBottom(proxy: proxy, animated: true)
                }
            }
            .onAppear {
                scrollToBottom(proxy: proxy, animated: false)
            }
        }
    }
    
    // MARK: - Private Views
    
    private var welcomeMessage: some View {
        VStack(spacing: 16) {
            // App icon or logo placeholder
            Image(systemName: "dumbbell.fill")
                .font(.system(size: 40))
                .foregroundColor(.blue)
            
            VStack(spacing: 8) {
                Text("Welcome to SpotMe! 💪")
                    .font(.title2)
                    .fontWeight(.bold)
                
                Text("Your AI fitness coach is ready to help you log workouts and track progress.")
                    .font(.body)
                    .foregroundColor(.secondary)
                    .multilineTextAlignment(.center)
            }
            
            // Example prompts
            VStack(alignment: .leading, spacing: 8) {
                Text("Try saying something like:")
                    .font(.subheadline)
                    .fontWeight(.medium)
                    .foregroundColor(.secondary)
                
                examplePrompt("\"Bench press, 3 sets of 8 reps at 135 lbs\"")
                examplePrompt("\"What should I work out today?\"")
                examplePrompt("\"Show me my bench press PR\"")
            }
            .frame(maxWidth: .infinity, alignment: .leading)
        }
        .padding(.horizontal, 24)
        .padding(.vertical, 32)
    }
    
    private func examplePrompt(_ text: String) -> some View {
        Text("• \(text)")
            .font(.footnote)
            .foregroundColor(.secondary)
            .italic()
    }
    
    // MARK: - Private Methods
    
    private func scrollToBottom(proxy: ScrollViewReader, animated: Bool = true) {
        let targetID = isTyping ? "typing" : (messages.last?.id ?? "bottom")
        
        if animated {
            withAnimation(.easeInOut(duration: 0.3)) {
                proxy.scrollTo(targetID, anchor: .bottom)
            }
        } else {
            proxy.scrollTo(targetID, anchor: .bottom)
        }
    }
}

// MARK: - Preview
#Preview {
    let sampleMessages = [
        ChatMessage(content: "I did bench press today, 3 sets of 8 reps at 135 lbs", isFromUser: true),
        ChatMessage(content: "Nice! That's the same as last time - ready to bump up the weight next session? 💪", isFromUser: false),
        ChatMessage(content: "Yeah, let's try 140 lbs next time", isFromUser: true),
        ChatMessage(content: "Perfect! I'll remind you about that next push day. Keep crushing it! 🔥", isFromUser: false)
    ]
    
    ChatListView(messages: sampleMessages, isTyping: false)
        .previewDisplayName("With Messages")
    
    ChatListView(messages: [], isTyping: false)
        .previewDisplayName("Empty State")
}
