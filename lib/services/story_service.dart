import '../models/quiz_data.dart';

class StoryService {
  static const storyText =
      "Once upon a time, a clever little robot named Pip lost his shiny blue gear in the Whispering Woods...";

  static QuizData getQuiz() {
    return QuizData.fromJson({
      "question": "What colour was Pip the Robot's lost gear?",
      "options": ["Red", "Green", "Blue", "Yellow"],
      "answer": "Blue"
    });
  }
}
