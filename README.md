# SpotMe - AI Fitness Coach

A conversational fitness tracking app that allows users to log workouts, track progress, and receive guidance from an AI-powered coach through natural chat interactions.

## Overview

SpotMe transforms the tedious process of workout logging into natural conversations. Users simply type messages like "Bench press, 3 sets of 8 reps at 135 lbs" and the AI coach parses the data, stores it, and provides motivational guidance based on workout history.

### Key Features

- **Chat-Based Logging**: Natural language workout entry
- **AI Coach**: Gen Z fitness coach persona with motivational responses
- **Progress Tracking**: Automatic PR detection and historical context
- **Offline-First**: CoreData storage for privacy and offline use
- **Smart Parsing**: Handles exercise synonyms and weight calculations

## Technical Architecture

- **Platform**: iOS (SwiftUI)
- **Database**: CoreData (local storage)
- **AI Layer**: Modular service supporting GPT-4o mini / Gemini Flash-Lite
- **Architecture**: MVVM pattern
- **Security**: Environment variables / Keychain for API keys

## Project Structure

```
SpotMe/
├── Models/                 # CoreData entities and data models
│   ├── WorkoutModels.swift
│   └── ChatModels.swift
├── Views/                  # SwiftUI views and components
│   ├── ChatView.swift
│   └── Components/
│       ├── ChatBubble.swift
│       ├── ChatInputBar.swift
│       ├── ChatListView.swift
│       └── Sidebar.swift
├── ViewModels/            # MVVM view models
│   └── ChatViewModel.swift
├── Services/              # Business logic and external services
│   ├── AIService.swift
│   └── CoreDataManager.swift
└── Utils/                 # Constants and extensions
    ├── Constants.swift
    └── Extensions.swift
```

## Getting Started

### Prerequisites

- Xcode 15.0+
- iOS 16.0+ target
- OpenAI API key or Gemini API key

### Setup

1. Clone the repository
2. Open `SpotMe.xcodeproj` in Xcode
3. Set your API key as an environment variable:
   ```bash
   export OPENAI_API_KEY="your-api-key-here"
   ```
4. Build and run the project

### Configuration

The app uses environment variables for API configuration:
- `OPENAI_API_KEY`: OpenAI API key for GPT models
- `GEMINI_API_KEY`: Google Gemini API key (alternative)

## Development Phases

### ✅ Phase 1: Project Setup
- [x] Xcode project structure
- [x] CoreData schema design
- [x] Basic UI scaffolding

### 🔄 Phase 2: Database Layer (In Progress)
- [ ] CoreData entities implementation
- [ ] CRUD operations
- [ ] Data persistence

### 📋 Phase 3: UI Components
- [ ] Chat bubble styling
- [ ] Input bar functionality
- [ ] Sidebar navigation
- [ ] Responsive design

### 🤖 Phase 4: AI Integration
- [ ] API service layer
- [ ] Message parsing logic
- [ ] Response streaming
- [ ] Error handling

### 🧪 Phase 5: Testing
- [ ] Unit tests for CoreData
- [ ] AI parsing validation
- [ ] UI interaction tests

## Sample Interactions

```
User: "Bench press, 3 sets of 8 reps at 135 lbs"
AI: "Nice! That's the same as last time - ready to bump up the weight next session? 💪"

User: "What should I work out today?"
AI: "You hit push yesterday, so how about some pull work? Try deadlifts or rows! 🏋️"

User: "Show me my bench press PR"
AI: "Your bench press PR is 155 lbs for 5 reps from last week! Beast mode! 🔥"
```

## Contributing

This project follows the development workflow outlined in `.cursorrules`. Key guidelines:

- Follow Swift naming conventions and best practices
- Use MVVM architecture pattern
- Write comprehensive tests for new features
- Reference Linear tickets in commits
- Maintain modular, reusable components

## License

Private project - All rights reserved.

## Version

Current version: 0.1 (MVP)
