# Peblo Story Buddy

A Flutter-based interactive storytelling experience built for the Peblo Mobile App Developer Challenge.

## Overview

Peblo Story Buddy is a child-friendly storytelling application that combines text-to-speech narration with an interactive quiz experience. The app narrates a short story about Pip the Robot and then presents a quiz generated from structured JSON data.

The experience is designed to be lightweight, responsive, and suitable for children using mid-range Android devices.

## Framework Choice

I chose Flutter because it provides a single codebase, fast development workflow, smooth animations, and excellent support for Android devices, which aligns with Peblo's target audience.

## Features

* Interactive AI Buddy character
* Story narration using Flutter TTS
* Loading and speaking states
* Error handling with retry support
* Data-driven quiz rendering
* Dynamic option generation
* Wrong-answer feedback
* Success state with confetti celebration
* Responsive single-screen experience

## Story Flow

Idle State

↓

Preparing Audio

↓

Story Narration

↓

Quiz Reveal

↓

Wrong Answer Feedback or Success Celebration

## Audio Handling

The application uses Flutter TTS for narration.

Implemented states:

* Preparing
* Speaking
* Finished
* Error

If narration fails, the user receives a friendly retry option instead of the application becoming unresponsive.

## Data-Driven Quiz

The quiz is generated from JSON data instead of hardcoded UI elements.

Example structure:

```json
{
  "question": "What colour was Pip the Robot's lost gear?",
  "options": ["Red", "Green", "Blue", "Yellow"],
  "answer": "Blue"
}
```

The renderer supports different question text and varying numbers of options without requiring UI changes.

## State Management

The project uses Provider-based state management to separate story state and quiz state from the UI layer.

## Performance Considerations

Optimizations performed:

* Lightweight widget tree
* Minimal rebuilds
* Efficient animation usage
* Native device TTS
* Small asset footprint
* Responsive layout for mid-range Android devices

## Caching Approach

Current implementation uses device-native TTS.

If remote audio generation is introduced in the future, generated audio files can be cached locally using Flutter cache management packages to reduce network calls and improve performance.

## Error Handling

Handled scenarios:

* TTS initialization failure
* Narration interruption
* Retry support
* Safe state transitions

## AI Usage & Judgment

AI tools were used for research, implementation guidance, debugging assistance, and evaluating alternative approaches.

One suggestion that was not adopted was introducing multiple nested animation controllers for several UI elements. A simpler animation structure was selected to keep the application lightweight and maintain smooth performance on modest Android devices.

## Project Structure

```text
lib/
├── models/
├── providers/
├── services/
├── screens/
├── widgets/
└── main.dart
```

## Screenshots

Add screenshots here:

* Home Screen
* Story Narration
* Quiz Display
* Wrong Answer Feedback
* Success State

## Run Instructions

```bash
flutter pub get
flutter run
```

## Author

Nancy Khandelwal

