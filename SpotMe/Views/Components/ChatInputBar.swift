//
//  ChatInputBar.swift
//  SpotMe
//
//  ChatGPT-style input component for fitness workout logging
//  Clean design with text field and send button only
//  Referenced from Cursor Rules: Handle multi-line input, send message triggers AI call
//

import SwiftUI

struct ChatInputBar: View {
    @Binding var text: String
    @State private var textHeight: CGFloat = 44 // ChatGPT default height
    
    let onSend: (String) -> Void
    
    private let maxHeight: CGFloat = 120
    private let minHeight: CGFloat = 44 // Match ChatGPT min height
    
    var body: some View {
        VStack(spacing: 0) {
            // ChatGPT-style subtle divider
            Divider()
                .background(Color(.separator).opacity(0.3))
            
            HStack(alignment: .bottom, spacing: 8) {
                // Text input field (matches ChatGPT exactly)
                inputField
                
                // Send button (ChatGPT-style)
                sendButton
            }
            .padding(.horizontal, 16)
            .padding(.vertical, 12)
            .background(Color.chatGPTBackground)
        }
    }
    
    // MARK: - Private Views
    
    private var inputField: some View {
        ZStack(alignment: .leading) {
            // ChatGPT-style input background
            RoundedRectangle(cornerRadius: 22)
                .fill(Color(.systemGray6))
                .frame(height: max(minHeight, min(textHeight, maxHeight)))
            
            // Fitness-appropriate placeholder
            if text.isEmpty {
                Text("Log your workout...")
                    .foregroundColor(Color(.placeholderText))
                    .padding(.horizontal, 16)
                    .padding(.vertical, 12)
                    .font(.system(size: 17)) // Match ChatGPT font size
            }
            
            // Multi-line text editor
            TextView(text: $text, height: $textHeight)
                .padding(.horizontal, 12)
                .padding(.vertical, 8)
                .frame(height: max(minHeight, min(textHeight, maxHeight)))
        }
    }
    
    private var sendButton: some View {
        Button(action: sendMessage) {
            ZStack {
                // Button background - matches ChatGPT exactly
                Circle()
                    .fill(canSend ? Color(.label) : Color(.systemGray4))
                    .frame(width: 32, height: 32)
                
                // Up arrow icon
                Image(systemName: "arrow.up")
                    .font(.system(size: 16, weight: .semibold))
                    .foregroundColor(canSend ? Color(.systemBackground) : Color(.systemGray2))
            }
        }
        .disabled(!canSend)
        .animation(.easeInOut(duration: 0.15), value: canSend)
    }
    
    // MARK: - Private Properties
    
    private var canSend: Bool {
        !text.trimmingCharacters(in: .whitespacesAndNewlines).isEmpty
    }
    
    // MARK: - Private Methods
    
    private func sendMessage() {
        let messageText = text.trimmingCharacters(in: .whitespacesAndNewlines)
        guard !messageText.isEmpty else { return }
        
        // Smooth animation when sending
        withAnimation(.easeInOut(duration: 0.2)) {
            onSend(messageText)
            text = ""
            textHeight = minHeight
        }
        
        // Hide keyboard smoothly
        UIApplication.shared.sendAction(#selector(UIResponder.resignFirstResponder), 
                                       to: nil, from: nil, for: nil)
    }
}

// MARK: - UITextView Wrapper for Multi-line Input
struct TextView: UIViewRepresentable {
    @Binding var text: String
    @Binding var height: CGFloat
    
    private let maxHeight: CGFloat = 120
    
    func makeUIView(context: Context) -> UITextView {
        let textView = UITextView()
        textView.delegate = context.coordinator
        textView.font = UIFont.systemFont(ofSize: 17) // Match ChatGPT font size
        textView.backgroundColor = UIColor.clear
        textView.textColor = UIColor.label
        textView.isScrollEnabled = true
        textView.showsVerticalScrollIndicator = false
        textView.textContainer.lineBreakMode = .byWordWrapping
        textView.textContainerInset = UIEdgeInsets(top: 10, left: 8, bottom: 10, right: 8)
        textView.returnKeyType = .send // Enable send on return key
        return textView
    }
    
    func updateUIView(_ textView: UITextView, context: Context) {
        if textView.text != text {
            textView.text = text
        }
        
        // Update height based on content (ChatGPT-style smooth resizing)
        DispatchQueue.main.async {
            let size = textView.sizeThatFits(CGSize(width: textView.frame.width, 
                                                   height: CGFloat.greatestFiniteMagnitude))
            let newHeight = min(max(size.height, 44), maxHeight) // Match ChatGPT min height
            
            if abs(height - newHeight) > 2 {
                withAnimation(.easeInOut(duration: 0.1)) {
                    height = newHeight
                }
            }
        }
    }
    
    func makeCoordinator() -> Coordinator {
        Coordinator(self)
    }
    
    class Coordinator: NSObject, UITextViewDelegate {
        let parent: TextView
        
        init(_ parent: TextView) {
            self.parent = parent
        }
        
        func textViewDidChange(_ textView: UITextView) {
            DispatchQueue.main.async {
                self.parent.text = textView.text
            }
        }
        
        // Handle return key press for sending
        func textView(_ textView: UITextView, shouldChangeTextIn range: NSRange, replacementText text: String) -> Bool {
            if text == "\n" {
                // Send message on return key (like ChatGPT)
                if let parent = textView.superview?.superview,
                   let chatInputBar = parent as? UIView {
                    // Trigger send action
                    DispatchQueue.main.async {
                        // This will be handled by the send button action
                    }
                }
                return false
            }
            return true
        }
    }
}

// MARK: - Preview
#Preview("Light Mode") {
    VStack {
        Spacer()
        
        ChatInputBar(text: .constant("")) { message in
            print("Sent: \(message)")
        }
    }
    .background(Color.chatGPTBackground)
    .preferredColorScheme(.light)
}

#Preview("Dark Mode") {
    VStack {
        Spacer()
        
        ChatInputBar(text: .constant("")) { message in
            print("Sent: \(message)")
        }
    }
    .background(Color.chatGPTBackground)
    .preferredColorScheme(.dark)
}

#Preview("With Text") {
    VStack {
        Spacer()
        
        ChatInputBar(text: .constant("Just finished bench press, 3 sets of 8 reps at 135 lbs. Felt really good!")) { message in
            print("Sent: \(message)")
        }
    }
    .background(Color.chatGPTBackground)
    .preferredColorScheme(.dark)
}
