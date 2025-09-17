project:
  name: SpotMe
  platform: iOS
  language: Swift
  ui_framework: SwiftUI
  database: CoreData
  ai_layer: LLM (GPT-4o mini / Gemini Flash-Lite)
  version: 0.1 (MVP)

overview:
  purpose: >
    A low-friction, conversational fitness tracking app.
    Users log workouts, track progress, and receive guidance from an AI-powered coach.
    The AI acts as a friend, motivator, and coach — helping track workouts, calculate weights,
    suggest routines, and remind users of personal records.
  scope:
    - Chat-based interface for logging workouts
    - AI parses and structures workout data
    - Local database storage (CoreData)
    - Contextual guidance based on past workouts
    - Scalable AI layer with secure API key management

problem_statement:
  user_pain_points:
    - Manual workout entry is cumbersome
    - Forgetting past workouts, PRs, or weights
    - Lack of motivation and accountability
  goal: >
    Create a conversational AI coach that logs workouts automatically,
    reminds users of past performance, and provides actionable guidance in a chat interface.

mvp_features:
  chat_based_logging:
    description: >
      Users type messages naturally to log workouts.
      AI parses free-text messages into structured data and stores it in CoreData.
    data_handled:
      - Exercise name (handles synonyms / clarifications)
      - Sets / reps / weight
      - Day type (push/pull/legs/shoulders)
      - PR tracking
      - Plate/barbell weight calculations
    sample_interaction:
      user: "Incline chest press machine, 80 lbs, 6 reps"
      ai: "Got it! Last time was 80 lbs x 6 reps too — keep pushing! 👍"

  contextual_guidance:
    description: >
      Suggest exercises based on recent history, avoid repeating same muscle groups,
      suggest rest days, remind user of PRs, and offer motivational responses.

  local_storage:
    description: Store workouts on device using CoreData.
    entities:
      workout:
        attributes: date, dayType, notes
      exercise:
        attributes: name, sets, reps, weight, totalWeight, prFlag
        relationship: belongs to Workout
    queries:
      - fetch last 7 days
      - fetch PRs per exercise

  ui_design:
    description: >
      Chat interface similar to ChatGPT iOS app.
      Left sidebar shows past conversations with day type.
      Right sidebar (future) shows dashboard for stats and PRs.
    components:
      - ChatBubble
      - ChatInputBar
      - ChatList / ScrollView
      - TypingIndicator
      - Sidebar

  ai_layer:
    description: >
      Handles message parsing, structured data extraction, guidance, and conversation tone.
    system_prompt: >
      "You are a Gen Z fitness coach and accountability buddy. Be casual, motivational,
      and slightly playful. Use short, chatty messages with occasional emojis.
      Track user workouts (reps/sets/exercises) and suggest new ones based on recent history."
    scalability:
      - Abstract AI behind single interface to switch models easily
      - Load model configuration from environment variables
      - Protect API keys (env variables / Keychain)
      - Modular AI logic for future replacement
      - Handle errors (rate limits, invalid responses)

technical_considerations:
  programming_language: Swift
  ui_framework: SwiftUI
  database: CoreData
  ai_models: GPT-4o mini / Gemini Flash-Lite
  api_key_management: Environment variables or Keychain
  prompt_engineering: Include last 7 days of workouts in AI call

project_plan:
  phase_1: Project setup (Xcode + MCP + Cursor rules)
  phase_2: Database schema & helpers
  phase_3: UI components
  phase_4: AI integration & parsing logic (secure & scalable)
  phase_5: Chat flow & conversation logic
  phase_6: Testing & QA
  phase_7: Optional enhancements (dashboard, HealthKit, multi-device sync)

cursor_integration:
  guidelines:
    - Always reference PRD
    - Break tasks into Linear tickets
    - Map Figma → SwiftUI using MCP
    - Treat each ticket as self-contained

mvp_success_criteria:
  - Workouts logged via chat naturally
  - AI parses and stores workouts correctly
  - Last 7 days of data influence suggestions
  - Chat interface is responsive
  - CoreData storage works offline

future_enhancements:
  - Dashboard with PRs, charts, totals
  - Apple HealthKit integration
  - Multi-device sync via Supabase
  - Gamification / streaks / social features



  MVP Flow Diagram

  [User Opens App]
        |
        v
[Chat Interface]
(User types a message)
        |
        v
[App Pre-Processing Layer]
- Capture user message
- Query CoreData for last 7 days of workouts
- Format context for AI
        |
        v
[AI Layer (LLM)]
(System prompt: Gen Z fitness coach)
- Receives user message + historical context
- Parses free-text to structured data
- Generates conversational response
- Suggests exercises / reps / weights
        |
        v
[AI Output Handler]
- Extract structured workout info:
    - Exercise name
    - Sets / Reps / Weight / Total weight
    - Day type (push/pull/legs)
    - PR flags
- Format chat message for display
        |
        v
[CoreData Storage]
- Store structured workout data
    - Workout entity
    - Exercise entity
- Update PRs if necessary
        |
        v
[Chat UI Display]
- Show AI message in chat
- Include motivational text / guidance
- Scroll to latest message
        |
        v
[Next User Message]
- Loop repeats