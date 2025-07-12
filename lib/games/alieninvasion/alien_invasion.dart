import 'dart:async';
import 'dart:math';
import 'package:flutter/material.dart';
import '../../screens/option_screen.dart';

class AlienInvasionGame extends StatefulWidget {
  const AlienInvasionGame({super.key});

  @override
  State<AlienInvasionGame> createState() => _AlienInvasionGameState();
}

class _AlienInvasionGameState extends State<AlienInvasionGame> with TickerProviderStateMixin {
  double cannonX = 0.0;
  List<Offset> bullets = [];
  List<Offset> aliens = [];
  List<Offset> explosions = [];
  int score = 0;
  bool isGameOver = false;
  late Timer _gameLoop;
  Timer? _alienSpawner;
  Timer? _shootingTimer;
  late AnimationController _explosionController;

  // Dark theme colors
  final Color backgroundColor = const Color(0xFF0A0A0A);
  final Color cardColor = const Color(0xFF1E1E1E);
  final Color textColor = const Color(0xFFE0E0E0);
  final Color accentColor = const Color(0xFF4A90E2);
  final Color cannonColor = const Color(0xFF2D4A2D);
  final Color bulletColor = const Color(0xFF00FF88);
  final Color alienColor = const Color(0xFF8B0000);

  @override
  void initState() {
    super.initState();
    _explosionController = AnimationController(
      duration: const Duration(milliseconds: 300),
      vsync: this,
    );
    WidgetsBinding.instance.addPostFrameCallback((_) => _startGame());
  }

  void _startGame() {
    aliens.clear();
    bullets.clear();
    explosions.clear();
    score = 0;
    isGameOver = false;
    _gameLoop = Timer.periodic(const Duration(milliseconds: 30), _update);
    _alienSpawner = Timer.periodic(const Duration(seconds: 2), (_) => _spawnAliens());
    _startShooting();
  }

  void _spawnAliens() {
    if (!mounted || isGameOver) return;
    setState(() {
      final rand = Random();
      final screenWidth = MediaQuery.of(context).size.width;
      for (int i = 0; i < 5; i++) {
        double x = rand.nextDouble() * (screenWidth - 60) + 10;
        aliens.add(Offset(x, 0));
      }
    });
  }

  void _startShooting() {
    _shootingTimer = Timer.periodic(const Duration(milliseconds: 300), (_) {
      if (!isGameOver && mounted) {
        _shootBullet();
      }
    });
  }

  void _update(Timer timer) {
    if (!mounted || isGameOver) return;
    setState(() {
      bullets = bullets.map((b) => Offset(b.dx, b.dy - 10)).toList();
      bullets.removeWhere((b) => b.dy < 0);

      aliens = aliens.map((a) => Offset(a.dx, a.dy + 2)).toList();

      for (int i = bullets.length - 1; i >= 0; i--) {
        for (int j = aliens.length - 1; j >= 0; j--) {
          if ((bullets[i] - aliens[j]).distance < 25) {
            explosions.add(aliens[j]);
            bullets.removeAt(i);
            aliens.removeAt(j);
            score++;
            _explosionController.forward().then((_) {
              _explosionController.reset();
            });
            break;
          }
        }
      }

      // Remove old explosions
      explosions.removeWhere((e) =>
      DateTime.now().millisecondsSinceEpoch % 1000 > 300);

      for (Offset alien in aliens) {
        if (alien.dy > MediaQuery.of(context).size.height - 50) {
          _endGame();
          return;
        }
      }
    });
  }

  void _shootBullet() {
    bullets.add(Offset(cannonX + 30, MediaQuery.of(context).size.height - 90));
  }

  void _moveCannon(double delta) {
    setState(() {
      cannonX += delta;
      double maxX = MediaQuery.of(context).size.width - 60;
      if (cannonX < 0) cannonX = 0;
      if (cannonX > maxX) cannonX = maxX;
    });
  }

