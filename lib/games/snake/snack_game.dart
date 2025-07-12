import 'dart:async';
import 'dart:math';

import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

import '../../screens/option_screen.dart';

enum Direction { up, down, left, right }

class SnakeGame extends StatefulWidget {
  const SnakeGame({super.key});

  @override
  State<SnakeGame> createState() => _SnakeGameState();
}

class _SnakeGameState extends State<SnakeGame> with TickerProviderStateMixin {
  static const int rows = 20;
  static const int columns = 20;
  static const Duration initialSpeed = Duration(milliseconds: 400);
  late Timer timer;
  late AnimationController _pulseController;
  late AnimationController _glowController;
  late AnimationController _backgroundController;
  late AnimationController _particleController;
  late Animation<double> _pulseAnimation;
  late Animation<double> _glowAnimation;
  late Animation<double> _backgroundAnimation;
  late Animation<double> _particleAnimation;

  List<Point<int>> snake = [const Point(10, 10)];
  Point<int> food = const Point(5, 5);
  Direction direction = Direction.right;
  bool isGameOver = false;
  bool isPaused = false;
  int score = 0;
  int level = 1;
  Duration currentSpeed = initialSpeed;
  List<Point<int>> particles = [];
  DateTime? _lastDirectionChange;
  static const Duration _debounceDuration = Duration(milliseconds: 100);

  @override
  void initState() {
    super.initState();
    _setupAnimations();
    startGame();
    _generateParticles();
  }

  void _setupAnimations() {
    _pulseController = AnimationController(
      duration: const Duration(milliseconds: 800),
      vsync: this,
    );
    _glowController = AnimationController(
      duration: const Duration(milliseconds: 1500),
      vsync: this,
    );
    _backgroundController = AnimationController(
      duration: const Duration(seconds: 10),
      vsync: this,
    );
    _particleController = AnimationController(
      duration: const Duration(seconds: 3),
      vsync: this,
    );

    _pulseAnimation = Tween<double>(
      begin: 0.9,
      end: 1.1,
    ).animate(CurvedAnimation(
      parent: _pulseController,
      curve: Curves.easeInOut,
    ));

    _glowAnimation = Tween<double>(
      begin: 0.3,
      end: 1.0,
    ).animate(CurvedAnimation(
      parent: _glowController,
      curve: Curves.easeInOut,
    ));

    _backgroundAnimation = Tween<double>(
      begin: 0.0,
      end: 1.0,
    ).animate(CurvedAnimation(
      parent: _backgroundController,
      curve: Curves.linear,
    ));

    _particleAnimation = Tween<double>(
      begin: 0.0,
      end: 1.0,
    ).animate(CurvedAnimation(
      parent: _particleController,
      curve: Curves.easeInOut,
    ));

    _pulseController.repeat(reverse: true);
    _glowController.repeat(reverse: true);
    _backgroundController.repeat();
    _particleController.repeat(reverse: true);
  }

  void _generateParticles() {
    final rand = Random();
    particles = List.generate(15, (index) =>
        Point(rand.nextInt(columns), rand.nextInt(rows))
    );
  }

  void startGame() {
    timer = Timer.periodic(currentSpeed, (Timer t) {
      if (!isPaused) {
        setState(moveSnake);
      }
    });
  }

  void moveSnake() {
    if (isGameOver) return;

    final head = snake.last;
    Point<int> newHead;

    switch (direction) {
      case Direction.up:
        newHead = Point(head.x, head.y - 1);
        break;
      case Direction.down:
        newHead = Point(head.x, head.y + 1);
        break;
      case Direction.left:
        newHead = Point(head.x - 1, head.y);
        break;
      case Direction.right:
        newHead = Point(head.x + 1, head.y);
        break;
    }

    if (newHead.x < 0 ||
        newHead.y < 0 ||
        newHead.x >= columns ||
        newHead.y >= rows ||
        snake.contains(newHead)) {
      isGameOver = true;
      timer.cancel();
      _pulseController.stop();
      _glowController.stop();
      _backgroundController.stop();
      _particleController.stop();
      HapticFeedback.heavyImpact();
      showGameOverDialog();
      return;
    }

    snake.add(newHead);

    if (newHead == food) {
      score += 10;
      level = (score ~/ 100) + 1;
      _updateSpeed();
      generateFood();
      HapticFeedback.lightImpact();
    } else {
      snake.removeAt(0);
    }
  }

