//
//  ChatView.swift
//  SpotMe
//
//  Main chat interface view combining all chat components
//  Referenced from Cursor Rules: MVVM pattern, chat flow logic
//

import SwiftUI

struct ChatView: View {
    @StateObject private var chatViewModel = ChatViewModel()
    @State private var showSidebar = false
    @State private var inputText = ""
    
    var body: some View {
        NavigationView {
            VStack(spacing: 0) {
                // Chat messages
                ChatListView(
                    messages: chatViewModel.currentMessages,
                    isTyping: chatViewModel.isTyping
                )
                
                // Input bar
                ChatInputBar(text: $inputText) { message in
                    chatViewModel.sendMessage(message)
                }
            }
            .background(Color.chatGPTBackground) // ChatGPT-style background
            .navigationTitle(chatViewModel.currentSessionTitle)
            .navigationBarTitleDisplayMode(.inline)
            .toolbar {
                ToolbarItem(placement: .navigationBarLeading) {
                    Button(action: { showSidebar = true }) {
                        Image(systemName: "sidebar.left")
                            .foregroundColor(.primary)
                    }
                }
                
                ToolbarItem(placement: .navigationBarTrailing) {
                    Button(action: chatViewModel.startNewSession) {
                        Image(systemName: "plus")
                            .foregroundColor(.primary)
                    }
                }
            }
            .toolbarBackground(Color.chatGPTBackground, for: .navigationBar)
        }
        .navigationViewStyle(StackNavigationViewStyle()) // Prevent sidebar on iPad
        .sheet(isPresented: $showSidebar) {
            Sidebar(
                selectedSession: $chatViewModel.selectedSession,
                sessions: $chatViewModel.sessions,
                isPresented: $showSidebar,
                onNewChat: chatViewModel.startNewSession,
                onDeleteSession: chatViewModel.deleteSession
            )
        }
        .onAppear {
            chatViewModel.loadSessions()
        }
    }
}

// MARK: - Preview
#Preview {
    ChatView()
        .environment(\.managedObjectContext, PersistenceController.preview.container.viewContext)
}
