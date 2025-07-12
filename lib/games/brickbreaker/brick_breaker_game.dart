import 'dart:async';
import 'package:flutter/material.dart';
import 'package:zabimaru/screens/option_screen.dart';

class BrickBreakerGame extends StatefulWidget {
  const BrickBreakerGame({super.key});

  @override
  State<BrickBreakerGame> createState() => _BrickBreakerGameState();
}

class _BrickBreakerGameState extends State<BrickBreakerGame> {
  double paddleX = 0.0;
  double ballX = 0.0;
  double ballY = -0.8;
  double previousBallY = -0.8;
  double ballXDirection = 0.015;
  double ballYDirection = 0.015;
  final double minXVelocity = 0.015;
  final double minYVelocity = 0.015;
  int score = 0;

  final int rowCount = 5;
  final int columnCount = 6;
  List<List<bool>> bricks = [];

  Timer? gameTimer;
  bool hasStarted = false;

  // Dark theme colors - monochromatic with subtle variations
  final List<Color> brickColors = [
    const Color(0xFF6B7280), // Gray-500
    const Color(0xFF4B5563), // Gray-600
    const Color(0xFF374151), // Gray-700
    const Color(0xFF1F2937), // Gray-800
    const Color(0xFF111827), // Gray-900
  ];

  // Additional theme colors for dialog
  final Color cardColor = const Color(0xFF1E1E1E);
  final Color textColor = const Color(0xFFE0E0E0);
  final Color accentColor = const Color(0xFF4A90E2);

  @override
  void initState() {
    super.initState();
    resetBricks();
    startGameLoop();
  }

  void resetBricks() {
    bricks = List.generate(rowCount, (_) => List.generate(columnCount, (_) => true));
  }

  void startGameLoop() {
    gameTimer?.cancel();
    gameTimer = Timer.periodic(const Duration(milliseconds: 16), (_) {
      setState(() {
        updateBallPosition();
        if (hasStarted) checkCollisions();
      });
    });
  }

  void updateBallPosition() {
    previousBallY = ballY;
    ballX += ballXDirection;
    ballY += ballYDirection;

    // Bounce off walls
    if (ballX <= -1) {
      ballX = -1 + 0.01;
      ballXDirection = ballXDirection.abs();
      if (ballXDirection < minXVelocity) {
        ballXDirection = minXVelocity;
      }
    } else if (ballX >= 1) {
      ballX = 1 - 0.01;
      ballXDirection = -ballXDirection.abs();
      if (ballXDirection.abs() < minXVelocity) {
        ballXDirection = -minXVelocity;
      }
    }

    if (ballY <= -1) {
      ballY = -1 + 0.01;
      ballYDirection = ballYDirection.abs();
      if (ballYDirection < minYVelocity) {
        ballYDirection = minYVelocity;
      }
    }

    // Paddle collision detection
    double screenWidth = MediaQuery.of(context).size.width;
    double screenHeight = MediaQuery.of(context).size.height;

    double paddleWidthPx = 120;
    double paddleHeightPx = 20;
    double paddleTopPx = screenHeight * 0.925;
    double paddleLeftPx = (screenWidth / 2) + (paddleX * screenWidth / 2) - paddleWidthPx / 2;

    double ballDiameterPx = 20;
    double ballCenterX = (screenWidth / 2) + (ballX * screenWidth / 2);
    double ballCenterY = (screenHeight / 2) + (ballY * screenHeight / 2);
    double ballBottom = ballCenterY + ballDiameterPx / 2;
    double ballTop = ballCenterY - ballDiameterPx / 2;

    // Relaxed paddle collision detection
    bool ballHitsPaddle =
        ballYDirection > 0 &&
            ballBottom >= paddleTopPx - 10 &&
            ballTop <= paddleTopPx + paddleHeightPx + 10 &&
            ballCenterX >= paddleLeftPx - 10 &&
            ballCenterX <= paddleLeftPx + paddleWidthPx + 10;

    if (ballHitsPaddle) {
      double hitPosition = (ballCenterX - paddleLeftPx) / paddleWidthPx;
      double maxAngle = 0.03;
      ballXDirection = (hitPosition - 0.5) * 2 * maxAngle;
      ballYDirection = -ballYDirection.abs();
      ballY = (paddleTopPx - ballDiameterPx / 2 - screenHeight / 2) / (screenHeight / 2) - 0.03;
      hasStarted = true;

      if (ballXDirection.abs() < minXVelocity) {
        ballXDirection = ballXDirection.isNegative ? -minXVelocity : minXVelocity;
      }
      debugPrint("Paddle hit: ballY=$ballY, ballYDirection=$ballYDirection, ballX=$ballX");
    } else if (ballBottom >= paddleTopPx - 10 && ballBottom <= paddleTopPx + paddleHeightPx + 10) {
      debugPrint("Paddle miss: ballY=$ballY, ballYDirection=$ballYDirection, ballCenterX=$ballCenterX, paddleLeftPx=$paddleLeftPx, paddleWidthPx=$paddleWidthPx");
    }

    // Game Over
    if (ballY > 1) {
      debugPrint("Game Over: Score=$score");
      showGameOverDialog("💀 Game Over");
      resetGame();
    }

    // Safety net: keep velocities from dying
    if (ballXDirection.abs() < minXVelocity) {
      ballXDirection = ballXDirection.isNegative ? -minXVelocity : minXVelocity;
    }
    if (ballYDirection.abs() < minYVelocity) {
      ballYDirection = ballYDirection.isNegative ? -minYVelocity : minYVelocity;
    }
  }

