//
//  ChatBubble.swift
//  SpotMe
//
//  Chat message bubble component mimicking ChatGPT iOS app
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
        HStack {
            if message.isFromUser {
                Spacer()
            }
            
            VStack(alignment: message.isFromUser ? .trailing : .leading, spacing: 4) {
                // Message bubble
                messageContent
                    .background(backgroundColor)
                    .foregroundColor(textColor)
                    .clipShape(RoundedRectangle(cornerRadius: 16))
                    .overlay(
                        // Tail for bubble
                        bubbleTail,
                        alignment: message.isFromUser ? .bottomTrailing : .bottomLeading
                    )
                
                // Timestamp
                Text(message.timestamp, style: .time)
                    .font(.caption2)
                    .foregroundColor(.secondary)
                    .padding(.horizontal, 4)
            }
            
            if !message.isFromUser {
                Spacer()
            }
        }
        .padding(.horizontal, 16)
        .padding(.vertical, 4)
    }
    
    // MARK: - Private Views
    
    @ViewBuilder
    private var messageContent: some View {
        HStack(spacing: 0) {
            if !message.isFromUser && isTyping {
                TypingIndicator()
                    .padding(.horizontal, 12)
                    .padding(.vertical, 10)
            } else {
                Text(message.content)
                    .font(.body)
                    .padding(.horizontal, 12)
                    .padding(.vertical, 10)
                    .multilineTextAlignment(message.isFromUser ? .trailing : .leading)
                    .fixedSize(horizontal: false, vertical: true)
            }
        }
        .frame(maxWidth: UIScreen.main.bounds.width * 0.75, alignment: message.isFromUser ? .trailing : .leading)
    }
    
    private var backgroundColor: Color {
        if message.isFromUser {
            return .blue
        } else {
            return Color(.systemGray5)
        }
    }
    
    private var textColor: Color {
        message.isFromUser ? .white : .primary
    }
    
    @ViewBuilder
    private var bubbleTail: some View {
        if message.isFromUser {
            // User bubble tail (right side)
            Triangle()
                .fill(backgroundColor)
                .frame(width: 10, height: 10)
                .rotationEffect(.degrees(135))
                .offset(x: 5, y: 5)
        } else {
            // AI bubble tail (left side)  
            Triangle()
                .fill(backgroundColor)
                .frame(width: 10, height: 10)
                .rotationEffect(.degrees(-45))
                .offset(x: -5, y: 5)
        }
    }
}

// MARK: - Triangle Shape for Bubble Tail
struct Triangle: Shape {
    func path(in rect: CGRect) -> Path {
        var path = Path()
        path.move(to: CGPoint(x: rect.midX, y: rect.minY))
        path.addLine(to: CGPoint(x: rect.minX, y: rect.maxY))
        path.addLine(to: CGPoint(x: rect.maxX, y: rect.maxY))
        path.addLine(to: CGPoint(x: rect.midX, y: rect.minY))
        return path
    }
}

// MARK: - Typing Indicator
struct TypingIndicator: View {
    @State private var animationOffset: CGFloat = 0
    
    var body: some View {
        HStack(spacing: 4) {
            ForEach(0..<3, id: \.self) { index in
                Circle()
                    .fill(Color.secondary)
                    .frame(width: 6, height: 6)
                    .offset(y: animationOffset)
                    .animation(
                        Animation.easeInOut(duration: 0.6)
                            .repeatForever(autoreverses: true)
                            .delay(Double(index) * 0.2),
                        value: animationOffset
                    )
            }
        }
        .onAppear {
            animationOffset = -3
        }
    }
}

// MARK: - Preview
#Preview {
    VStack(spacing: 16) {
        ChatBubble(message: ChatMessage(
            content: "I did bench press today, 3 sets of 8 reps at 135 lbs",
            isFromUser: true
        ))
        
        ChatBubble(message: ChatMessage(
            content: "Nice! That's the same as last time - ready to bump up the weight next session? 💪",
            isFromUser: false
        ))
        
        ChatBubble(message: ChatMessage(
            content: "Loading...",
            isFromUser: false
        ), isTyping: true)
    }
    .padding()
    .previewLayout(.sizeThatFits)
}
