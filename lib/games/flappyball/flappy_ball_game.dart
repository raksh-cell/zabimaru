import 'dart:async';
import 'dart:math';
import 'package:flutter/material.dart';
import 'package:zabimaru/screens/option_screen.dart';

class FlappyBallGame extends StatefulWidget {
  const FlappyBallGame({super.key});

  @override
  State<FlappyBallGame> createState() => _FlappyBallGameState();
}

class _FlappyBallGameState extends State<FlappyBallGame> with TickerProviderStateMixin {
  double ballY = 300;
  double velocity = 0;
  double gravity = 0.4;
  double jumpForce = -6;
  bool isGameStarted = false;
  int score = 0;
  Timer? gameLoop;

  late AnimationController _ballAnimationController;
  late AnimationController _scoreAnimationController;
  late Animation<double> _ballRotation;
  late Animation<double> _scoreScale;

  final double ballSize = 40;
  final double pillarWidth = 60;
  final double gapHeight = 300; // Increased from 200 to 300 for larger gap

  double screenHeight = 0;
  double screenWidth = 0;

  List<double> pillarX = [];
  List<double> gapTop = [];
  final Random rand = Random();

  // Dark theme colors
  final Color primaryDark = const Color(0xFF0D1117);
  final Color secondaryDark = const Color(0xFF161B22);
  final Color accentCyan = const Color(0xFF58A6FF);
  final Color accentPurple = const Color(0xFF8B5CF6);
  final Color accentOrange = const Color(0xFFFF6B35);
  final Color textLight = const Color(0xFFF0F6FC);
  final Color textMuted = const Color(0xFF8B949E);

  @override
  void initState() {
    super.initState();
    _ballAnimationController = AnimationController(
      duration: const Duration(milliseconds: 200),
      vsync: this,
    );
    _scoreAnimationController = AnimationController(
      duration: const Duration(milliseconds: 300),
      vsync: this,
    );

    _ballRotation = Tween<double>(
      begin: 0,
      end: 2 * pi,
    ).animate(CurvedAnimation(
      parent: _ballAnimationController,
      curve: Curves.easeInOut,
    ));

    _scoreScale = Tween<double>(
      begin: 1.0,
      end: 1.3,
    ).animate(CurvedAnimation(
      parent: _scoreAnimationController,
      curve: Curves.elasticOut,
    ));

    _ballAnimationController.repeat();
  }

  void startGame() {
    isGameStarted = true;
    velocity = 0;
    ballY = screenHeight / 2;
    score = 0;

    pillarX = [screenWidth + 100, screenWidth + 400];
    gapTop = [randomGapY(), randomGapY()];

    gameLoop = Timer.periodic(const Duration(milliseconds: 16), (timer) {
      setState(() {
        velocity += gravity;
        velocity *= 0.98;
        ballY += velocity;

        for (int i = 0; i < pillarX.length; i++) {
          pillarX[i] -= 1.3;

          if (pillarX[i] < -pillarWidth) {
            pillarX[i] = screenWidth;
            gapTop[i] = randomGapY();
            score++;
            _scoreAnimationController.forward().then((_) {
              _scoreAnimationController.reverse();
            });
          }

          if (_checkCollision(pillarX[i], gapTop[i])) {
            endGame();
          }
        }

        if (ballY < 0 || ballY + ballSize > screenHeight) {
          endGame();
        }
      });
    });
  }

  bool _checkCollision(double pipeX, double gapY) {
    if (pipeX < ballSize + 100 && pipeX + pillarWidth > 100) {
      if (ballY < gapY || ballY + ballSize > gapY + gapHeight) {
        return true;
      }
    }
    return false;
  }

  void flap() {
    if (!isGameStarted) {
      startGame();
    }
    setState(() {
      velocity = jumpForce;
    });
  }

  double randomGapY() {
    return 100 + rand.nextInt(250).toDouble();
  }

