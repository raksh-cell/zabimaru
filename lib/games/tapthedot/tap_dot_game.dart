import 'dart:async';
import 'dart:math';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

class TapDotGame extends StatefulWidget {
  const TapDotGame({super.key});

  @override
  State<TapDotGame> createState() => _TapDotGameState();
}

class _TapDotGameState extends State<TapDotGame> with TickerProviderStateMixin {
  int score = 0;
  int highScore = 0;
  double dotX = 100;
  double dotY = 100;
  Timer? gameTimer;
  Timer? dotTimer;
  int timeLeft = 30;
  bool gameOver = false;
  bool gameStarted = false;
  final Random random = Random();

  // Enhanced features
  int streak = 0;
  int maxStreak = 0;
  double dotSize = 60.0;
  Color dotColor = Colors.red;
  int level = 1;
  double dotSpeed = 2.0; // seconds between moves
  List<Color> dotColors = [
    Colors.red,
    Colors.orange,
    Colors.yellow,
    Colors.green,
    Colors.blue,
    Colors.purple,
    Colors.pink,
    Colors.cyan,
  ];

  // Animation controllers
  late AnimationController _pulseController;
  late AnimationController _fadeController;
  late Animation<double> _pulseAnimation;
  late Animation<double> _fadeAnimation;

  // Particle effects
  List<Particle> particles = [];
  Timer? particleTimer;

  @override
  void initState() {
    super.initState();

    // Initialize animations
    _pulseController = AnimationController(
      duration: const Duration(milliseconds: 500),
      vsync: this,
    );

    _fadeController = AnimationController(
      duration: const Duration(milliseconds: 300),
      vsync: this,
    );

    _pulseAnimation = Tween<double>(
      begin: 1.0,
      end: 1.3,
    ).animate(CurvedAnimation(
      parent: _pulseController,
      curve: Curves.elasticOut,
    ));

    _fadeAnimation = Tween<double>(
      begin: 0.0,
      end: 1.0,
    ).animate(CurvedAnimation(
      parent: _fadeController,
      curve: Curves.easeIn,
    ));

    // Delay until after build is complete
    WidgetsBinding.instance.addPostFrameCallback((_) {
      _fadeController.forward();
      startParticleSystem();
    });
  }

  void startGame() {
    setState(() {
      score = 0;
      timeLeft = 30;
      gameOver = false;
      gameStarted = true;
      streak = 0;
      level = 1;
      dotSize = 60.0;
      dotSpeed = 2.0;
    });

    moveDot();

    // Game countdown timer
    gameTimer = Timer.periodic(const Duration(seconds: 1), (timer) {
      setState(() {
        timeLeft--;
      });

      if (timeLeft <= 0) {
        endGame();
      }
    });

    // Automatic dot movement timer
    startDotTimer();
  }

  void startDotTimer() {
    dotTimer?.cancel();
    dotTimer = Timer.periodic(Duration(milliseconds: (dotSpeed * 1000).round()), (timer) {
      if (!gameOver && gameStarted) {
        moveDot();
      }
    });
  }

  void endGame() {
    setState(() {
      gameOver = true;
      gameStarted = false;
      if (score > highScore) {
        highScore = score;
      }
      if (streak > maxStreak) {
        maxStreak = streak;
      }
    });

    gameTimer?.cancel();
    dotTimer?.cancel();

    // Haptic feedback
    HapticFeedback.mediumImpact();
  }

  void moveDot() {
    final size = MediaQuery.of(context).size;

    setState(() {
      dotX = random.nextDouble() * (size.width - dotSize - 40);
      dotY = random.nextDouble() * (size.height - dotSize - 250);
      dotColor = dotColors[random.nextInt(dotColors.length)];
    });

    _fadeController.reset();
    _fadeController.forward();
  }

  void tapDot() {
    if (gameOver || !gameStarted) return;

    // Haptic feedback
    HapticFeedback.lightImpact();

    setState(() {
      score++;
      streak++;

      // Level progression
      if (score % 10 == 0) {
        level++;
        dotSize = max(30.0, dotSize - 3.0); // Shrink dot
        dotSpeed = max(0.5, dotSpeed - 0.1); // Increase speed
        startDotTimer(); // Restart timer with new speed
      }
    });

    // Pulse animation
    _pulseController.reset();
    _pulseController.forward();

    // Create particles
    createParticles(dotX + dotSize / 2, dotY + dotSize / 2);

    moveDot();
  }