  void checkCollisions() {
    debugPrint("Checking collisions: ballX=$ballX, ballY=$ballY, score=$score");
    for (int row = 0; row < rowCount; row++) {
      for (int col = 0; col < columnCount; col++) {
        if (bricks[row][col]) {
          double brickLeft = -1 + col * (2 / columnCount);
          double brickRight = brickLeft + (2 / columnCount);
          double brickTop = -1 + row * 0.15;
          double brickBottom = brickTop + 0.1;

          // Relaxed brick collision detection
          bool isHit = ballX >= brickLeft - 0.05 &&
              ballX <= brickRight + 0.05 &&
              ballY >= brickTop - 0.05 &&
              ballY <= brickBottom + 0.05;

          debugPrint(
              "Brick[$row,$col]: left=$brickLeft, right=$brickRight, top=$brickTop, bottom=$brickBottom, ballX=$ballX, ballY=$ballY, hit=$isHit");

          if (isHit) {
            setState(() {
              bricks[row][col] = false;
              score++;
              debugPrint("Brick broken at row=$row, col=$col, New Score=$score");

              double ballCenterX = ballX;
              double ballCenterY = ballY;
              double distanceFromLeft = (ballCenterX - brickLeft).abs();
              double distanceFromRight = (brickRight - ballCenterX).abs();
              double distanceFromTop = (ballCenterY - brickTop).abs();
              double distanceFromBottom = (brickBottom - ballCenterY).abs();

              double minDistance = [
                distanceFromLeft,
                distanceFromRight,
                distanceFromTop,
                distanceFromBottom
              ].reduce((a, b) => a < b ? a : b);

              if (minDistance == distanceFromTop || minDistance == distanceFromBottom) {
                ballYDirection *= -1;
                if (ballYDirection.abs() < minYVelocity) {
                  ballYDirection = ballYDirection.isNegative ? -minYVelocity : minYVelocity;
                }
              } else {
                ballXDirection *= -1;
                if (ballXDirection.abs() < minXVelocity) {
                  ballXDirection = ballXDirection.isNegative ? -minXVelocity : minXVelocity;
                }
              }

              // Nudge ball away from the brick
              if (minDistance == distanceFromTop) {
                ballY = brickTop - 0.01;
              } else if (minDistance == distanceFromBottom) {
                ballY = brickBottom + 0.01;
              } else if (minDistance == distanceFromLeft) {
                ballX = brickLeft - 0.01;
              } else if (minDistance == distanceFromRight) {
                ballX = brickRight + 0.01;
              }
            });
          }
        }
      }
    }

    if (bricks.every((row) => row.every((brick) => !brick))) {
      debugPrint("Victory: Score=$score");
      showGameOverDialog("🏆 Victory");
      resetGame();
    }
  }

