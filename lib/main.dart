import 'dart:math';
import 'package:google_fonts/google_fonts.dart';
import 'package:confetti/confetti.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_tts/flutter_tts.dart';
import 'package:flutter_animate/flutter_animate.dart';
import 'models/quiz_data.dart';
import 'services/story_service.dart';
import 'package:google_fonts/google_fonts.dart';

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
      theme: ThemeData(
        useMaterial3: true,
        textTheme: GoogleFonts.baloo2TextTheme(), 
      ),
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
      setState(() => storyState = StoryState.finished);
    });

    flutterTts.setErrorHandler((message) {
      if (!mounted) return;
      setState(() => storyState = StoryState.error);
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
      await flutterTts.setPitch(1.08);

      setState(() => storyState = StoryState.speaking);

      await flutterTts.speak(storyText);
    } catch (_) {
      setState(() => storyState = StoryState.error);
    }
  }

  void checkAnswer(String option) {
    if (quizSuccess) return;

    setState(() => selectedAnswer = option);

    if (option == quiz.answer) {
      HapticFeedback.lightImpact();
      setState(() => quizSuccess = true);
      confettiController.play();
    } else {
      HapticFeedback.mediumImpact();
      shakeController.forward(from: 0);
    }
  }

  String get buttonText {
    if (storyState == StoryState.preparing) return "Getting Pip Ready...";
    if (storyState == StoryState.speaking) return "Pip is Reading...";
    if (storyState == StoryState.error) return "Try Again";
    return "Read Me a Story";
  }

  String get helperText {
    if (storyState == StoryState.preparing) return "Pip is warming up his voice!";
    if (storyState == StoryState.speaking) return "Listen carefully, little explorer!";
    if (storyState == StoryState.finished && quizSuccess) {
      return "Yay! Pip found his shiny gear!";
    }
    if (storyState == StoryState.finished) return "Can you help Pip now?";
    if (storyState == StoryState.error) return "Oops! Pip needs one more try.";
    return "A tiny story adventure is waiting.";
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
      body: Stack(
        children: [
          Container(
            decoration: const BoxDecoration(
              gradient: LinearGradient(
                colors: [
                  Color(0xFFFFE7A8),
                  Color(0xFFC7F0FF),
                  Color(0xFFEAD7FF),
                ],
                begin: Alignment.topLeft,
                end: Alignment.bottomRight,
              ),
            ),
          ),
          const Positioned(
            bottom: 0,
            left: 0,
            right: 0,
            child: MountainBackground(),
          ),
          MovingCloud(top: 60, size: 140, duration: 40, startOffset: -200),
          MovingCloud(top: 120, size: 100, duration: 50, startOffset: 300),
          MovingCloud(top: 190, size: 120, duration: 60, startOffset: 800),
          MovingCloud(top: 90, size: 90, duration: 70, startOffset: 1300),
          
          SafeArea(
            child: SingleChildScrollView(
              padding: const EdgeInsets.all(22),
              child: Column(
                children: [
                  const SizedBox(height: 8),
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Container(
                        padding: const EdgeInsets.symmetric(
                          horizontal: 20,
                          vertical: 12,
                        ),
                        decoration: BoxDecoration(
                          color: Colors.white.withOpacity(0.55),
                          borderRadius: BorderRadius.circular(28),
                        ),
                        child: Text(
                          "Pip's Story Corner",
                          style: GoogleFonts.schoolbell(
                            fontSize: 36,
                            fontWeight: FontWeight.bold,
                            color:const Color(0xFF3D2B7A),
                            shadows: const [
                              Shadow(
                                color: Colors.black12,
                                blurRadius: 4,
                                offset: Offset(2, 2),
                              ),
                            ],
                          ),
                        ),
                      ),
                      Container(
                        padding: const EdgeInsets.symmetric(
                          horizontal: 14,
                          vertical: 8,
                        ),
                        decoration: BoxDecoration(
                          color: const Color(0xFFFFE9A8),
                          borderRadius: BorderRadius.circular(18),
                        ),
                        child: Text(
                          quizSuccess ? "⭐ 20 XP" : "⭐ 10 XP",
                          style: const TextStyle(
                            fontWeight: FontWeight.w900,
                            color: Color(0xFF7A4A00),
                          ),
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 10),
                  Text(
                    helperText,
                    textAlign: TextAlign.center,
                    style: GoogleFonts.baloo2(
                      fontSize: 18,
                      fontWeight: FontWeight.w600,
                      color: Color(0xFF5D4D91),
                    ),
                  ),
                  const SizedBox(height: 24),
                  buddyBox(),
                  const SizedBox(height: 18),
                  storyCard()
                    .animate()
                    .fadeIn(duration: 700.ms)
                    .slideY(begin: 0.15, end: 0),
                  const SizedBox(height: 18),
                  if (storyState == StoryState.finished)
                    quizCard()
                        .animate()
                        .fadeIn(duration: 500.ms)
                        .slideY(
                          begin: 0.25,
                          end: 0,
                          curve: Curves.easeOutBack,
                        ),
                  const SizedBox(height: 24),
                  SizedBox(
                    width: double.infinity,
                    height: 62,
                    child: ElevatedButton(
                      onPressed: isBusy ? null : readStory,
                      style: ElevatedButton.styleFrom(
                        backgroundColor: const Color(0xFF5B3DFF),
                        foregroundColor: Colors.white,
                        disabledBackgroundColor: const Color(0xFFFFA65C),
                        elevation: storyState == StoryState.speaking ? 12 : 8,
                        shadowColor: storyState == StoryState.speaking
                            ? const Color(0xFFFFA65C)
                            : const Color(0xFF5B3DFF),
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(24),
                        ),
                      ),
                      child: Row(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          Icon(
                            Icons.menu_book_rounded,
                            size: 28,
                            color: storyState == StoryState.speaking
                                ? Color(0xFF5B3DFF)
                                : const Color(0xFFFFA65C),
                          ),
                          const SizedBox(width: 12),
                          Text(
                            buttonText,
                            style: GoogleFonts.fredoka(
                              fontSize: 22,
                              fontWeight: FontWeight.w600,
                              color: storyState == StoryState.speaking
                                  ? Color(0xFF5B3DFF)
                                  : const Color(0xFFFFA65C),
                              
                            ),
                          ),
                        ],
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
              numberOfParticles: 20,
              gravity: 0.25,
            ),
          ),
        ],
      ),
    );
  }

  Widget buddyBox() {
    return Column(
      children: [
        Container(
          padding: const EdgeInsets.symmetric(horizontal: 18, vertical: 14),
          decoration: BoxDecoration(
            color: Colors.white,
            borderRadius: BorderRadius.circular(24),
            boxShadow: [
              BoxShadow(
                color: Colors.black.withOpacity(0.10),
                blurRadius: 14,
                offset: const Offset(0, 7),
              ),
            ],
          ),
          child: Text(
            quizSuccess
                ? "You found my gear! Thank you!"
                : "Hi explorer, I am Pip. Listen to my story!",
            textAlign: TextAlign.center,
            style: const TextStyle(
              fontSize: 17,
              height: 1.25,
              fontWeight: FontWeight.w800,
              color: Color(0xFF3D2B7A),
            ),
          ),
        ),
        const SizedBox(height: 12),
        AnimatedScale(
          scale: storyState == StoryState.speaking ? 1.06 : 1,
          duration: const Duration(milliseconds: 350),
          child: Container(
            height: 178,
            width: 178,
            padding: const EdgeInsets.all(16),
            decoration: BoxDecoration(
              shape: BoxShape.circle,
              color: const Color(0xFFDDF7FF),
              boxShadow: [
                BoxShadow(
                  color: Colors.black.withOpacity(0.14),
                  blurRadius: 22,
                  offset: const Offset(0, 10),
                ),
              ],
            ),
            child: Image.asset(
              'assets/images/pip_robot.png',
              fit: BoxFit.contain,
            ),
          ),
        )
      
            .animate(
              onPlay: (controller) => controller.repeat(reverse: true),
            )
            .moveY(
              begin: 0,
              end: -10,
              duration: 1200.ms,
              curve: Curves.easeInOut,
            ),
        const SizedBox(height: 10),
        Container(
          padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
          decoration: BoxDecoration(
            color: quizSuccess ? const Color(0xFFFFD66B) : Colors.white,
            borderRadius: BorderRadius.circular(22),
          ),
          child: Text(
            quizSuccess ? "Pip Helper Badge" : "Story Buddy",
            style: const TextStyle(
              fontSize: 15,
              fontWeight: FontWeight.w900,
              color: Color(0xFF3D2B7A),
            ),
          ),
        ),
      ],
    );
  }


  Widget storyCard() {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: const Color(0xFFFFFDF4),
        borderRadius: BorderRadius.circular(30),
        border: Border.all(
          color: const Color(0xFFFFC94A),
          width: 3,
        ),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.10),
            blurRadius: 18,
            offset: const Offset(0, 8),
          ),
        ],
      ),
      child: Column(
        children: [
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 7),
            decoration: BoxDecoration(
              color: const Color(0xFFFFE9A8),
              borderRadius: BorderRadius.circular(18),
            ),
            child: Text(
              "Today's Story",
              style: GoogleFonts.fredoka(
                fontSize: 20,
                fontWeight: FontWeight.w700,
                color: const Color(0xFF7A4A00),
              ),
            ),
          ),
        
          const SizedBox(height: 14),
          Text(
            storyText,
            textAlign: TextAlign.center,
            style: GoogleFonts.baloo2(
              fontSize: 20,
              height: 1.5,
              fontWeight: FontWeight.w600,
              color: Color(0xFF333333),
            ),
          ), 
        ],
      ),
    );
  }

  Widget quizCard() {
    return AnimatedBuilder(
      animation: shakeAnimation,
      builder: (context, child) {
        final dx = sin(shakeAnimation.value * pi * 6) * 8;
        return Transform.translate(offset: Offset(dx, 0), child: child);
      },
      child: Container(
        width: double.infinity,
        padding: const EdgeInsets.all(18),
        decoration: BoxDecoration(
          color: const Color(0xFFF0FFF6),
          borderRadius: BorderRadius.circular(30),
          border: Border.all(color: const Color(0xFF66D98F), width: 3),
          boxShadow: [
            BoxShadow(
              color: Colors.black.withOpacity(0.10),
              blurRadius: 16,
              offset: const Offset(0, 8),
            ),
          ],
        ),
        child: Column(
          children: [
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 7),
              decoration: BoxDecoration(
                color: const Color(0xFFD9FFE5),
                borderRadius: BorderRadius.circular(18),
              ),
              child: Text(
                "Pip's Mission",
                style: GoogleFonts.fredoka(
                  fontSize: 22,
                  fontWeight: FontWeight.w700,
                  color:Color(0xFF1F7A3D),
                ),
              ),
            ),
            const SizedBox(height: 8),
            const Text(
              "Help Pip remember his missing gear!",
              textAlign: TextAlign.center,
              style: TextStyle(
                fontSize: 14,
                fontWeight: FontWeight.w700,
                color: Color(0xFF4D775C),
              ),
            ),
          
            const SizedBox(height: 12),
            Text(
              quiz.question,
              textAlign: TextAlign.center,
              style: GoogleFonts.fredoka(
                fontSize: 22,
                height: 1.3,
                fontWeight: FontWeight.w700,
                color: Color(0xFF2F337A),
              ),
            ),
            const SizedBox(height: 14),
            Wrap(
              spacing: 10,
              runSpacing: 10,
              alignment: WrapAlignment.center,
              children: quiz.options.map((option) => optionButton(option)).toList(),
            ),
            if (quizSuccess) ...[
              const SizedBox(height: 16),
              (
                Container(
                  padding: const EdgeInsets.all(14),
                  decoration: BoxDecoration(
                    color: const Color(0xFFFFF0B8),
                    borderRadius: BorderRadius.circular(22),
                    border: Border.all(
                      color: const Color(0xFFFFC94A),
                      width: 2,
                    ),
                  ),
                  child: const Column(
                    children: [
                      Text(
                        "🎉 Mission Complete!",
                        textAlign: TextAlign.center,
                        style: TextStyle(
                          color: Color(0xFF7A4A00),
                          fontSize: 17,
                          fontWeight: FontWeight.w900,
                        ),
                      ),
                      SizedBox(height: 4),
                      Text(
                        "⭐ You helped Pip find his shiny blue gear.\n+10 XP earned",
                        textAlign: TextAlign.center,
                        style: TextStyle(
                          color: Color(0xFF7A4A00),
                          fontSize: 14,
                          fontWeight: FontWeight.w700,
                        ),
                      ),
                    ],
                  ),
                )
              )
              .animate()
              .scale(
                begin: const Offset(0.8, 0.8),
                end: const Offset(1, 1),
                duration: 500.ms,
              ),
            ] else if (selectedAnswer != null && selectedAnswer != quiz.answer) ...[
              const SizedBox(height: 14),
              const Text(
                "Almost! Try once more.",
                style: TextStyle(
                  color: Color(0xFFD86B3D),
                  fontSize: 15,
                  fontWeight: FontWeight.w800,
                ),
              ),
            ],
          ],
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
        padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 14),
        decoration: BoxDecoration(
          color: bgColor,
          borderRadius: BorderRadius.circular(20),
          border: Border.all(color: const Color(0xFF3D2B7A), width: 1.5),
          boxShadow: [
            BoxShadow(
              color: Colors.black.withOpacity(0.09),
              blurRadius: 10,
              offset: const Offset(0, 5),
            ),
          ],
        ),
        child: Text(
          option,
          style: GoogleFonts.fredoka(
            color: textColor,
            fontSize: 17,
            fontWeight: FontWeight.w600,
          ),
        ),
      ),
    );
  }
}
class MovingCloud extends StatefulWidget {
  final double top;
  final double size;
  final int duration;
  final double startOffset;