  void createParticles(double x, double y) {
    for (int i = 0; i < 8; i++) {
      particles.add(Particle(
        x: x,
        y: y,
        color: dotColor,
        angle: (i * 45.0) * (pi / 180),
        speed: 2.0 + random.nextDouble() * 3.0,
      ));
    }
  }

  void startParticleSystem() {
    particleTimer = Timer.periodic(const Duration(milliseconds: 50), (timer) {
      if (mounted) {
        setState(() {
          particles.removeWhere((particle) => particle.life <= 0);
          for (var particle in particles) {
            particle.update();
          }
        });
      }
    });
  }

  void restartGame() {
    setState(() {
      startGame();
    });
  }

  void exitGame() {
    // Simple back navigation to previous screen
    Navigator.pop(context);
  }

  void showPauseDialog() {
    gameTimer?.cancel();
    dotTimer?.cancel();

    showDialog(
      context: context,
      barrierDismissible: false,
      builder: (context) => AlertDialog(
        backgroundColor: const Color(0xFF1A1A1A),
        title: const Text(
          'Game Paused',
          style: TextStyle(color: Colors.white),
        ),
        content: const Text(
          'What would you like to do?',
          style: TextStyle(color: Colors.white70),
        ),
        actions: [
          TextButton(
            onPressed: () {
              Navigator.pop(context);
              if (timeLeft > 0 && gameStarted) {
                startGame();
              }
            },
            child: const Text('Resume', style: TextStyle(color: Colors.blue)),
          ),
          TextButton(
            onPressed: () {
              Navigator.pop(context);
              exitGame();
            },
            child: const Text('Exit', style: TextStyle(color: Colors.red)),
          ),
        ],
      ),
    );
  }

