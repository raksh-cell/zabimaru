import 'dart:async';
import 'dart:math';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import '../../screens/option_screen.dart';

class SimonSaysGame extends StatefulWidget {
  const SimonSaysGame({super.key});

  @override
  State<SimonSaysGame> createState() => _SimonSaysGameState();
}

class _SimonSaysGameState extends State<SimonSaysGame>
    with SingleTickerProviderStateMixin {
  final List<int> _sequence = [];
  final List<int> _playerInput = [];

  // Dark theme color palette
  final List<Color> _colors = [
    const Color(0xFF8B5A3C), // Dark red-brown
    const Color(0xFF2E5D4F), // Dark green
    const Color(0xFF1E3A8A), // Dark blue
    const Color(0xFF92400E), // Dark amber
  ];

  final List<Color> _glowColors = [
    const Color(0xFFEF4444), // Red glow
    const Color(0xFF10B981), // Green glow
    const Color(0xFF3B82F6), // Blue glow
    const Color(0xFFF59E0B), // Amber glow
  ];

  final Duration _highlightDuration = const Duration(milliseconds: 500);

  int _highlightedIndex = -1;
  bool _isPlayerTurn = false;
  bool _isGameOver = false;
  int _round = 0;
  int _bestScore = 0;
  String _comboMessage = '';

  // Dark theme colors
  final Color backgroundColor = const Color(0xFF0A0A0A);
  final Color cardColor = const Color(0xFF1E1E1E);
  final Color textColor = const Color(0xFFE0E0E0);
  final Color accentColor = const Color(0xFF4A90E2);

  @override
  void initState() {
    super.initState();
    _startGame();
  }

  void _startGame() {
    _sequence.clear();
    _playerInput.clear();
    _round = 0;
    _comboMessage = '';
    _isGameOver = false;
    _addToSequence();
  }

  void _addToSequence() async {
    _playerInput.clear();
    _sequence.add(Random().nextInt(4));
    _round++;

    setState(() {
      _isPlayerTurn = false;
    });

    await _playSequence();

    setState(() {
      _isPlayerTurn = true;
    });
  }

  Future<void> _playSequence() async {
    for (int index in _sequence) {
      setState(() => _highlightedIndex = index);
      await Future.delayed(_highlightDuration);
      setState(() => _highlightedIndex = -1);
      await Future.delayed(const Duration(milliseconds: 300));
    }
  }

  void _handleTap(int index) async {
    if (!_isPlayerTurn || _isGameOver) return;

    HapticFeedback.lightImpact();
    setState(() => _highlightedIndex = index);

    await Future.delayed(const Duration(milliseconds: 200));
    setState(() => _highlightedIndex = -1);

    _playerInput.add(index);
    final currentStep = _playerInput.length - 1;

    if (_playerInput[currentStep] != _sequence[currentStep]) {
      setState(() => _isGameOver = true);
      _showGameOverDialog();
      return;
    }

    if (_playerInput.length == _sequence.length) {
      if (_round >= 10) {
        _comboMessage = "👑 Brain God Mode";
      } else if (_round >= 5) {
        _comboMessage = "💯 Memory Master";
      } else if (_round >= 3) {
        _comboMessage = "🔥 On Fire!";
      } else {
        _comboMessage = '';
      }

      Future.delayed(const Duration(milliseconds: 600), _addToSequence);
    }
  }

  void _showGameOverDialog() {
    if (_round > _bestScore) _bestScore = _round;

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
            Icon(Icons.psychology, color: accentColor, size: 28),
            const SizedBox(width: 12),
            Text(
              'Game Over',
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
                      'Level Reached',
                      style: TextStyle(
                        color: textColor.withOpacity(0.7),
                        fontSize: 14,
                        fontWeight: FontWeight.w500,
                      ),
                    ),
                    const SizedBox(height: 8),
                    Text(
                      '$_round',
                      style: TextStyle(
                        color: accentColor,
                        fontSize: 36,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    const SizedBox(height: 16),
                    Container(
                      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
                      decoration: BoxDecoration(
                        color: Colors.amber.withOpacity(0.2),
                        borderRadius: BorderRadius.circular(20),
                        border: Border.all(color: Colors.amber.withOpacity(0.3)),
                      ),
                      child: Text(
                        'Best: $_bestScore',
                        style: TextStyle(
                          color: Colors.amber.shade300,
                          fontSize: 16,
                          fontWeight: FontWeight.w600,
                        ),
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
              Navigator.of(context).pushReplacement(
                MaterialPageRoute(builder: (_) => const OptionScreen()),
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

  Widget _buildColorButton(int index) {
    final bool isHighlighted = _highlightedIndex == index;
    final bool isAppTurn = !_isPlayerTurn && isHighlighted;
    final bool isPlayerTap = _isPlayerTurn && isHighlighted;

    Color baseColor = _colors[index];
    Color glowColor = _glowColors[index];
    List<BoxShadow> shadow = [];

    if (isAppTurn) {
      shadow = [
        BoxShadow(
          color: glowColor.withOpacity(0.6),
          blurRadius: 25,
          spreadRadius: 8,
        ),
        BoxShadow(
          color: glowColor.withOpacity(0.3),
          blurRadius: 50,
          spreadRadius: 15,
        )
      ];
    } else if (isPlayerTap) {
      shadow = [
        BoxShadow(
          color: Colors.white.withOpacity(0.8),
          blurRadius: 20,
          spreadRadius: 5,
        )
      ];
    } else {
      shadow = [
        BoxShadow(
          color: Colors.black.withOpacity(0.4),
          blurRadius: 8,
          offset: const Offset(0, 4),
        )
      ];
    }

    return GestureDetector(
      onTap: () => _handleTap(index),
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 200),
        margin: const EdgeInsets.all(12),
        decoration: BoxDecoration(
          color: baseColor,
          borderRadius: BorderRadius.circular(20),
          border: Border.all(
            color: isHighlighted
                ? Colors.white.withOpacity(0.4)
                : Colors.white.withOpacity(0.1),
            width: 2,
          ),
          boxShadow: shadow,
        ),
        child: Center(
          child: AnimatedScale(
            scale: isHighlighted ? 0.95 : 1.0,
            duration: const Duration(milliseconds: 100),
            child: Container(
              width: 60,
              height: 60,
              decoration: BoxDecoration(
                color: Colors.white.withOpacity(0.1),
                borderRadius: BorderRadius.circular(30),
                border: Border.all(
                  color: Colors.white.withOpacity(0.2),
                  width: 1,
                ),
              ),
            ),
          ),
        ),
      ),
    );
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
              backgroundColor.withOpacity(0.8),
              const Color(0xFF111111),
            ],
          ),
        ),
        child: SafeArea(
          child: Column(
            children: [
              const SizedBox(height: 30),

              // Game title and level
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 16),
                decoration: BoxDecoration(
                  color: cardColor.withOpacity(0.8),
                  borderRadius: BorderRadius.circular(20),
                  border: Border.all(color: accentColor.withOpacity(0.3)),
                  boxShadow: [
                    BoxShadow(
                      color: Colors.black.withOpacity(0.2),
                      blurRadius: 10,
                      offset: const Offset(0, 4),
                    ),
                  ],
                ),
                child: Column(
                  children: [
                    Text(
                      'SIMON SAYS',
                      style: TextStyle(
                        color: accentColor,
                        fontSize: 20,
                        fontWeight: FontWeight.bold,
                        letterSpacing: 2,
                      ),
                    ),
                    const SizedBox(height: 8),
                    Text(
                      _isGameOver ? 'Game Over' : 'Level $_round',
                      style: TextStyle(
                        color: textColor,
                        fontSize: 28,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                  ],
                ),
              ),

              // Combo message
              if (_comboMessage.isNotEmpty)
                Container(
                  margin: const EdgeInsets.only(top: 16),
                  padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 10),
                  decoration: BoxDecoration(
                    color: Colors.amber.withOpacity(0.2),
                    borderRadius: BorderRadius.circular(25),
                    border: Border.all(color: Colors.amber.withOpacity(0.3)),
                  ),
                  child: Text(
                    _comboMessage,
                    style: TextStyle(
                      color: Colors.amber.shade300,
                      fontSize: 18,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                ),

              const SizedBox(height: 30),

              // Game grid
              Expanded(
                child: Container(
                  margin: const EdgeInsets.all(20),
                  padding: const EdgeInsets.all(20),
                  decoration: BoxDecoration(
                    color: cardColor.withOpacity(0.3),
                    borderRadius: BorderRadius.circular(24),
                    border: Border.all(color: Colors.white.withOpacity(0.1)),
                  ),
                  child: GridView.count(
                    crossAxisCount: 2,
                    children: List.generate(4, _buildColorButton),
                  ),
                ),
              ),

              // Status indicator
              Container(
                margin: const EdgeInsets.only(bottom: 30),
                padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 12),
                decoration: BoxDecoration(
                  color: _isPlayerTurn
                      ? Colors.green.withOpacity(0.2)
                      : Colors.orange.withOpacity(0.2),
                  borderRadius: BorderRadius.circular(25),
                  border: Border.all(
                    color: _isPlayerTurn
                        ? Colors.green.withOpacity(0.3)
                        : Colors.orange.withOpacity(0.3),
                  ),
                ),
                child: Row(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Icon(
                      _isPlayerTurn ? Icons.touch_app : Icons.visibility,
                      color: _isPlayerTurn ? Colors.green : Colors.orange,
                      size: 20,
                    ),
                    const SizedBox(width: 8),
                    Text(
                      _isPlayerTurn ? "Your Turn" : "Watch Pattern",
                      style: TextStyle(
                        color: _isPlayerTurn ? Colors.green : Colors.orange,
                        fontSize: 16,
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}






