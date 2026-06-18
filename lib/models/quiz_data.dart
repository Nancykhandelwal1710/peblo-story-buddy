class QuizData {
  final String question;
  final List<String> options;
  final String answer;

  QuizData({
    required this.question,
    required this.options,
    required this.answer,
  });

  factory QuizData.fromJson(Map<String, dynamic> json) {
    return QuizData(
      question: json['question'],
      options: List<String>.from(json['options']),
      answer: json['answer'],
    );
  }
}