  @override
  void dispose() {
    gameTimer?.cancel();
    dotTimer?.cancel();
    particleTimer?.cancel();
    _pulseController.dispose();
    _fadeController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFF0A0A0A),
      appBar: AppBar(
        title: const Text(
          "Tap the Dot",
          style: TextStyle(
            color: Colors.white,
            fontWeight: FontWeight.bold,
          ),
        ),
        backgroundColor: const Color(0xFF1A1A1A),
        elevation: 0,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back, color: Colors.white),
          onPressed: exitGame,
        ),
        actions: [
          IconButton(
            icon: const Icon(Icons.pause, color: Colors.white),
            onPressed: gameStarted && !gameOver ? showPauseDialog : null,
          ),
          IconButton(
            icon: const Icon(Icons.exit_to_app, color: Colors.white),
            onPressed: exitGame,
          ),
        ],
      ),
      body: Stack(
        children: [
          // Animated background
          Container(
            decoration: const BoxDecoration(
              gradient: RadialGradient(
                center: Alignment.center,
                radius: 1.0,
                colors: [
                  Color(0xFF1A1A1A),
                  Color(0xFF0A0A0A),
                ],
              ),
            ),
          ),

          // Particles
          ...particles.where((particle) => particle.life > 0).map((particle) => Positioned(
            left: particle.x,
            top: particle.y,
            child: Container(
              width: 4,
              height: 4,
              decoration: BoxDecoration(
                shape: BoxShape.circle,
                color: particle.color.withOpacity(particle.life.clamp(0.0, 1.0)),
              ),
            ),
          )),

          // Game stats
          Positioned(
            top: 20,
            left: 20,
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  "Score: $score",
                  style: const TextStyle(
                    color: Colors.white,
                    fontSize: 24,
                    fontWeight: FontWeight.bold,
                  ),
                ),
                Text(
                  "High: $highScore",
                  style: const TextStyle(
                    color: Colors.white70,
                    fontSize: 16,
                  ),
                ),
                Text(
                  "Streak: $streak",
                  style: TextStyle(
                    color: streak > 5 ? Colors.orange : Colors.white70,
                    fontSize: 16,
                  ),
                ),
              ],
            ),
          ),

          Positioned(
            top: 20,
            right: 20,
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.end,
              children: [
                Text(
                  "Time: $timeLeft",
                  style: TextStyle(
                    color: timeLeft <= 10 ? Colors.red : Colors.white,
                    fontSize: 24,
                    fontWeight: FontWeight.bold,
                  ),
                ),
                Text(
                  "Level: $level",
                  style: const TextStyle(
                    color: Colors.white70,
                    fontSize: 16,
                  ),
                ),
              ],
            ),
          ),

          // Dot
          if (!gameOver && gameStarted)
            Positioned(
              left: dotX,
              top: dotY,
              child: GestureDetector(
                onTap: tapDot,
                child: AnimatedBuilder(
                  animation: _pulseAnimation,
                  builder: (context, child) {
                    return Transform.scale(
                      scale: _pulseAnimation.value,
                      child: FadeTransition(
                        opacity: _fadeAnimation,
                        child: Container(
                          width: dotSize,
                          height: dotSize,
                          decoration: BoxDecoration(
                            shape: BoxShape.circle,
                            color: dotColor,
                            boxShadow: [
                              BoxShadow(
                                color: dotColor.withOpacity(0.5),
                                blurRadius: 10,
                                spreadRadius: 2,
                              ),
                            ],
                          ),
                        ),
                      ),
                    );
                  },
                ),
              ),
            ),

          // Start screen
          if (!gameStarted && !gameOver)
            Center(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  const Icon(
                    Icons.touch_app,
                    size: 80,
                    color: Colors.white,
                  ),
                  const SizedBox(height: 20),
                  const Text(
                    "Tap the Dot",
                    style: TextStyle(
                      color: Colors.white,
                      fontSize: 32,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  const SizedBox(height: 10),
                  const Text(
                    "Tap as many dots as you can!\nThey get faster and smaller each level.",
                    textAlign: TextAlign.center,
                    style: TextStyle(
                      color: Colors.white70,
                      fontSize: 16,
                    ),
                  ),
                  const SizedBox(height: 30),
                  ElevatedButton(
                    onPressed: startGame,
                    style: ElevatedButton.styleFrom(
                      backgroundColor: Colors.blue,
                      foregroundColor: Colors.white,
                      padding: const EdgeInsets.symmetric(
                        horizontal: 40,
                        vertical: 15,
                      ),
                    ),
                    child: const Text(
                      "Start Game",
                      style: TextStyle(fontSize: 18),
                    ),
                  ),
                ],
              ),
            ),

          // Game Over screen
          if (gameOver)
            Center(
              child: Container(
                margin: const EdgeInsets.all(20),
                padding: const EdgeInsets.all(30),
                decoration: BoxDecoration(
                  color: const Color(0xFF1A1A1A),
                  borderRadius: BorderRadius.circular(20),
                  border: Border.all(color: Colors.white24),
                ),
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    const Icon(
                      Icons.emoji_events,
                      size: 60,
                      color: Colors.yellow,
                    ),
                    const SizedBox(height: 20),
                    const Text(
                      "Game Over!",
                      style: TextStyle(
                        color: Colors.white,
                        fontSize: 32,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    const SizedBox(height: 20),
                    Text(
                      "Final Score: $score",
                      style: const TextStyle(
                        color: Colors.white,
                        fontSize: 24,
                      ),
                    ),
                    Text(
                      "High Score: $highScore",
                      style: const TextStyle(
                        color: Colors.white70,
                        fontSize: 18,
                      ),
                    ),
                    Text(
                      "Max Streak: $maxStreak",
                      style: const TextStyle(
                        color: Colors.white70,
                        fontSize: 18,
                      ),
                    ),
                    Text(
                      "Level Reached: $level",
                      style: const TextStyle(
                        color: Colors.white70,
                        fontSize: 18,
                      ),
                    ),
                    const SizedBox(height: 30),
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                      children: [
                        ElevatedButton(
                          onPressed: restartGame,
                          style: ElevatedButton.styleFrom(
                            backgroundColor: Colors.blue,
                            foregroundColor: Colors.white,
                          ),
                          child: const Text("Play Again"),
                        ),
                        ElevatedButton(
                          onPressed: exitGame,
                          style: ElevatedButton.styleFrom(
                            backgroundColor: Colors.red,
                            foregroundColor: Colors.white,
                          ),
                          child: const Text("Exit"),
                        ),
                      ],
                    ),
                  ],
                ),
              ),
            ),
        ],
      ),
    );
  }
}

class Particle {
  double x, y;
  Color color;
  double angle;
  double speed;
  double life;

  Particle({
    required this.x,
    required this.y,
    required this.color,
    required this.angle,
    required this.speed,
  }) : life = 1.0;

  void update() {
    x += cos(angle) * speed;
    y += sin(angle) * speed;
    life = (life - 0.02).clamp(0.0, 1.0);
    speed *= 0.98;
  }
}