  const MovingCloud({
    super.key,
    required this.top,
    required this.size,
    required this.duration,
    required this.startOffset,
  });

  @override
  State<MovingCloud> createState() => _MovingCloudState();
}

class _MovingCloudState extends State<MovingCloud>
    with SingleTickerProviderStateMixin {
  late AnimationController controller;

  @override
  void initState() {
    super.initState();

    controller = AnimationController(
      vsync: this,
      duration: Duration(seconds: widget.duration),
    )..repeat();
  }

  @override
  void dispose() {
    controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final screenWidth = MediaQuery.of(context).size.width;
    final totalWidth = screenWidth + 1800;

    return AnimatedBuilder(
      animation: controller,
      builder: (context, child) {
        
        final x =
            (controller.value * totalWidth + widget.startOffset) %
              totalWidth -
            widget.size;

        return Positioned(
          top: widget.top,
          left: x,
          child: child!,
        );
      },
      
      child: Icon(
        Icons.cloud,
        size: widget.size,
        color: Colors.white.withOpacity(0.85),
        shadows: [
          Shadow(
            color: Colors.black.withOpacity(0.18),
            blurRadius: 18,
            offset: const Offset(3, 5),
          ),
        ],
      ),
    );
  }
}

class MountainBackground extends StatelessWidget {
  const MountainBackground({super.key});

