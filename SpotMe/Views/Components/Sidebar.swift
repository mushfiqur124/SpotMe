//
//  Sidebar.swift
//  SpotMe
//
//  Left sidebar showing past conversations/workout dates
//  Referenced from Cursor Rules: Show past conversations with day type
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
                // Header
                sidebarHeader
                
                // Sessions list
                sessionsList
                
                Spacer()
                
                // Footer with app info
                sidebarFooter
            }
            .navigationTitle("Workouts")
            .navigationBarTitleDisplayMode(.large)
            .background(Color(.systemGroupedBackground))
        }
        .navigationViewStyle(StackNavigationViewStyle())
    }
    
    // MARK: - Private Views
    
    private var sidebarHeader: some View {
        VStack(spacing: 12) {
            // New Chat button
            Button(action: {
                onNewChat()
                isPresented = false
            }) {
                HStack {
                    Image(systemName: "plus.circle.fill")
                    Text("New Workout")
                    Spacer()
                }
                .padding(.horizontal, 16)
                .padding(.vertical, 12)
                .background(Color.blue)
                .foregroundColor(.white)
                .cornerRadius(12)
            }
            .padding(.horizontal, 16)
            
            Divider()
        }
        .padding(.top, 8)
    }
    
    private var sessionsList: some View {
        ScrollView {
            LazyVStack(spacing: 4) {
                if sessions.isEmpty {
                    emptyState
                } else {
                    // Group sessions by date
                    ForEach(groupedSessions, id: \.0) { date, sessionGroup in
                        Section {
                            ForEach(sessionGroup) { session in
                                sessionRow(session)
                            }
                        } header: {
                            sectionHeader(for: date)
                        }
                    }
                }
            }
            .padding(.horizontal, 8)
        }
    }
    
    private var emptyState: some View {
        VStack(spacing: 16) {
            Image(systemName: "dumbbell")
                .font(.system(size: 32))
                .foregroundColor(.secondary)
            
            Text("No workouts yet")
                .font(.headline)
                .foregroundColor(.secondary)
            
            Text("Start your first workout to see it here!")
                .font(.subheadline)
                .foregroundColor(.secondary)
                .multilineTextAlignment(.center)
        }
        .padding(.horizontal, 24)
        .padding(.vertical, 32)
    }
    
    private func sessionRow(_ session: ChatSession) -> some View {
        Button(action: {
            selectedSession = session
            isPresented = false
        }) {
            HStack(spacing: 12) {
                // Day type indicator
                if let dayType = session.dayType,
                   let type = DayType(rawValue: dayType) {
                    Text(type.emoji)
                        .font(.title2)
                } else {
                    Image(systemName: "message.circle")
                        .foregroundColor(.secondary)
                }
                
                VStack(alignment: .leading, spacing: 2) {
                    Text(session.displayTitle)
                        .font(.subheadline)
                        .fontWeight(.medium)
                        .lineLimit(1)
                    
                    Text("\(session.messages.count) messages")
                        .font(.caption)
                        .foregroundColor(.secondary)
                }
                
                Spacer()
                
                // Time
                Text(session.date, style: .time)
                    .font(.caption)
                    .foregroundColor(.secondary)
            }
            .padding(.horizontal, 12)
            .padding(.vertical, 8)
            .background(
                RoundedRectangle(cornerRadius: 8)
                    .fill(selectedSession?.id == session.id ? Color.blue.opacity(0.1) : Color.clear)
            )
            .overlay(
                RoundedRectangle(cornerRadius: 8)
                    .stroke(selectedSession?.id == session.id ? Color.blue : Color.clear, lineWidth: 1)
            )
        }
        .buttonStyle(PlainButtonStyle())
        .contextMenu {
            Button("Delete", role: .destructive) {
                onDeleteSession(session)
            }
        }
    }
    
    private func sectionHeader(for date: Date) -> some View {
        HStack {
            Text(sectionTitle(for: date))
                .font(.caption)
                .fontWeight(.semibold)
                .foregroundColor(.secondary)
                .textCase(.uppercase)
            
            Spacer()
        }
        .padding(.horizontal, 12)
        .padding(.vertical, 4)
    }
    
    private var sidebarFooter: some View {
        VStack(spacing: 8) {
            Divider()
            
            HStack {
                Image(systemName: "dumbbell.fill")
                    .foregroundColor(.blue)
                Text("SpotMe")
                    .font(.footnote)
                    .fontWeight(.semibold)
                Spacer()
                Text("v0.1")
                    .font(.caption)
                    .foregroundColor(.secondary)
            }
            .padding(.horizontal, 16)
            .padding(.bottom, 8)
        }
    }
    
    // MARK: - Private Computed Properties
    
    private var groupedSessions: [(Date, [ChatSession])] {
        let calendar = Calendar.current
        let grouped = Dictionary(grouping: sessions) { session in
            calendar.startOfDay(for: session.date)
        }
        
        return grouped.sorted { $0.key > $1.key }
    }
    
    // MARK: - Private Methods
    
    private func sectionTitle(for date: Date) -> String {
        let calendar = Calendar.current
        let today = calendar.startOfDay(for: Date())
        let sectionDate = calendar.startOfDay(for: date)
        
        if sectionDate == today {
            return "Today"
        } else if sectionDate == calendar.date(byAdding: .day, value: -1, to: today) {
            return "Yesterday"
        } else {
            let formatter = DateFormatter()
            formatter.dateFormat = "MMM d"
            return formatter.string(from: date)
        }
    }
}

// MARK: - Preview
#Preview {
    let sampleSessions = [
        ChatSession(title: "Push Day", dayType: "Push"),
        ChatSession(title: "Pull Day", dayType: "Pull"),
        ChatSession(title: "Leg Day", dayType: "Legs")
    ]
    
    Sidebar(
        selectedSession: .constant(nil),
        sessions: .constant(sampleSessions),
        isPresented: .constant(true),
        onNewChat: { print("New chat") },
        onDeleteSession: { _ in print("Delete session") }
    )
}