  void _updateSpeed() {
    timer.cancel();
    currentSpeed = Duration(milliseconds: max(100, initialSpeed.inMilliseconds - (level * 30)));
    startGame();
  }

  void generateFood() {
    final rand = Random();
    Point<int> newFood;

    do {
      newFood = Point(rand.nextInt(columns), rand.nextInt(rows));
    } while (snake.contains(newFood));

    food = newFood;
  }

  void _togglePause() {
    setState(() {
      isPaused = !isPaused;
    });
    if (isPaused) {
      _pulseController.stop();
      _glowController.stop();
    } else {
      _pulseController.repeat(reverse: true);
      _glowController.repeat(reverse: true);
    }
  }

  void showGameOverDialog() {
    showDialog(
      context: context,
      barrierDismissible: false,
      builder: (_) => AlertDialog(
        backgroundColor: const Color(0xFF0D1117),
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(20),
          side: const BorderSide(
            color: Color(0xFF21262D),
            width: 2,
          ),
        ),
        title: Container(
          padding: const EdgeInsets.all(15),
          decoration: BoxDecoration(
            gradient: const LinearGradient(
              colors: [Color(0xFFFF6B6B), Color(0xFFEE5A24)],
              begin: Alignment.topLeft,
              end: Alignment.bottomRight,
            ),
            borderRadius: BorderRadius.circular(15),
            boxShadow: [
              BoxShadow(
                color: const Color(0xFFFF6B6B).withOpacity(0.3),
                blurRadius: 15,
                spreadRadius: 2,
              ),
            ],
          ),
          child: const Text(
            '☠️ GAME OVER',
            style: TextStyle(
              color: Colors.white,
              fontWeight: FontWeight.bold,
              fontSize: 22,
              letterSpacing: 1.2,
            ),
            textAlign: TextAlign.center,
          ),
        ),
        content: Container(
          padding: const EdgeInsets.all(20),
          decoration: BoxDecoration(
            color: const Color(0xFF161B22),
            borderRadius: BorderRadius.circular(15),
            border: Border.all(
              color: const Color(0xFF30363D),
              width: 1,
            ),
          ),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              const Text(
                '🏆 FINAL STATS',
                style: TextStyle(
                  color: Color(0xFF58A6FF),
                  fontWeight: FontWeight.bold,
                  fontSize: 16,
                ),
              ),
              const SizedBox(height: 15),
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  const Text(
                    'Score:',
                    style: TextStyle(
                      color: Colors.white70,
                      fontSize: 16,
                    ),
                  ),
                  Text(
                    '$score',
                    style: const TextStyle(
                      color: Colors.white,
                      fontSize: 20,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 8),
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  const Text(
                    'Level:',
                    style: TextStyle(
                      color: Colors.white70,
                      fontSize: 16,
                    ),
                  ),
                  Text(
                    '$level',
                    style: const TextStyle(
                      color: Colors.white,
                      fontSize: 20,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 8),
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  const Text(
                    'Length:',
                    style: TextStyle(
                      color: Colors.white70,
                      fontSize: 16,
                    ),
                  ),
                  Text(
                    '${snake.length}',
                    style: const TextStyle(
                      color: Colors.white,
                      fontSize: 20,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                ],
              ),
            ],
          ),
        ),
        actions: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceEvenly,
            children: [
              Container(
                decoration: BoxDecoration(
                  gradient: const LinearGradient(
                    colors: [Color(0xFF6C757D), Color(0xFF495057)],
                  ),
                  borderRadius: BorderRadius.circular(25),
                ),
                child: TextButton(
                  onPressed: () {
                    Navigator.of(context).pushAndRemoveUntil(
                      MaterialPageRoute(builder: (_) => const OptionScreen()),
                          (route) => false,
                    );
                  },
                  child: const Padding(
                    padding: EdgeInsets.symmetric(horizontal: 15, vertical: 8),
                    child: Text(
                      '🚪 EXIT',
                      style: TextStyle(
                        color: Colors.white,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                  ),
                ),
              ),
              Container(
                decoration: BoxDecoration(
                  gradient: const LinearGradient(
                    colors: [Color(0xFF4ECDC4), Color(0xFF44A08D)],
                  ),
                  borderRadius: BorderRadius.circular(25),
                ),
                child: TextButton(
                  onPressed: () {
                    Navigator.of(context).pop();
                    resetGame();
                  },
                  child: const Padding(
                    padding: EdgeInsets.symmetric(horizontal: 15, vertical: 8),
                    child: Text(
                      '🔄 RESTART',
                      style: TextStyle(
                        color: Colors.white,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                  ),
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }

  void resetGame() {
    setState(() {
      snake = [const Point(10, 10)];
      food = const Point(5, 5);
      direction = Direction.right;
      isGameOver = false;
      isPaused = false;
      score = 0;
      level = 1;
      currentSpeed = initialSpeed;
      _lastDirectionChange = null;
      _generateParticles();
      _setupAnimations();
      startGame();
    });
  }

  void changeDirection(Direction newDirection) {
    final now = DateTime.now();
    if (_lastDirectionChange != null &&
        now.difference(_lastDirectionChange!) < _debounceDuration) {
      return;
    }

    if ((direction == Direction.left && newDirection == Direction.right) ||
        (direction == Direction.right && newDirection == Direction.left) ||
        (direction == Direction.up && newDirection == Direction.down) ||
        (direction == Direction.down && newDirection == Direction.up)) {
      return;
    }

    setState(() {
      direction = newDirection;
      _lastDirectionChange = now;
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFF0D1117),
      body: AnimatedBuilder(
        animation: _backgroundAnimation,
        builder: (context, child) {
          return Container(
            decoration: BoxDecoration(
              gradient: RadialGradient(
                center: Alignment.center,
                radius: 1.5 + (_backgroundAnimation.value * 0.3),
                colors: const [
                  Color(0xFF161B22),
                  Color(0xFF0D1117),
                  Color(0xFF010409),
                ],
              ),
            ),
            child: SafeArea(
              child: GestureDetector(
                onTap: _togglePause,
                onPanUpdate: (details) {
                  final dx = details.delta.dx;
                  final dy = details.delta.dy;
                  const swipeThreshold = 5.0;

                  if (dx.abs() > dy.abs() && dx.abs() > swipeThreshold) {
                    if (dx < 0) {
                      changeDirection(Direction.left);
                    } else {
                      changeDirection(Direction.right);
                    }
                  } else if (dy.abs() > swipeThreshold) {
                    if (dy < 0) {
                      changeDirection(Direction.up);
                    } else {
                      changeDirection(Direction.down);
                    }
                  }
                },
                child: Column(
                  children: [
                    const SizedBox(height: 10),
                    Container(
                      margin: const EdgeInsets.symmetric(horizontal: 20),
                      padding: const EdgeInsets.all(15),
                      decoration: BoxDecoration(
                        gradient: const LinearGradient(
                          colors: [Color(0xFF21262D), Color(0xFF161B22)],
                          begin: Alignment.topLeft,
                          end: Alignment.bottomRight,
                        ),
                        borderRadius: BorderRadius.circular(20),
                        border: Border.all(
                          color: const Color(0xFF30363D),
                          width: 1,
                        ),
                        boxShadow: [
                          BoxShadow(
                            color: const Color(0xFF58A6FF).withOpacity(0.1),
                            blurRadius: 20,
                            spreadRadius: 2,
                          ),
                        ],
                      ),
                      child: Row(
                        mainAxisAlignment: MainAxisAlignment.spaceAround,
                        children: [
                          _buildStatItem('🎯', 'SCORE', score.toString()),
                          _buildStatItem('⚡', 'LEVEL', level.toString()),
                          _buildStatItem('🐍', 'LENGTH', snake.length.toString()),
                        ],
                      ),
                    ),
                    const SizedBox(height: 15),
                    Expanded(
                      child: Container(
                        margin: const EdgeInsets.all(20),
                        padding: const EdgeInsets.all(8),
                        decoration: BoxDecoration(
                          gradient: const LinearGradient(
                            colors: [Color(0xFF0D1117), Color(0xFF161B22)],
                            begin: Alignment.topLeft,
                            end: Alignment.bottomRight,
                          ),
                          borderRadius: BorderRadius.circular(25),
                          border: Border.all(
                            color: const Color(0xFF21262D),
                            width: 2,
                          ),
                          boxShadow: [
                            BoxShadow(
                              color: const Color(0xFF000000).withOpacity(0.5),
                              blurRadius: 30,
                              spreadRadius: 5,
                              offset: const Offset(0, 10),
                            ),
                          ],
                        ),
                        child: ClipRRect(
                          borderRadius: BorderRadius.circular(20),
                          child: Stack(
                            children: [
                              ...particles.map((particle) => AnimatedBuilder(
                                animation: _particleAnimation,
                                builder: (context, child) {
                                  return Positioned(
                                    left: (particle.x / columns) * (MediaQuery.of(context).size.width - 80),
                                    top: (particle.y / rows) * (MediaQuery.of(context).size.height - 300),
                                    child: Container(
                                      width: 2,
                                      height: 2,
                                      decoration: BoxDecoration(
                                        color: const Color(0xFF30363D).withOpacity(
                                            0.3 + (_particleAnimation.value * 0.4)
                                        ),
                                        shape: BoxShape.circle,
                                      ),
                                    ),
                                  );
                                },
                              )).toList(),
                              GridView.builder(
                                physics: const NeverScrollableScrollPhysics(),
                                gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
                                  crossAxisCount: columns,
                                  mainAxisSpacing: 1,
                                  crossAxisSpacing: 1,
                                ),
                                itemCount: rows * columns,
                                itemBuilder: (context, index) {
                                  final x = index % columns;
                                  final y = index ~/ columns;
                                  final cell = Point(x, y);
                                  return _buildCell(cell);
                                },
                              ),
                              if (isPaused)
                                Container(
                                  color: const Color(0xFF000000).withOpacity(0.7),
                                  child: const Center(
                                    child: Text(
                                      '⏸️ PAUSED\nTap to Resume',
                                      style: TextStyle(
                                        color: Colors.white,
                                        fontSize: 24,
                                        fontWeight: FontWeight.bold,
                                      ),
                                      textAlign: TextAlign.center,
                                    ),
                                  ),
                                ),
                            ],
                          ),
                        ),
                      ),
                    ),
                    Container(
                      margin: const EdgeInsets.only(bottom: 20),
                      padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 12),
                      decoration: BoxDecoration(
                        color: const Color(0xFF21262D),
                        borderRadius: BorderRadius.circular(15),
                        border: Border.all(
                          color: const Color(0xFF30363D),
                          width: 1,
                        ),
                      ),
                      child: Text(
                        'Swipe to move ${_getDirectionEmoji()} • Tap to pause ⏸️',
                        style: const TextStyle(
                          color: Colors.white60,
                          fontSize: 14,
                        ),
                        textAlign: TextAlign.center,
                      ),
                    ),
                  ],
                ),
              ),
            ),
          );
        },
      ),
    );
  }

  Widget _buildStatItem(String emoji, String label, String value) {
    return Column(
      children: [
        Text(
          emoji,
          style: const TextStyle(fontSize: 20),
        ),
        const SizedBox(height: 4),
        Text(
          label,
          style: const TextStyle(
            color: Colors.white54,
            fontSize: 10,
            fontWeight: FontWeight.w500,
          ),
        ),
        const SizedBox(height: 2),
        Text(
          value,
          style: const TextStyle(
            color: Colors.white,
            fontSize: 16,
            fontWeight: FontWeight.bold,
          ),
        ),
      ],
    );
  }

  String _getDirectionEmoji() {
    switch (direction) {
      case Direction.up:
        return '⬆️';
      case Direction.down:
        return '⬇️';
      case Direction.left:
        return '⬅️';
      case Direction.right:
        return '➡️';
    }
  }

  Widget _buildCell(Point<int> cell) {
    if (snake.contains(cell)) {
      final isHead = cell == snake.last;
      final segmentIndex = snake.indexOf(cell);
      final opacity = 1.0 - (segmentIndex * 0.05);
      final isNeck = segmentIndex == snake.length - 2;

      return AnimatedBuilder(
        animation: _pulseAnimation,
        builder: (context, child) {
          return Transform.scale(
            scale: isHead ? _pulseAnimation.value : 1.0,
            child: Container(
              margin: const EdgeInsets.all(0.5),
              decoration: BoxDecoration(
                gradient: isHead
                    ? const LinearGradient(
                  colors: [Color(0xFF4ECDC4), Color(0xFF44A08D)],
                  begin: Alignment.topLeft,
                  end: Alignment.bottomRight,
                )
                    : LinearGradient(
                  colors: [
                    Color(0xFF4ECDC4).withOpacity(opacity.clamp(0.3, 1.0)),
                    Color(0xFF44A08D).withOpacity(opacity.clamp(0.3, 1.0)),
                  ],
                  begin: Alignment.topLeft,
                  end: Alignment.bottomRight,
                ),
                borderRadius: BorderRadius.circular(isHead ? 8 : (isNeck ? 6 : 4)),
                boxShadow: [
                  BoxShadow(
                    color: const Color(0xFF4ECDC4).withOpacity(isHead ? 0.6 : 0.3),
                    blurRadius: isHead ? 8 : 4,
                    spreadRadius: isHead ? 1 : 0,
                  ),
                ],
              ),
              child: isHead
                  ? Center(
                child: Icon(
                  _getSnakeHeadIcon(),
                  color: Colors.white,
                  size: 12,
                ),
              )
                  : null,
            ),
          );
        },
      );
    } else if (cell == food) {
      return AnimatedBuilder(
        animation: _glowAnimation,
        builder: (context, child) {
          return Transform.scale(
            scale: 1.0 + (_glowAnimation.value * 0.15),
            child: Container(
              margin: const EdgeInsets.all(0.5),
              decoration: BoxDecoration(
                gradient: const RadialGradient(
                  colors: [Color(0xFFFF6B6B), Color(0xFFEE5A24)],
                  center: Alignment.center,
                ),
                borderRadius: BorderRadius.circular(8),
                boxShadow: [
                  BoxShadow(
                    color: const Color(0xFFFF6B6B).withOpacity(0.8),
                    blurRadius: 8 + (_glowAnimation.value * 4),
                    spreadRadius: 1 + (_glowAnimation.value * 2),
                  ),
                ],
              ),
              child: const Center(
                child: Text(
                  "🍎",
                  style: TextStyle(fontSize: 12),
                ),
              ),
            ),
          );
        },
      );
    } else {
      return Container(
        margin: const EdgeInsets.all(0.5),
        decoration: BoxDecoration(
          color: const Color(0xFF161B22),
          borderRadius: BorderRadius.circular(2),
          border: Border.all(
            color: const Color(0xFF21262D),
            width: 0.3,
          ),
        ),
      );
    }
  }

  IconData _getSnakeHeadIcon() {
    switch (direction) {
      case Direction.up:
        return Icons.keyboard_arrow_up;
      case Direction.down:
        return Icons.keyboard_arrow_down;
      case Direction.left:
        return Icons.keyboard_arrow_left;
      case Direction.right:
        return Icons.keyboard_arrow_right;
    }
  }

  @override
  void dispose() {
    timer.cancel();
    _pulseController.dispose();
    _glowController.dispose();
    _backgroundController.dispose();
    _particleController.dispose();
    super.dispose();
  }
}