  @override
  Widget build(BuildContext context) {
    return CustomPaint(
      size: Size(MediaQuery.of(context).size.width, 260),
      painter: MountainPainter(),
    );
  }
}

class MountainPainter extends CustomPainter {
  @override
  void paint(Canvas canvas, Size size) {
    final backMountain = Paint()
      ..color = const Color(0xFF466A9F).withOpacity(0.75);

    final frontMountain = Paint()
      ..color = const Color(0xFF274F7A).withOpacity(0.82);

    final hill = Paint()
      ..color = const Color(0xFF3F9B61).withOpacity(0.78);

    final backPath = Path()
      ..moveTo(0, size.height)
      ..lineTo(size.width * 0.18, size.height * 0.18)
      ..lineTo(size.width * 0.34, size.height)
      ..lineTo(size.width * 0.55, size.height * 0.26)
      ..lineTo(size.width * 0.75, size.height)
      ..lineTo(size.width * 0.92, size.height * 0.20)
      ..lineTo(size.width, size.height)
      ..close();

    canvas.drawPath(backPath, backMountain);

    final frontPath = Path()
      ..moveTo(0, size.height)
      ..lineTo(size.width * 0.12, size.height * 0.45)
      ..lineTo(size.width * 0.27, size.height)
      ..lineTo(size.width * 0.48, size.height * 0.48)
      ..lineTo(size.width * 0.66, size.height)
      ..lineTo(size.width * 0.84, size.height * 0.42)
      ..lineTo(size.width, size.height)
      ..close();

    canvas.drawPath(frontPath, frontMountain);

    final hillPath = Path()
      ..moveTo(0, size.height)
      ..quadraticBezierTo(
        size.width * 0.25,
        size.height * 0.65,
        size.width * 0.5,
        size.height * 0.82,
      )
      ..quadraticBezierTo(
        size.width * 0.75,
        size.height,
        size.width,
        size.height * 0.70,
      )
      ..lineTo(size.width, size.height)
      ..close();

    canvas.drawPath(hillPath, hill);
  }

  @override
  bool shouldRepaint(covariant CustomPainter oldDelegate) => false;
}
