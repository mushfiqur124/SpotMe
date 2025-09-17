//
//  ChatInputBar.swift
//  SpotMe
//
//  Chat input component for sending messages
//  Referenced from Cursor Rules: Handle multi-line input, send message triggers AI call
//

import SwiftUI

struct ChatInputBar: View {
    @Binding var text: String
    @State private var textHeight: CGFloat = 40
    
    let onSend: (String) -> Void
    
    private let maxHeight: CGFloat = 120
    private let minHeight: CGFloat = 40
    
    var body: some View {
        VStack(spacing: 0) {
            // Divider
            Divider()
            
            HStack(alignment: .bottom, spacing: 8) {
                // Text input
                inputField
                
                // Send button
                sendButton
            }
            .padding(.horizontal, 16)
            .padding(.vertical, 12)
            .background(Color(.systemBackground))
        }
    }
    
    // MARK: - Private Views
    
    private var inputField: some View {
        ZStack(alignment: .leading) {
            // Background
            RoundedRectangle(cornerRadius: 20)
                .fill(Color(.systemGray6))
                .frame(height: max(minHeight, min(textHeight, maxHeight)))
            
            // Placeholder
            if text.isEmpty {
                Text("Log your workout...")
                    .foregroundColor(.secondary)
                    .padding(.horizontal, 16)
                    .padding(.vertical, 12)
            }
            
            // Text editor
            TextView(text: $text, height: $textHeight)
                .padding(.horizontal, 12)
                .padding(.vertical, 8)
                .frame(height: max(minHeight, min(textHeight, maxHeight)))
        }
    }
    
    private var sendButton: some View {
        Button(action: sendMessage) {
            Image(systemName: "arrow.up.circle.fill")
                .font(.system(size: 28))
                .foregroundColor(canSend ? .blue : .gray)
        }
        .disabled(!canSend)
        .animation(.easeInOut(duration: 0.2), value: canSend)
    }
    
    // MARK: - Private Properties
    
    private var canSend: Bool {
        !text.trimmingCharacters(in: .whitespacesAndNewlines).isEmpty
    }
    
    // MARK: - Private Methods
    
    private func sendMessage() {
        let messageText = text.trimmingCharacters(in: .whitespacesAndNewlines)
        guard !messageText.isEmpty else { return }
        
        onSend(messageText)
        text = ""
        textHeight = minHeight
        
        // Hide keyboard
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
        textView.font = UIFont.systemFont(ofSize: 16)
        textView.backgroundColor = UIColor.clear
        textView.textColor = UIColor.label
        textView.isScrollEnabled = true
        textView.showsVerticalScrollIndicator = false
        textView.textContainer.lineBreakMode = .byWordWrapping
        textView.textContainerInset = UIEdgeInsets(top: 8, left: 4, bottom: 8, right: 4)
        return textView
    }
    
    func updateUIView(_ textView: UITextView, context: Context) {
        if textView.text != text {
            textView.text = text
        }
        
        // Update height based on content
        DispatchQueue.main.async {
            let size = textView.sizeThatFits(CGSize(width: textView.frame.width, 
                                                   height: CGFloat.greatestFiniteMagnitude))
            let newHeight = min(max(size.height, 40), maxHeight)
            
            if abs(height - newHeight) > 1 {
                height = newHeight
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
    }
}

// MARK: - Preview
#Preview {
    VStack {
        Spacer()
        
        ChatInputBar(text: .constant("")) { message in
            print("Sent: \(message)")
        }
    }
    .background(Color(.systemBackground))
}
