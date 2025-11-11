import 'dart:async';
import 'dart:math';
import 'package:flutter/material.dart';

void main() {
  runApp(const TapTargetGame());
}

class TapTargetGame extends StatelessWidget {
  const TapTargetGame({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Tap Target Game',
      debugShowCheckedModeBanner: false,
      theme: ThemeData(
        colorScheme: ColorScheme.fromSeed(seedColor: Colors.deepPurple),
      ),
      home: const TapTargetScreen(),
    );
  }
}

class TapTargetScreen extends StatefulWidget {
  const TapTargetScreen({super.key});

  @override
  State<TapTargetScreen> createState() => _TapTargetScreenState();
}

class _TapTargetScreenState extends State<TapTargetScreen> {
  final Random _random = Random();
  double targetX = 150;
  double targetY = 300;
  double targetScale = 1.0;
  Color bgColor = Colors.deepPurple.shade50;
  int score = 0;
  int timeLeft = 30;
  bool gameStarted = false;

  Timer? moveTimer;
  Timer? countdownTimer;

  void startGame() {
    setState(() {
      score = 0;
      timeLeft = 30;
      bgColor = Colors.deepPurple.shade50;
      gameStarted = true;
    });

    // Start moving target every second
    moveTimer = Timer.periodic(const Duration(seconds: 1), (_) {
      moveTarget();
    });

    // Countdown timer
    countdownTimer = Timer.periodic(const Duration(seconds: 1), (_) {
      if (timeLeft > 0) {
        setState(() => timeLeft--);
      } else {
        stopGame();
        showDialog(
          context: context,
          builder: (_) => AlertDialog(
            title: const Text("⏱️ Time’s Up!"),
            content: Text("Your final score: $score"),
            actions: [
              TextButton(
                onPressed: () => Navigator.pop(context),
                child: const Text("OK"),
              ),
            ],
          ),
        );
      }
    });
  }

  void stopGame() {
    moveTimer?.cancel();
    countdownTimer?.cancel();
    setState(() {
      gameStarted = false;
    });
  }

  void moveTarget() {
    setState(() {
      targetX = _random.nextDouble() * 300;
      targetY = _random.nextDouble() * 500;
    });
  }

  void tapTarget() {
    if (!gameStarted) return;

    setState(() {
      score++;
      targetScale = 1.3;
      bgColor = Color.lerp(
        Colors.deepPurple.shade50,
        Colors.purpleAccent.shade100,
        (score % 10) / 10,
      )!;
    });

    Future.delayed(const Duration(milliseconds: 150), () {
      if (mounted) {
        setState(() => targetScale = 1.0);
      }
    });

    moveTarget();
  }

  @override
  void dispose() {
    moveTimer?.cancel();
    countdownTimer?.cancel();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: AnimatedContainer(
        duration: const Duration(milliseconds: 400),
        color: bgColor,
        child: Stack(
          children: [
            // Score and timer
            Positioned(
              top: 40,
              left: 20,
              right: 20,
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Text(
                    "Score: $score",
                    style: const TextStyle(
                        fontSize: 22, fontWeight: FontWeight.bold),
                  ),
                  Text(
                    "Time: $timeLeft",
                    style: const TextStyle(
                        fontSize: 22, fontWeight: FontWeight.bold),
                  ),
                ],
              ),
            ),

            // Animated target
            AnimatedPositioned(
              duration: const Duration(milliseconds: 500),
              curve: Curves.easeInOut,
              left: targetX,
              top: targetY,
              child: GestureDetector(
                onTap: tapTarget,
                child: AnimatedScale(
                  scale: targetScale,
                  duration: const Duration(milliseconds: 150),
                  curve: Curves.easeOutBack,
                  child: Container(
                    width: 70,
                    height: 70,
                    decoration: BoxDecoration(
                      gradient: const LinearGradient(
                        colors: [Colors.deepPurple, Colors.purpleAccent],
                        begin: Alignment.topLeft,
                        end: Alignment.bottomRight,
                      ),
                      shape: BoxShape.circle,
                      boxShadow: [
                        BoxShadow(
                          color: Colors.purple.withOpacity(0.5),
                          blurRadius: 10,
                          spreadRadius: 3,
                        ),
                      ],
                    ),
                    child: const Center(
                      child: Text(
                        "🎯",
                        style: TextStyle(fontSize: 30),
                      ),
                    ),
                  ),
                ),
              ),
            ),

            // Start/Stop button
            Align(
              alignment: Alignment.bottomCenter,
              child: Padding(
                padding: const EdgeInsets.all(20),
                child: ElevatedButton(
                  onPressed: gameStarted ? stopGame : startGame,
                  style: ElevatedButton.styleFrom(
                    backgroundColor:
                        gameStarted ? Colors.redAccent : Colors.green,
                    minimumSize: const Size(double.infinity, 55),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(16),
                    ),
                  ),
                  child: Text(
                    gameStarted ? "Stop Game" : "Start Game",
                    style: const TextStyle(
                        fontSize: 20,
                        color: Colors.white,
                        fontWeight: FontWeight.bold),
                  ),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