  void resetGame() {
    setState(() {
      paddleX = 0.0;
      ballX = 0.0;
      ballY = -0.8;
      previousBallY = -0.8;
      ballXDirection = 0.015;
      ballYDirection = 0.015;
      hasStarted = false;
      score = 0;
      resetBricks();
      debugPrint("Game reset: score=$score, ballY=$ballY, hasStarted=$hasStarted");
    });
  }

  void showGameOverDialog(String message) {
    gameTimer?.cancel();
    debugPrint("Showing dialog: message=$message, score=$score");
    Future.delayed(const Duration(milliseconds: 300), () {
      showDialog(
        context: context,
        barrierColor: Colors.black87,
        builder: (_) => AlertDialog(
          backgroundColor: cardColor,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(20),
            side: BorderSide(color: accentColor.withOpacity(0.3), width: 1),
          ),
          title: Row(
            children: [
              Icon(
                message.contains("Victory") ? Icons.emoji_events : Icons.warning,
                color: accentColor,
                size: 28,
              ),
              const SizedBox(width: 12),
              Text(
                message,
                style: TextStyle(
                  color: textColor,
                  fontSize: 22,
                  fontWeight: FontWeight.bold,
                ),
              ),
            ],
          ),
          content: Text(
            message.contains("Victory") ? 'You cleared all bricks!' : 'Better luck next time!',
            style: TextStyle(
              color: textColor.withOpacity(0.7),
              fontSize: 14,
            ),
          ),
          actions: [
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceEvenly,
              children: [
                TextButton(
                  onPressed: () {
                    Navigator.of(context).pushAndRemoveUntil(
                      MaterialPageRoute(builder: (_) => const OptionScreen()),
                          (route) => false,
                    );
                  },
                  style: TextButton.styleFrom(
                    padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 12),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(12),
                      side: BorderSide(color: Colors.red.withOpacity(0.3)),
                    ),
                  ),
                  child: Text(
                    'Exit',
                    style: TextStyle(
                      color: Colors.red.shade400,
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                ),
                TextButton(
                  onPressed: () {
                    Navigator.of(context).pop();
                    resetGame();
                    startGameLoop();
                  },
                  style: TextButton.styleFrom(
                    backgroundColor: accentColor,
                    padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 12),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(12),
                    ),
                  ),
                  child: const Text(
                    'Play Again',
                    style: TextStyle(
                      color: Colors.white,
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                ),
              ],
            ),
          ],
        ),
      );
    });
  }

  @override
  void dispose() {
    gameTimer?.cancel();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFF000000),
      body: Container(
        decoration: const BoxDecoration(
          gradient: LinearGradient(
            begin: Alignment.topCenter,
            end: Alignment.bottomCenter,
            colors: [
              Color(0xFF000000),
              Color(0xFF0F0F0F),
            ],
          ),
        ),
        child: GestureDetector(
          onHorizontalDragUpdate: (details) {
            setState(() {
              paddleX += details.delta.dx / MediaQuery.of(context).size.width * 3.5;
              paddleX = paddleX.clamp(-0.9, 0.9);
            });
          },
          behavior: HitTestBehavior.opaque,
          child: Stack(
            children: [
              // Game border glow effect
              Container(
                margin: const EdgeInsets.all(8),
                decoration: BoxDecoration(
                  border: Border.all(
                    color: const Color(0xFF333333).withOpacity(0.4),
                    width: 1,
                  ),
                  borderRadius: BorderRadius.circular(12),
                  boxShadow: [
                    BoxShadow(
                      color: const Color(0xFF333333).withOpacity(0.1),
                      blurRadius: 10,
                      spreadRadius: 1,
                    ),
                  ],
                ),
              ),

              // Bricks
              ..._buildBricks(),

              // Ball with subtle glow effect
              Align(
                alignment: Alignment(ballX, ballY),
                child: Container(
                  width: 20,
                  height: 20,
                  decoration: BoxDecoration(
                    gradient: const RadialGradient(
                      colors: [
                        Color(0xFFFFFFFF),
                        Color(0xFFE5E7EB),
                      ],
                    ),
                    shape: BoxShape.circle,
                    boxShadow: [
                      BoxShadow(
                        color: const Color(0xFF000000).withOpacity(0.8),
                        blurRadius: 3,
                        spreadRadius: 0.5,
                      ),
                      BoxShadow(
                        color: const Color(0xFFFFFFFF).withOpacity(0.1),
                        blurRadius: 15,
                        spreadRadius: 2,
                      ),
                    ],
                  ),
                ),
              ),

              // Paddle with dark theme design
              Align(
                alignment: Alignment(paddleX, 0.85),
                child: Container(
                  width: 120,
                  height: 20,
                  decoration: BoxDecoration(
                    gradient: const LinearGradient(
                      colors: [
                        Color(0xFF4B5563),
                        Color(0xFF374151),
                      ],
                    ),
                    borderRadius: BorderRadius.circular(10),
                    border: Border.all(
                      color: const Color(0xFF6B7280).withOpacity(0.6),
                      width: 1,
                    ),
                    boxShadow: [
                      BoxShadow(
                        color: const Color(0xFF000000).withOpacity(0.8),
                        blurRadius: 8,
                        spreadRadius: 1,
                        offset: const Offset(0, 4),
                      ),
                    ],
                  ),
                ),
              ),

              // Instructions text
              if (!hasStarted)
                const Positioned(
                  bottom: 120,
                  left: 0,
                  right: 0,
                  child: Text(
                    "Drag to move paddle\nHit the ball to start!",
                    textAlign: TextAlign.center,
                    style: TextStyle(
                      color: Color(0xFF6B7280),
                      fontSize: 16,
                      fontWeight: FontWeight.w500,
                    ),
                  ),
                ),

              // Score display
              Positioned(
                top: 60,
                left: 24,
                child: Container(
                  padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 12),
                  decoration: BoxDecoration(
                    color: cardColor.withOpacity(0.9),
                    borderRadius: BorderRadius.circular(25),
                    border: Border.all(color: accentColor.withOpacity(0.3)),
                    boxShadow: [
                      BoxShadow(
                        color: Colors.black.withOpacity(0.3),
                        blurRadius: 8,
                        offset: const Offset(0, 4),
                      ),
                    ],
                  ),
                  child: Row(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      Icon(
                        Icons.star,
                        color: Colors.amber,
                        size: 20,
                      ),
                      const SizedBox(width: 8),
                      Text(
                        "Score: $score",
                        style: TextStyle(
                          color: textColor,
                          fontSize: 18,
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
      ),
    );
  }

  List<Widget> _buildBricks() {
    List<Widget> brickWidgets = [];
    double brickWidth = 2 / columnCount;
    double brickHeight = 0.1;

    for (int row = 0; row < rowCount; row++) {
      for (int col = 0; col < columnCount; col++) {
        if (bricks[row][col]) {
          double left = -1 + col * brickWidth;
          double top = -1 + row * 0.15;

          Color brickColor = brickColors[row % brickColors.length];

          brickWidgets.add(
            Align(
              alignment: Alignment(left + brickWidth / 2, top + brickHeight / 2),
              child: Container(
                width: MediaQuery.of(context).size.width * 0.92 / columnCount,
                height: 22,
                margin: const EdgeInsets.all(1),
                decoration: BoxDecoration(
                  gradient: LinearGradient(
                    begin: Alignment.topLeft,
                    end: Alignment.bottomRight,
                    colors: [
                      brickColor,
                      brickColor.withOpacity(0.8),
                    ],
                  ),
                  borderRadius: BorderRadius.circular(4),
                  border: Border.all(
                    color: brickColor.withOpacity(0.9),
                    width: 0.5,
                  ),
                  boxShadow: [
                    BoxShadow(
                      color: const Color(0xFF000000).withOpacity(0.6),
                      blurRadius: 3,
                      offset: const Offset(0, 2),
                    ),
                    BoxShadow(
                      color: brickColor.withOpacity(0.1),
                      blurRadius: 6,
                      spreadRadius: 0.5,
                    ),
                  ],
                ),
              ),
            ),
          );
        }
      }
    }

    return brickWidgets;
  }
}