  void endGame() {
    gameLoop?.cancel();
    isGameStarted = false;
    showDialog(
      context: context,
      barrierDismissible: false,
      builder: (_) => AlertDialog(
        backgroundColor: secondaryDark,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(20),
          side: BorderSide(color: accentCyan.withOpacity(0.3), width: 1),
        ),
        title: Row(
          children: [
            Icon(Icons.sports_esports, color: accentOrange, size: 28),
            const SizedBox(width: 12),
            Text(
              "Game Over",
              style: TextStyle(
                color: textLight,
                fontSize: 24,
                fontWeight: FontWeight.bold,
              ),
            ),
          ],
        ),
        content: Container(
          padding: const EdgeInsets.symmetric(vertical: 20),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Container(
                padding: const EdgeInsets.all(20),
                decoration: BoxDecoration(
                  gradient: LinearGradient(
                    colors: [accentCyan.withOpacity(0.2), accentPurple.withOpacity(0.2)],
                    begin: Alignment.topLeft,
                    end: Alignment.bottomRight,
                  ),
                  borderRadius: BorderRadius.circular(15),
                  border: Border.all(color: accentCyan.withOpacity(0.3)),
                ),
                child: Column(
                  children: [
                    Text(
                      "Final Score",
                      style: TextStyle(
                        color: textMuted,
                        fontSize: 16,
                        fontWeight: FontWeight.w500,
                      ),
                    ),
                    const SizedBox(height: 8),
                    Text(
                      "$score",
                      style: TextStyle(
                        color: accentCyan,
                        fontSize: 48,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),
        ),
        actions: [
          Container(
            width: double.infinity,
            child: Row(
              children: [
                Expanded(
                  child: TextButton(
                    onPressed: () {
                      Navigator.of(context).pushAndRemoveUntil(
                        MaterialPageRoute(builder: (_) => const OptionScreen()),
                            (route) => false,
                      );
                    },
                    style: TextButton.styleFrom(
                      backgroundColor: Colors.red[900]?.withOpacity(0.2),
                      padding: const EdgeInsets.symmetric(vertical: 12),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(12),
                        side: BorderSide(color: Colors.red[400]!.withOpacity(0.5)),
                      ),
                    ),
                    child: Row(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        Icon(Icons.exit_to_app, color: Colors.red[400], size: 20),
                        const SizedBox(width: 8),
                        Text(
                          "Exit",
                          style: TextStyle(
                            color: Colors.red[400],
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: TextButton(
                    onPressed: () {
                      Navigator.of(context).pop();
                      startGame();
                    },
                    style: TextButton.styleFrom(
                      backgroundColor: accentCyan.withOpacity(0.2),
                      padding: const EdgeInsets.symmetric(vertical: 12),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(12),
                        side: BorderSide(color: accentCyan.withOpacity(0.5)),
                      ),
                    ),
                    child: Row(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        Icon(Icons.refresh, color: accentCyan, size: 20),
                        const SizedBox(width: 8),
                        Text(
                          "Restart",
                          style: TextStyle(
                            color: accentCyan,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  @override
  void dispose() {
    gameLoop?.cancel();
    _ballAnimationController.dispose();
    _scoreAnimationController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    screenHeight = MediaQuery.of(context).size.height;
    screenWidth = MediaQuery.of(context).size.width;

    return GestureDetector(
      onTap: flap,
      child: Scaffold(
        body: Container(
          decoration: BoxDecoration(
            gradient: LinearGradient(
              begin: Alignment.topCenter,
              end: Alignment.bottomCenter,
              colors: [
                primaryDark,
                secondaryDark,
                primaryDark.withBlue(30),
              ],
            ),
          ),
          child: Stack(
            children: [
              // Animated background particles
              ...List.generate(20, (index) {
                return Positioned(
                  left: rand.nextDouble() * screenWidth,
                  top: rand.nextDouble() * screenHeight,
                  child: AnimatedBuilder(
                    animation: _ballAnimationController,
                    builder: (context, child) {
                      return Opacity(
                        opacity: 0.1 + (sin(_ballAnimationController.value * 2 * pi + index) * 0.1),
                        child: Container(
                          width: 4,
                          height: 4,
                          decoration: BoxDecoration(
                            shape: BoxShape.circle,
                            color: accentCyan,
                          ),
                        ),
                      );
                    },
                  ),
                );
              }),

              // Score display
              Positioned(
                top: 80,
                left: 0,
                right: 0,
                child: Center(
                  child: AnimatedBuilder(
                    animation: _scoreScale,
                    builder: (context, child) {
                      return Transform.scale(
                        scale: _scoreScale.value,
                        child: Container(
                          padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 12),
                          decoration: BoxDecoration(
                            gradient: LinearGradient(
                              colors: [accentCyan.withOpacity(0.2), accentPurple.withOpacity(0.2)],
                              begin: Alignment.topLeft,
                              end: Alignment.bottomRight,
                            ),
                            borderRadius: BorderRadius.circular(25),
                            border: Border.all(color: accentCyan.withOpacity(0.3)),
                            boxShadow: [
                              BoxShadow(
                                color: accentCyan.withOpacity(0.2),
                                blurRadius: 10,
                                spreadRadius: 2,
                              ),
                            ],
                          ),
                          child: Text(
                            isGameStarted ? 'Score: $score' : 'TAP TO START',
                            style: TextStyle(
                              color: textLight,
                              fontSize: 20,
                              fontWeight: FontWeight.bold,
                              letterSpacing: 1.2,
                            ),
                          ),
                        ),
                      );
                    },
                  ),
                ),
              ),

              // Ball with glow effect
              Positioned(
                top: ballY,
                left: 100,
                child: AnimatedBuilder(
                  animation: _ballRotation,
                  builder: (context, child) {
                    return Transform.rotate(
                      angle: _ballRotation.value,
                      child: Container(
                        width: ballSize,
                        height: ballSize,
                        decoration: BoxDecoration(
                          shape: BoxShape.circle,
                          gradient: RadialGradient(
                            colors: [
                              accentOrange,
                              accentOrange.withOpacity(0.8),
                              accentOrange.withOpacity(0.6),
                            ],
                          ),
                          boxShadow: [
                            BoxShadow(
                              color: accentOrange.withOpacity(0.6),
                              blurRadius: 15,
                              spreadRadius: 3,
                            ),
                            BoxShadow(
                              color: accentOrange.withOpacity(0.3),
                              blurRadius: 25,
                              spreadRadius: 5,
                            ),
                          ],
                        ),
                        child: Container(
                          decoration: BoxDecoration(
                            shape: BoxShape.circle,
                            gradient: RadialGradient(
                              center: const Alignment(-0.3, -0.3),
                              colors: [
                                Colors.white.withOpacity(0.4),
                                Colors.transparent,
                              ],
                              stops: const [0.0, 0.7],
                            ),
                          ),
                        ),
                      ),
                    );
                  },
                ),
              ),

              // Enhanced pillars with glow
              for (int i = 0; i < pillarX.length; i++) ...[
                // Top Pillar
                Positioned(
                  left: pillarX[i],
                  top: 0,
                  child: Container(
                    width: pillarWidth,
                    height: gapTop[i],
                    decoration: BoxDecoration(
                      gradient: LinearGradient(
                        begin: Alignment.topLeft,
                        end: Alignment.bottomRight,
                        colors: [
                          accentPurple.withOpacity(0.8),
                          accentPurple.withOpacity(0.6),
                          accentCyan.withOpacity(0.6),
                        ],
                      ),
                      borderRadius: const BorderRadius.only(
                        bottomLeft: Radius.circular(12),
                        bottomRight: Radius.circular(12),
                      ),
                      border: Border.all(color: accentCyan.withOpacity(0.3)),
                      boxShadow: [
                        BoxShadow(
                          color: accentPurple.withOpacity(0.3),
                          blurRadius: 10,
                          spreadRadius: 2,
                        ),
                      ],
                    ),
                    child: Container(
                      decoration: BoxDecoration(
                        gradient: LinearGradient(
                          begin: Alignment.centerLeft,
                          end: Alignment.centerRight,
                          colors: [
                            Colors.white.withOpacity(0.1),
                            Colors.transparent,
                            Colors.white.withOpacity(0.05),
                          ],
                        ),
                        borderRadius: const BorderRadius.only(
                          bottomLeft: Radius.circular(12),
                          bottomRight: Radius.circular(12),
                        ),
                      ),
                    ),
                  ),
                ),
                // Bottom Pillar
                Positioned(
                  left: pillarX[i],
                  top: gapTop[i] + gapHeight,
                  child: Container(
                    width: pillarWidth,
                    height: screenHeight - gapTop[i] - gapHeight,
                    decoration: BoxDecoration(
                      gradient: LinearGradient(
                        begin: Alignment.topLeft,
                        end: Alignment.bottomRight,
                        colors: [
                          accentCyan.withOpacity(0.6),
                          accentPurple.withOpacity(0.6),
                          accentPurple.withOpacity(0.8),
                        ],
                      ),
                      borderRadius: const BorderRadius.only(
                        topLeft: Radius.circular(12),
                        topRight: Radius.circular(12),
                      ),
                      border: Border.all(color: accentCyan.withOpacity(0.3)),
                      boxShadow: [
                        BoxShadow(
                          color: accentCyan.withOpacity(0.3),
                          blurRadius: 10,
                          spreadRadius: 2,
                        ),
                      ],
                    ),
                    child: Container(
                      decoration: BoxDecoration(
                        gradient: LinearGradient(
                          begin: Alignment.centerLeft,
                          end: Alignment.centerRight,
                          colors: [
                            Colors.white.withOpacity(0.1),
                            Colors.transparent,
                            Colors.white.withOpacity(0.05),
                          ],
                        ),
                        borderRadius: const BorderRadius.only(
                          topLeft: Radius.circular(12),
                          topRight: Radius.circular(12),
                        ),
                      ),
                    ),
                  ),
                ),
              ],
            ],
          ),
        ),
      ),
    );
  }
}

