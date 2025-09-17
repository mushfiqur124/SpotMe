//
//  Sidebar.swift
//  SpotMe
//
//  ChatGPT-style sidebar showing workout history
//  Clean, simple design focused on workout sessions
//

import SwiftUI

struct Sidebar: View {
    @Binding var selectedSession: ChatSession?
    @Binding var sessions: [ChatSession]
    @Binding var isPresented: Bool
    
    let onNewChat: () -> Void
    let onDeleteSession: (ChatSession) -> Void
    
    var body: some View {
        NavigationView {
            VStack(spacing: 0) {
                // Header with new workout button
                sidebarHeader
                
                // Simple workout sessions list
                workoutSessionsList
                
                // Footer
                sidebarFooter
            }
            .background(Color.chatGPTBackground)
            .navigationBarHidden(true)
        }
        .navigationViewStyle(StackNavigationViewStyle())
    }
    
    // MARK: - Private Views
    
    private var sidebarHeader: some View {
        VStack(spacing: 0) {
            // Top padding
            Spacer()
                .frame(height: 60) // Status bar + some padding
            
            // App title and close button
            HStack {
                Button(action: { isPresented = false }) {
                    Image(systemName: "sidebar.left")
                        .font(.system(size: 18))
                        .foregroundColor(.primary)
                }
                
                Spacer()
                
                Text("SpotMe")
                    .font(.headline)
                    .fontWeight(.semibold)
                
                Spacer()
                
                // New workout button
                Button(action: {
                    onNewChat()
                    isPresented = false
                }) {
                    Image(systemName: "square.and.pencil")
                        .font(.system(size: 18))
                        .foregroundColor(.primary)
                }
            }
            .padding(.horizontal, 20)
            .padding(.bottom, 20)
        }
    }
    
    private var workoutSessionsList: some View {
        ScrollView(showsIndicators: false) {
            if sessions.isEmpty {
                emptyState
            } else {
                LazyVStack(spacing: 2) { // Minimal spacing like ChatGPT
                    ForEach(sessions.sorted { $0.date > $1.date }) { session in
                        workoutSessionRow(session)
                    }
                }
                .padding(.horizontal, 12)
                .padding(.top, 8)
            }
        }
    }
    
    private var emptyState: some View {
        VStack(spacing: 12) {
            Spacer()
            
            Image(systemName: "dumbbell")
                .font(.system(size: 28))
                .foregroundColor(.secondary)
            
            Text("No workouts yet")
                .font(.subheadline)
                .foregroundColor(.secondary)
            
            Spacer()
        }
        .frame(maxWidth: .infinity, maxHeight: .infinity)
    }
    
    private func workoutSessionRow(_ session: ChatSession) -> some View {
        Button(action: {
            selectedSession = session
            isPresented = false
        }) {
            HStack(spacing: 12) {
                VStack(alignment: .leading, spacing: 2) {
                    // Workout title (day type or date)
                    Text(workoutTitle(for: session))
                        .font(.system(size: 15))
                        .fontWeight(.medium)
                        .foregroundColor(.primary)
                        .lineLimit(1)
                    
                    // Date subtitle
                    Text(formatDate(session.date))
                        .font(.system(size: 13))
                        .foregroundColor(.secondary)
                }
                
                Spacer()
            }
            .padding(.horizontal, 16)
            .padding(.vertical, 10)
            .background(
                RoundedRectangle(cornerRadius: 8)
                    .fill(selectedSession?.id == session.id ? 
                          Color(.systemGray5) : Color.clear)
            )
        }
        .buttonStyle(PlainButtonStyle())
        .contextMenu {
            Button("Delete", role: .destructive) {
                onDeleteSession(session)
            }
        }
    }
    
    private var sidebarFooter: some View {
        VStack(spacing: 0) {
            Spacer()
                .frame(height: 20)
        }
    }
    
    // MARK: - Private Methods
    
    private func workoutTitle(for session: ChatSession) -> String {
        if let dayType = session.dayType, !dayType.isEmpty {
            return "\(dayType) Day"
        } else {
            return "Workout"
        }
    }
    
    private func formatDate(_ date: Date) -> String {
        let calendar = Calendar.current
        let now = Date()
        
        if calendar.isDateInToday(date) {
            return "Today"
        } else if calendar.isDateInYesterday(date) {
            return "Yesterday" 
        } else if calendar.isDate(date, equalTo: now, toGranularity: .weekOfYear) {
            let formatter = DateFormatter()
            formatter.dateFormat = "EEEE" // Day of week
            return formatter.string(from: date)
        } else {
            let formatter = DateFormatter()
            formatter.dateFormat = "MMM d"
            return formatter.string(from: date)
        }
    }
}

// MARK: - Preview
#Preview("Light Mode") {
    let sampleSessions = [
        ChatSession(title: "Push Day", date: Date(), dayType: "Push"),
        ChatSession(title: "Pull Day", date: Calendar.current.date(byAdding: .day, value: -1, to: Date()) ?? Date(), dayType: "Pull"),
        ChatSession(title: "Leg Day", date: Calendar.current.date(byAdding: .day, value: -2, to: Date()) ?? Date(), dayType: "Legs"),
        ChatSession(title: "Chest Workout", date: Calendar.current.date(byAdding: .day, value: -3, to: Date()) ?? Date(), dayType: "Chest"),
        ChatSession(title: "Back Day", date: Calendar.current.date(byAdding: .day, value: -5, to: Date()) ?? Date(), dayType: "Back")
    ]
    
    Sidebar(
        selectedSession: .constant(sampleSessions[0]),
        sessions: .constant(sampleSessions),
        isPresented: .constant(true),
        onNewChat: { print("New chat") },
        onDeleteSession: { _ in print("Delete session") }
    )
    .preferredColorScheme(.light)
}

#Preview("Dark Mode") {
    let sampleSessions = [
        ChatSession(title: "Push Day", date: Date(), dayType: "Push"),
        ChatSession(title: "Pull Day", date: Calendar.current.date(byAdding: .day, value: -1, to: Date()) ?? Date(), dayType: "Pull"),
        ChatSession(title: "Leg Day", date: Calendar.current.date(byAdding: .day, value: -2, to: Date()) ?? Date(), dayType: "Legs")
    ]
    
    Sidebar(
        selectedSession: .constant(nil),
        sessions: .constant(sampleSessions),
        isPresented: .constant(true),
        onNewChat: { print("New chat") },
        onDeleteSession: { _ in print("Delete session") }
    )
    .preferredColorScheme(.dark)
}

#Preview("Empty State") {
    Sidebar(
        selectedSession: .constant(nil),
        sessions: .constant([]),
        isPresented: .constant(true),
        onNewChat: { print("New chat") },
        onDeleteSession: { _ in print("Delete session") }
    )
    .preferredColorScheme(.dark)
}
