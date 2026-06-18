import 'dart:math';

import 'package:confetti/confetti.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_tts/flutter_tts.dart';
import 'models/quiz_data.dart';
import 'services/story_service.dart';

void main() {
  runApp(const PebloStoryBuddyApp());
}

class PebloStoryBuddyApp extends StatelessWidget {
  const PebloStoryBuddyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Peblo Story Buddy',
      debugShowCheckedModeBanner: false,
      theme: ThemeData(useMaterial3: true),
      home: const StoryBuddyScreen(),
    );
  }
}

enum StoryState { idle, preparing, speaking, finished, error }



class StoryBuddyScreen extends StatefulWidget {
  const StoryBuddyScreen({super.key});

  @override
  State<StoryBuddyScreen> createState() => _StoryBuddyScreenState();
}

class _StoryBuddyScreenState extends State<StoryBuddyScreen>
    with SingleTickerProviderStateMixin {
  final FlutterTts flutterTts = FlutterTts();
  late final ConfettiController confettiController;
  late final AnimationController shakeController;
  late final Animation<double> shakeAnimation;

  StoryState storyState = StoryState.idle;
  String? selectedAnswer;
  bool quizSuccess = false;

  final String storyText = StoryService.storyText;

  final QuizData quiz = StoryService.getQuiz();
  

  @override
  void initState() {
    super.initState();

    confettiController =
        ConfettiController(duration: const Duration(seconds: 2));

    shakeController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 420),
    );

    shakeAnimation = Tween<double>(begin: 0, end: 1).animate(
      CurvedAnimation(parent: shakeController, curve: Curves.elasticIn),
    );

    flutterTts.setCompletionHandler(() {
      if (!mounted) return;
      setState(() {
        storyState = StoryState.finished;
      });
    });

    flutterTts.setErrorHandler((message) {
      if (!mounted) return;
      setState(() {
        storyState = StoryState.error;
      });
    });
  }

  Future<void> readStory() async {
    try {
      setState(() {
        storyState = StoryState.preparing;
        selectedAnswer = null;
        quizSuccess = false;
      });

      await flutterTts.setLanguage("en-IN");
      await flutterTts.setSpeechRate(0.45);
      await flutterTts.setPitch(1.05);

      setState(() {
        storyState = StoryState.speaking;
      });

      await flutterTts.speak(storyText);
    } catch (_) {
      setState(() {
        storyState = StoryState.error;
      });
    }
  }

  void checkAnswer(String option) {
    if (quizSuccess) return;

    setState(() {
      selectedAnswer = option;
    });

    if (option == quiz.answer) {
      HapticFeedback.lightImpact();
      setState(() {
        quizSuccess = true;
      });
      confettiController.play();
    } else {
      HapticFeedback.mediumImpact();
      shakeController.forward(from: 0);
    }
  }

  String get buttonText {
    if (storyState == StoryState.preparing) return "Getting Pip ready...";
    if (storyState == StoryState.speaking) return "Pip is reading...";
    if (storyState == StoryState.error) return "Try Again";
    return "Read Me a Story";
  }

  String get helperText {
    if (storyState == StoryState.preparing) return "One tiny second...";
    if (storyState == StoryState.speaking) return "Listen carefully!";
    if (storyState == StoryState.finished && quizSuccess) {
      return "You helped Pip find his gear!";
    }
    if (storyState == StoryState.finished) return "Now help Pip answer this.";
    if (storyState == StoryState.error) {
      return "Oops, Pip could not speak. Please try again.";
    }
    return "Listen to Pip and answer a tiny question.";
  }

  @override
  void dispose() {
    flutterTts.stop();
    confettiController.dispose();
    shakeController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final bool isBusy =
        storyState == StoryState.preparing || storyState == StoryState.speaking;

    return Scaffold(
      backgroundColor: const Color(0xFFFFF4D8),
      body: Stack(
        children: [
          SafeArea(
            child: Padding(
              padding: const EdgeInsets.all(22),
              child: Column(
                children: [
                  const SizedBox(height: 10),
                  const Text(
                    "Pip's Story Corner",
                    style: TextStyle(
                      fontSize: 30,
                      fontWeight: FontWeight.w800,
                      color: Color(0xFF3D2B7A),
                    ),
                  ),
                  const SizedBox(height: 8),
                  Text(
                    helperText,
                    textAlign: TextAlign.center,
                    style: const TextStyle(
                      fontSize: 16,
                      color: Color(0xFF6F6298),
                    ),
                  ),
                  const SizedBox(height: 24),
                  AnimatedScale(
                    scale: storyState == StoryState.speaking ? 1.06 : 1,
                    duration: const Duration(milliseconds: 350),
                    child: Container(
                      height: 140,
                      width: 140,
                      decoration: BoxDecoration(
                        color: const Color(0xFFC7F0FF),
                        borderRadius: BorderRadius.circular(36),
                        boxShadow: [
                          BoxShadow(
                            color: Colors.black.withOpacity(0.12),
                            blurRadius: 18,
                            offset: const Offset(0, 8),
                          ),
                        ],
                      ),
                      child: Center(
                        child: Text(
                          quizSuccess ? "😄" : "🤖",
                          style: const TextStyle(fontSize: 76),
                        ),
                      ),
                    ),
                  ),
                  const SizedBox(height: 24),
                  storyCard(),
                  const SizedBox(height: 18),
                  if (storyState == StoryState.finished) quizCard(),
                  const Spacer(),
                  SizedBox(
                    width: double.infinity,
                    height: 60,
                    child: ElevatedButton(
                      onPressed: isBusy ? null : readStory,
                      style: ElevatedButton.styleFrom(
                        backgroundColor: const Color(0xFFFF8A3D),
                        foregroundColor: Colors.white,
                        disabledBackgroundColor: const Color(0xFFFFC49B),
                        elevation: 6,
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(22),
                        ),
                      ),
                      child: Text(
                        buttonText,
                        style: const TextStyle(
                          fontSize: 19,
                          fontWeight: FontWeight.w800,
                        ),
                      ),
                    ),
                  ),
                  const SizedBox(height: 16),
                ],
              ),
            ),
          ),
          Align(
            alignment: Alignment.topCenter,
            child: ConfettiWidget(
              confettiController: confettiController,
              blastDirection: pi / 2,
              emissionFrequency: 0.05,
              numberOfParticles: 18,
              gravity: 0.25,
            ),
          ),
        ],
      ),
    );
  }

  Widget storyCard() {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(26),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.10),
            blurRadius: 18,
            offset: const Offset(0, 8),
          ),
        ],
      ),
      child: Text(
        storyText,
        textAlign: TextAlign.center,
        style: const TextStyle(
          fontSize: 19,
          height: 1.45,
          fontWeight: FontWeight.w500,
          color: Color(0xFF333333),
        ),
      ),
    );
  }

  Widget quizCard() {
    return AnimatedBuilder(
      animation: shakeAnimation,
      builder: (context, child) {
        final dx = sin(shakeAnimation.value * pi * 6) * 8;
        return Transform.translate(
          offset: Offset(dx, 0),
          child: child,
        );
      },
      child: AnimatedOpacity(
        opacity: storyState == StoryState.finished ? 1 : 0,
        duration: const Duration(milliseconds: 450),
        child: Container(
          width: double.infinity,
          padding: const EdgeInsets.all(18),
          decoration: BoxDecoration(
            color: const Color(0xFFEAF8FF),
            borderRadius: BorderRadius.circular(24),
            border: Border.all(
              color: const Color(0xFFB6E7FF),
              width: 2,
            ),
          ),
          child: Column(
            children: [
              Text(
                quiz.question,
                textAlign: TextAlign.center,
                style: const TextStyle(
                  fontSize: 19,
                  height: 1.25,
                  fontWeight: FontWeight.w800,
                  color: Color(0xFF2F337A),
                ),
              ),
              const SizedBox(height: 14),
              Wrap(
                spacing: 10,
                runSpacing: 10,
                alignment: WrapAlignment.center,
                children: quiz.options.map((option) {
                  return optionButton(option);
                }).toList(),
              ),
              if (quizSuccess) ...[
                const SizedBox(height: 14),
                const Text(
                  "Success! Pip found the shiny blue gear.",
                  textAlign: TextAlign.center,
                  style: TextStyle(
                    color: Color(0xFF278544),
                    fontSize: 16,
                    fontWeight: FontWeight.w800,
                  ),
                ),
              ] else if (selectedAnswer != null &&
                  selectedAnswer != quiz.answer) ...[
                const SizedBox(height: 14),
                const Text(
                  "Almost! Try once more.",
                  style: TextStyle(
                    color: Color(0xFFD86B3D),
                    fontSize: 15,
                    fontWeight: FontWeight.w700,
                  ),
                ),
              ],
            ],
          ),
        ),
      ),
    );
  }

  Widget optionButton(String option) {
    final bool isCorrect = quizSuccess && option == quiz.answer;
    final bool isWrong =
        selectedAnswer == option && option != quiz.answer && !quizSuccess;

    Color bgColor = Colors.white;
    Color textColor = const Color(0xFF333333);

    if (isCorrect) {
      bgColor = const Color(0xFF9BE7A8);
      textColor = const Color(0xFF155D26);
    } else if (isWrong) {
      bgColor = const Color(0xFFFFD5C8);
      textColor = const Color(0xFF9F3D22);
    }

    return GestureDetector(
      onTap: () => checkAnswer(option),
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 220),
        padding: const EdgeInsets.symmetric(horizontal: 22, vertical: 13),
        decoration: BoxDecoration(
          color: bgColor,
          borderRadius: BorderRadius.circular(18),
          boxShadow: [
            BoxShadow(
              color: Colors.black.withOpacity(0.08),
              blurRadius: 10,
              offset: const Offset(0, 5),
            ),
          ],
        ),
        child: Text(
          option,
          style: TextStyle(
            color: textColor,
            fontSize: 16,
            fontWeight: FontWeight.w800,
          ),
        ),
      ),
    );
  }
}