  void _endGame() {
    isGameOver = true;
    _gameLoop.cancel();
    _alienSpawner?.cancel();
    _shootingTimer?.cancel();

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
            Icon(Icons.rocket_launch, color: accentColor, size: 28),
            const SizedBox(width: 12),
            Text(
              'Mission Complete',
              style: TextStyle(
                color: textColor,
                fontSize: 22,
                fontWeight: FontWeight.bold,
              ),
            ),
          ],
        ),
        content: Container(
          padding: const EdgeInsets.symmetric(vertical: 8),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Container(
                padding: const EdgeInsets.all(20),
                decoration: BoxDecoration(
                  color: accentColor.withOpacity(0.1),
                  borderRadius: BorderRadius.circular(16),
                  border: Border.all(color: accentColor.withOpacity(0.3)),
                ),
                child: Column(
                  children: [
                    Text(
                      'Aliens Destroyed',
                      style: TextStyle(
                        color: textColor.withOpacity(0.7),
                        fontSize: 14,
                        fontWeight: FontWeight.w500,
                      ),
                    ),
                    const SizedBox(height: 8),
                    Text(
                      '$score',
                      style: TextStyle(
                        color: accentColor,
                        fontSize: 36,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    const SizedBox(height: 8),
                    Text(
                      'Great shooting!',
                      style: TextStyle(
                        color: textColor.withOpacity(0.7),
                        fontSize: 14,
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),
        ),
        actions: [
          TextButton(
            onPressed: () {
              Navigator.pushAndRemoveUntil(
                context,
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
              Navigator.pop(context);
              _startGame();
            },
            style: TextButton.styleFrom(
              backgroundColor: accentColor,
              padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 12),
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(12),
              ),
            ),
            child: const Text(
              'Restart',
              style: TextStyle(
                color: Colors.white,
                fontWeight: FontWeight.w600,
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildCannon() {
    return Container(
      width: 60,
      height: 50,
      decoration: BoxDecoration(
        gradient: LinearGradient(
          begin: Alignment.topCenter,
          end: Alignment.bottomCenter,
          colors: [
            cannonColor.withOpacity(0.8),
            cannonColor,
          ],
        ),
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: Colors.green.withOpacity(0.3), width: 2),
        boxShadow: [
          BoxShadow(
            color: Colors.green.withOpacity(0.3),
            blurRadius: 10,
            spreadRadius: 2,
          ),
        ],
      ),
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Container(
            width: 8,
            height: 20,
            decoration: BoxDecoration(
              color: Colors.green.shade300,
              borderRadius: BorderRadius.circular(4),
              boxShadow: [
                BoxShadow(
                  color: Colors.green.withOpacity(0.5),
                  blurRadius: 4,
                ),
              ],
            ),
          ),
          const SizedBox(height: 4),
          Container(
            width: 40,
            height: 20,
            decoration: BoxDecoration(
              color: Colors.green.shade600,
              borderRadius: BorderRadius.circular(8),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildBullet(Offset position) {
    return Container(
      width: 8,
      height: 20,
      decoration: BoxDecoration(
        gradient: LinearGradient(
          begin: Alignment.topCenter,
          end: Alignment.bottomCenter,
          colors: [
            bulletColor,
            bulletColor.withOpacity(0.6),
          ],
        ),
        borderRadius: BorderRadius.circular(4),
        boxShadow: [
          BoxShadow(
            color: bulletColor.withOpacity(0.6),
            blurRadius: 8,
            spreadRadius: 2,
          ),
        ],
      ),
    );
  }

  Widget _buildAlien(Offset position) {
    return Container(
      width: 40,
      height: 40,
      decoration: BoxDecoration(
        color: alienColor,
        borderRadius: BorderRadius.circular(20),
        border: Border.all(color: Colors.red.withOpacity(0.5), width: 2),
        boxShadow: [
          BoxShadow(
            color: Colors.red.withOpacity(0.4),
            blurRadius: 8,
            spreadRadius: 2,
          ),
        ],
      ),
      child: Icon(
        Icons.bug_report,
        color: Colors.red.shade300,
        size: 24,
      ),
    );
  }

  // Helper method to get safe opacity value
  double _getExplosionOpacity() {
    final value = _explosionController.value;
    return (1.0 - value).clamp(0.0, 1.0);
  }

  Widget _buildExplosion(Offset position) {
    return AnimatedBuilder(
      animation: _explosionController,
      builder: (context, child) {
        final opacity = _getExplosionOpacity();
        return Container(
          width: 30 + (_explosionController.value * 20),
          height: 30 + (_explosionController.value * 20),
          decoration: BoxDecoration(
            color: Colors.orange.withOpacity(opacity),
            borderRadius: BorderRadius.circular(50),
            boxShadow: [
              BoxShadow(
                color: Colors.orange.withOpacity((0.8 - _explosionController.value).clamp(0.0, 1.0)),
                blurRadius: 20,
                spreadRadius: 10,
              ),
            ],
          ),
        );
      },
    );
  }

  @override
  void dispose() {
    _gameLoop.cancel();
    _alienSpawner?.cancel();
    _shootingTimer?.cancel();
    _explosionController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: backgroundColor,
      body: Container(
        decoration: BoxDecoration(
          gradient: LinearGradient(
            begin: Alignment.topCenter,
            end: Alignment.bottomCenter,
            colors: [
              backgroundColor,
              const Color(0xFF0D1B2A),
              const Color(0xFF1B263B),
            ],
          ),
        ),
        child: GestureDetector(
          onHorizontalDragUpdate: (details) => _moveCannon(details.delta.dx),
          child: Stack(
            children: [
              // Stars background
              ...List.generate(50, (index) {
                final random = Random(index);
                return Positioned(
                  left: random.nextDouble() * MediaQuery.of(context).size.width,
                  top: random.nextDouble() * MediaQuery.of(context).size.height,
                  child: Container(
                    width: 2,
                    height: 2,
                    decoration: BoxDecoration(
                      color: Colors.white.withOpacity(0.6),
                      borderRadius: BorderRadius.circular(1),
                    ),
                  ),
                );
              }),

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
                        "$score",
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

              // Game instructions
              Positioned(
                top: 60,
                right: 24,
                child: Container(
                  padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
                  decoration: BoxDecoration(
                    color: Colors.black.withOpacity(0.6),
                    borderRadius: BorderRadius.circular(20),
                    border: Border.all(color: Colors.white.withOpacity(0.2)),
                  ),
                  child: Text(
                    "Drag to move",
                    style: TextStyle(
                      color: textColor.withOpacity(0.8),
                      fontSize: 14,
                      fontWeight: FontWeight.w500,
                    ),
                  ),
                ),
              ),

              // Cannon
              Positioned(
                bottom: 20,
                left: cannonX,
                child: _buildCannon(),
              ),

              // Bullets
              ...bullets.map((b) => Positioned(
                left: b.dx,
                top: b.dy,
                child: _buildBullet(b),
              )),

              // Aliens
              ...aliens.map((a) => Positioned(
                left: a.dx,
                top: a.dy,
                child: _buildAlien(a),
              )),

              // Explosions
              ...explosions.map((e) => Positioned(
                left: e.dx,
                top: e.dy,
                child: _buildExplosion(e),
              )),
            ],
          ),
        ),
      ),
    );
  }
}

