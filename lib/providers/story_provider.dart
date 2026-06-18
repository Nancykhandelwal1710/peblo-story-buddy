import 'package:flutter/material.dart';

enum StoryState { idle, preparing, speaking, finished, error }

class StoryProvider extends ChangeNotifier {
  StoryState storyState = StoryState.idle;
  String? selectedAnswer;
  bool quizSuccess = false;

  void startPreparing() {
    storyState = StoryState.preparing;
    selectedAnswer = null;
    quizSuccess = false;
    notifyListeners();
  }

  void startSpeaking() {
    storyState = StoryState.speaking;
    notifyListeners();
  }

  void finishStory() {
    storyState = StoryState.finished;
    notifyListeners();
  }

  void showError() {
    storyState = StoryState.error;
    notifyListeners();
  }

  void chooseAnswer(String option, String correctAnswer) {
    selectedAnswer = option;

    if (option == correctAnswer) {
      quizSuccess = true;
    }

    notifyListeners();
  }
}
