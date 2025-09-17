//
//  ChatListView.swift
//  SpotMe
//
//  ChatGPT-style scrollable chat interface with smooth animations
//  Referenced from Cursor Rules: Support dynamic height, auto-scroll to latest, ChatGPT-like UI
//

import SwiftUI

struct ChatListView: View {
    let messages: [ChatMessage]
    let isTyping: Bool
    
    @State private var isScrolledToBottom = true
    @State private var showScrollToBottomButton = false
    
    var body: some View {
        ScrollViewReader { proxy in
            ZStack(alignment: .bottomTrailing) {
                // Main scroll view
                ScrollView(.vertical, showsIndicators: false) {
                    LazyVStack(spacing: 0) { // ChatGPT uses minimal spacing between messages
                        // Welcome message if no messages
                        if messages.isEmpty {
                            welcomeMessage
                                .id("welcome")
                        } else {
                            // Top spacer for first message
                            Spacer(minLength: 16)
                                .id("top")
                        }
                        
                        // Chat messages
                        ForEach(messages.indices, id: \.self) { index in
                            let message = messages[index]
                            let isLastMessage = index == messages.count - 1
                            
                            ChatBubble(message: message)
                                .id(message.id)
                                .padding(.bottom, isLastMessage ? 8 : 16) // Less spacing between messages like ChatGPT
                        }
                        
                        // Typing indicator
                        if isTyping {
                            ChatBubble(
                                message: ChatMessage(content: "", isFromUser: false),
                                isTyping: true
                            )
                            .id("typing")
                            .padding(.bottom, 8)
                        }
                        
                        // Bottom spacer for natural scrolling (ChatGPT style)
                        Spacer(minLength: 20)
                            .id("bottom")
                    }
                }
                .clipped() // Clean ChatGPT look
                .background(Color.chatGPTBackground)
                .onChange(of: messages.count) { _ in
                    scrollToBottom(proxy: proxy, animated: true)
                    showScrollToBottomButton = false
                }
                .onChange(of: isTyping) { _ in
                    if isTyping {
                        scrollToBottom(proxy: proxy, animated: true)
                    }
                }
                .onAppear {
                    DispatchQueue.main.asyncAfter(deadline: .now() + 0.1) {
                        scrollToBottom(proxy: proxy, animated: false)
                    }
                }
                
                // Scroll to bottom button (ChatGPT style) - simplified for now
                // Future enhancement: Add scroll position tracking
                if messages.count > 5 && !isScrolledToBottom {
                    scrollToBottomButton(proxy: proxy)
                        .transition(.scale.combined(with: .opacity))
                }
            }
        }
    }
    
    // MARK: - Private Views
    
    private var welcomeMessage: some View {
        VStack(spacing: 0) {
            Spacer()
            
            VStack(spacing: 24) {
                // ChatGPT-style app icon
                VStack(spacing: 16) {
                    ZStack {
                        Circle()
                            .fill(Color(.systemGray6))
                            .frame(width: 64, height: 64)
                        
                        Image(systemName: "dumbbell.fill")
                            .font(.system(size: 28, weight: .medium))
                            .foregroundColor(.primary)
                    }
                    
                    VStack(spacing: 6) {
                        Text("SpotMe")
                            .font(.title)
                            .fontWeight(.semibold)
                            .foregroundColor(.primary)
                        
                        Text("Your AI fitness coach")
                            .font(.subheadline)
                            .foregroundColor(.secondary)
                    }
                }
                
                // ChatGPT-style example prompts
                VStack(spacing: 12) {
                    ForEach(examplePrompts, id: \.self) { prompt in
                        examplePromptButton(prompt)
                    }
                }
                .padding(.horizontal, 8)
            }
            
            Spacer()
            Spacer() // Extra spacer to center content like ChatGPT
        }
        .frame(maxWidth: .infinity)
        .padding(.horizontal, 20)
    }
    
    private var examplePrompts: [String] {
        [
            "Bench press, 3 sets of 8 reps at 135 lbs",
            "What should I work out today?",
            "Show me my bench press PR"
        ]
    }
    
    private func examplePromptButton(_ text: String) -> some View {
        Button(action: {
            // Future: Auto-fill input with this prompt
            print("Selected prompt: \(text)")
        }) {
            HStack {
                Text(text)
                    .font(.body)
                    .foregroundColor(.primary)
                    .multilineTextAlignment(.leading)
                Spacer()
            }
            .padding(.horizontal, 16)
            .padding(.vertical, 12)
            .background(
                RoundedRectangle(cornerRadius: 12)
                    .fill(Color(.systemGray6))
                    .overlay(
                        RoundedRectangle(cornerRadius: 12)
                            .stroke(Color(.systemGray5), lineWidth: 0.5)
                    )
            )
        }
        .buttonStyle(PlainButtonStyle())
    }
    
    private func scrollToBottomButton(proxy: ScrollViewProxy) -> some View {
        Button(action: {
            scrollToBottom(proxy: proxy, animated: true)
        }) {
            Image(systemName: "arrow.down")
                .font(.system(size: 14, weight: .medium))
                .foregroundColor(.primary)
                .frame(width: 32, height: 32)
                .background(
                    Circle()
                        .fill(Color(.systemBackground))
                        .shadow(color: .black.opacity(0.1), radius: 8, x: 0, y: 2)
                )
        }
        .padding(.trailing, 20)
        .padding(.bottom, 20)
    }
    
    // MARK: - Private Methods
    
    private func scrollToBottom(proxy: ScrollViewProxy, animated: Bool = true) {
        let targetID: AnyHashable
        
        if isTyping {
            targetID = "typing"
        } else if let lastMessage = messages.last {
            targetID = lastMessage.id
        } else {
            targetID = "bottom"
        }
        
        if animated {
            withAnimation(.easeInOut(duration: 0.4)) { // Slightly longer animation like ChatGPT
                proxy.scrollTo(targetID, anchor: .bottom)
            }
        } else {
            proxy.scrollTo(targetID, anchor: .bottom)
        }
    }
}

// MARK: - Preview
#Preview("Empty State - Light") {
    ChatListView(messages: [], isTyping: false)
        .preferredColorScheme(.light)
}

#Preview("Empty State - Dark") {
    ChatListView(messages: [], isTyping: false)
        .preferredColorScheme(.dark)
}

#Preview("With Messages") {
    let sampleMessages = [
        ChatMessage(content: "Hey! Just finished my workout", isFromUser: true),
        ChatMessage(content: "Awesome! Tell me about it - what did you do today? 💪", isFromUser: false),
        ChatMessage(content: "I did bench press today, 3 sets of 8 reps at 135 lbs. Also did some incline press and finished with tricep dips.", isFromUser: true),
        ChatMessage(content: "Nice work! That's solid progress from last week. You were at 130 lbs then, so this is a great 5lb jump! How did the reps feel? 🔥", isFromUser: false),
        ChatMessage(content: "Felt pretty good! Last rep was a bit of a grind but I got it clean", isFromUser: true),
        ChatMessage(content: "Perfect! That means you're ready to progress. Next session, let's try 140 lbs for the same sets and reps. Your strength is definitely building! 💪", isFromUser: false)
    ]
    
    ChatListView(messages: sampleMessages, isTyping: false)
        .preferredColorScheme(.dark)
}

#Preview("Typing Indicator") {
    let sampleMessages = [
        ChatMessage(content: "Just finished squats, 4 sets of 12 reps at 185 lbs", isFromUser: true)
    ]
    
    ChatListView(messages: sampleMessages, isTyping: true)
        .preferredColorScheme(.dark)
}
