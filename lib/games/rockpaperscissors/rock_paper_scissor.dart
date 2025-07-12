import 'dart:math';
import 'package:flutter/material.dart';
import 'package:zabimaru/screens/option_screen.dart';

class RockPaperScissorsGame extends StatefulWidget {
  const RockPaperScissorsGame({super.key});

  @override
  State<RockPaperScissorsGame> createState() => _RockPaperScissorsGameState();
}

class _RockPaperScissorsGameState extends State<RockPaperScissorsGame>
    with TickerProviderStateMixin {
  final List<String> choices = ['Rock', 'Paper', 'Scissors'];
  final Map<String, String> emojis = {
    'Rock': '🗿',
    'Paper': '📃',
    'Scissors': '✂️',
  };

  String? playerChoice;
  String? aiChoice;
  String? roundResult;
  int playerScore = 0;
  int aiScore = 0;
  int drawCount = 0;
  int currentRound = 1;
  String? finalResult;

  late AnimationController _battleController;
  late AnimationController _scoreController;
  late AnimationController _glowController;
  late Animation<double> _battleAnimation;
  late Animation<double> _scoreAnimation;
  late Animation<double> _glowAnimation;

  @override
  void initState() {
    super.initState();
    _setupAnimations();
  }

  void _setupAnimations() {
    _battleController = AnimationController(
      duration: const Duration(milliseconds: 800),
      vsync: this,
    );
    _scoreController = AnimationController(
      duration: const Duration(milliseconds: 600),
      vsync: this,
    );
    _glowController = AnimationController(
      duration: const Duration(seconds: 2),
      vsync: this,
    );

    _battleAnimation = Tween<double>(begin: 0.0, end: 1.0).animate(
      CurvedAnimation(parent: _battleController, curve: Curves.elasticOut),
    );
    _scoreAnimation = Tween<double>(begin: 0.8, end: 1.2).animate(
      CurvedAnimation(parent: _scoreController, curve: Curves.elasticOut),
    );
    _glowAnimation = Tween<double>(begin: 0.5, end: 1.0).animate(
      CurvedAnimation(parent: _glowController, curve: Curves.easeInOut),
    );

    _glowController.repeat(reverse: true);
  }

  @override
  void dispose() {
    _battleController.dispose();
    _scoreController.dispose();
    _glowController.dispose();
    super.dispose();
  }

  void play(String choice) {
    if (currentRound > 5) return;

    final ai = choices[Random().nextInt(choices.length)];
    final result = getResult(choice, ai);

    setState(() {
      playerChoice = choice;
      aiChoice = ai;
      roundResult = result;

      if (result == 'VICTORY!') {
        playerScore++;
        _scoreController.forward().then((_) => _scoreController.reverse());
      } else if (result == 'DEFEAT!') {
        aiScore++;
      } else {
        drawCount++;
      }

      if (currentRound == 5) {
        if (playerScore > aiScore) {
          finalResult = '🏆 CHAMPION SUPREME!';
        } else if (aiScore > playerScore) {
          finalResult = '💀 AI DOMINATION!';
        } else {
          finalResult = '⚡ ETERNAL STALEMATE!';
        }
      }

      currentRound++;
    });

    _battleController.forward().then((_) => _battleController.reverse());
  }

  String getResult(String player, String ai) {
    if (player == ai) return 'DRAW!';
    if ((player == 'Rock' && ai == 'Scissors') ||
        (player == 'Paper' && ai == 'Rock') ||
        (player == 'Scissors' && ai == 'Paper')) {
      return 'VICTORY!';
    }
    return 'DEFEAT!';
  }

  void resetMatch() {
    setState(() {
      playerChoice = null;
      aiChoice = null;
      roundResult = null;
      playerScore = 0;
      aiScore = 0;
      drawCount = 0;
      currentRound = 1;
      finalResult = null;
    });
    _battleController.reset();
    _scoreController.reset();
  }

  Color _getResultColor(String? result) {
    switch (result) {
      case 'VICTORY!':
        return const Color(0xFF00FF88);
      case 'DEFEAT!':
        return const Color(0xFFFF4444);
      case 'DRAW!':
        return const Color(0xFFFFAA00);
      default:
        return Colors.white;
    }
  }

  @override
  Widget build(BuildContext context) {
    final matchOver = currentRound > 5;

    return Scaffold(
      backgroundColor: const Color(0xFF0A0A0A),
      appBar: AppBar(
        title: const Text(
          'BATTLE ARENA',
          style: TextStyle(
            color: Colors.white,
            fontWeight: FontWeight.bold,
            letterSpacing: 3,
            fontSize: 20,
          ),
        ),
        backgroundColor: const Color(0xFF1A1A1A),
        elevation: 0,
        iconTheme: const IconThemeData(color: Colors.white),
        centerTitle: true,
        actions: [
          Container(
            margin: const EdgeInsets.only(right: 8),
            child: IconButton(
              icon: Container(
                padding: const EdgeInsets.all(8),
                decoration: BoxDecoration(
                  gradient: const LinearGradient(
                    colors: [Color(0xFFFF4444), Color(0xFFFF6666)],
                  ),
                  borderRadius: BorderRadius.circular(8),
                ),
                child: const Icon(Icons.exit_to_app, color: Colors.white),
              ),
              onPressed: () {
                Navigator.of(context).pushAndRemoveUntil(
                  MaterialPageRoute(builder: (_) => const OptionScreen()),
                      (route) => false,
                );
              },
            ),
          ),
        ],
      ),
      body: Container(
        decoration: const BoxDecoration(
          gradient: LinearGradient(
            begin: Alignment.topCenter,
            end: Alignment.bottomCenter,
            colors: [
              Color(0xFF0A0A0A),
              Color(0xFF1A1A1A),
              Color(0xFF0A0A0A),
            ],
          ),
        ),
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 24),
          child: Column(
            children: [
              // Round Counter
              AnimatedBuilder(
                animation: _glowAnimation,
                builder: (context, child) {
                  return Container(
                    padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 12),
                    decoration: BoxDecoration(
                      gradient: LinearGradient(
                        colors: [
                          Color(0xFF6A0DAD).withOpacity(_glowAnimation.value),
                          Color(0xFF9A4DFF).withOpacity(_glowAnimation.value),
                        ],
                      ),
                      borderRadius: BorderRadius.circular(20),
                      boxShadow: [
                        BoxShadow(
                          color: const Color(0xFF6A0DAD).withOpacity(0.5),
                          blurRadius: 20,
                          spreadRadius: 2,
                        ),
                      ],
                    ),
                    child: Text(
                      'ROUND ${currentRound > 5 ? 5 : currentRound} OF 5',
                      style: const TextStyle(
                        color: Colors.white,
                        fontSize: 18,
                        fontWeight: FontWeight.bold,
                        letterSpacing: 2,
                      ),
                    ),
                  );
                },
              ),

              const SizedBox(height: 30),

              // Score Board
              Container(
                padding: const EdgeInsets.all(20),
                decoration: BoxDecoration(
                  gradient: const LinearGradient(
                    colors: [Color(0xFF2A2A2A), Color(0xFF1A1A1A)],
                  ),
                  borderRadius: BorderRadius.circular(20),
                  border: Border.all(color: const Color(0xFF333333), width: 2),
                ),
                child: Column(
                  children: [
                    const Text(
                      'SCOREBOARD',
                      style: TextStyle(
                        color: Color(0xFF888888),
                        fontSize: 14,
                        fontWeight: FontWeight.bold,
                        letterSpacing: 1,
                      ),
                    ),
                    const SizedBox(height: 16),
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                      children: [
                        AnimatedBuilder(
                          animation: _scoreAnimation,
                          builder: (context, child) {
                            return Transform.scale(
                              scale: roundResult == 'VICTORY!' ? _scoreAnimation.value : 1.0,
                              child: _buildScore("⚔️ WARRIOR", playerScore, const Color(0xFF00FF88)),
                            );
                          },
                        ),
                        Container(height: 40, width: 1, color: const Color(0xFF333333)),
                        _buildScore("🤖 MACHINE", aiScore, const Color(0xFFFF4444)),
                        Container(height: 40, width: 1, color: const Color(0xFF333333)),
                        _buildScore("⚖️ TIES", drawCount, const Color(0xFFFFAA00)),
                      ],
                    ),
                  ],
                ),
              ),

              const SizedBox(height: 40),

              // Battle Arena
              if (playerChoice != null && aiChoice != null)
                AnimatedBuilder(
                  animation: _battleAnimation,
                  builder: (context, child) {
                    return Transform.scale(
                      scale: _battleAnimation.value,
                      child: Container(
                        padding: const EdgeInsets.all(24),
                        decoration: BoxDecoration(
                          gradient: LinearGradient(
                            colors: [
                              _getResultColor(roundResult).withOpacity(0.2),
                              Colors.transparent,
                            ],
                          ),
                          borderRadius: BorderRadius.circular(20),
                          border: Border.all(
                            color: _getResultColor(roundResult),
                            width: 2,
                          ),
                        ),
                        child: Column(
                          children: [
                            const Text(
                              'BATTLE RESULT',
                              style: TextStyle(
                                color: Color(0xFF888888),
                                fontSize: 12,
                                fontWeight: FontWeight.bold,
                                letterSpacing: 1,
                              ),
                            ),
                            const SizedBox(height: 16),
                            Row(
                              mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                              children: [
                                Column(
                                  children: [
                                    Text(
                                      emojis[playerChoice!]!,
                                      style: const TextStyle(fontSize: 48),
                                    ),
                                    const Text(
                                      'YOU',
                                      style: TextStyle(
                                        color: Color(0xFF00FF88),
                                        fontSize: 12,
                                        fontWeight: FontWeight.bold,
                                      ),
                                    ),
                                  ],
                                ),
                                Column(
                                  children: [
                                    const Text(
                                      'VS',
                                      style: TextStyle(
                                        color: Colors.white,
                                        fontSize: 16,
                                        fontWeight: FontWeight.bold,
                                      ),
                                    ),
                                    const SizedBox(height: 8),
                                    Text(
                                      roundResult ?? '',
                                      style: TextStyle(
                                        fontSize: 16,
                                        fontWeight: FontWeight.bold,
                                        color: _getResultColor(roundResult),
                                      ),
                                    ),
                                  ],
                                ),
                                Column(
                                  children: [
                                    Text(
                                      emojis[aiChoice!]!,
                                      style: const TextStyle(fontSize: 48),
                                    ),
                                    const Text(
                                      'AI',
                                      style: TextStyle(
                                        color: Color(0xFFFF4444),
                                        fontSize: 12,
                                        fontWeight: FontWeight.bold,
                                      ),
                                    ),
                                  ],
                                ),
                              ],
                            ),
                          ],
                        ),
                      ),
                    );
                  },
                ),

              const Spacer(),

              // Game Controls
              if (matchOver)
                Container(
                  padding: const EdgeInsets.all(24),
                  decoration: BoxDecoration(
                    gradient: const LinearGradient(
                      colors: [Color(0xFF2A2A2A), Color(0xFF1A1A1A)],
                    ),
                    borderRadius: BorderRadius.circular(20),
                    border: Border.all(color: const Color(0xFF333333), width: 2),
                  ),
                  child: Column(
                    children: [
                      Text(
                        finalResult ?? '',
                        style: const TextStyle(
                          fontSize: 24,
                          color: Color(0xFFFFAA00),
                          fontWeight: FontWeight.bold,
                          letterSpacing: 1,
                        ),
                        textAlign: TextAlign.center,
                      ),
                      const SizedBox(height: 20),
                      Container(
                        width: double.infinity,
                        child: ElevatedButton(
                          onPressed: resetMatch,
                          style: ElevatedButton.styleFrom(
                            backgroundColor: const Color(0xFF00FF88),
                            foregroundColor: Colors.black,
                            padding: const EdgeInsets.symmetric(vertical: 16),
                            shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(12),
                            ),
                          ),
                          child: const Text(
                            "⚡ REMATCH ⚡",
                            style: TextStyle(
                              fontSize: 16,
                              fontWeight: FontWeight.bold,
                              letterSpacing: 1,
                            ),
                          ),
                        ),
                      ),
                    ],
                  ),
                )
              else
                Container(
                  padding: const EdgeInsets.all(24),
                  decoration: BoxDecoration(
                    gradient: const LinearGradient(
                      colors: [Color(0xFF2A2A2A), Color(0xFF1A1A1A)],
                    ),
                    borderRadius: BorderRadius.circular(20),
                    border: Border.all(color: const Color(0xFF333333), width: 2),
                  ),
                  child: Column(
                    children: [
                      const Text(
                        'CHOOSE YOUR WEAPON',
                        style: TextStyle(
                          color: Colors.white,
                          fontSize: 18,
                          fontWeight: FontWeight.bold,
                          letterSpacing: 1,
                        ),
                      ),
                      const SizedBox(height: 20),
                      Row(
                        mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                        children: choices.map((choice) {
                          return Expanded(
                            child: Container(
                              margin: const EdgeInsets.symmetric(horizontal: 4),
                              child: ElevatedButton(
                                style: ElevatedButton.styleFrom(
                                  backgroundColor: const Color(0xFF6A0DAD),
                                  foregroundColor: Colors.white,
                                  padding: const EdgeInsets.symmetric(vertical: 16),
                                  shape: RoundedRectangleBorder(
                                    borderRadius: BorderRadius.circular(12),
                                  ),
                                ),
                                onPressed: () => play(choice),
                                child: Column(
                                  mainAxisSize: MainAxisSize.min,
                                  children: [
                                    Text(
                                      emojis[choice]!,
                                      style: const TextStyle(fontSize: 24),
                                    ),
                                    const SizedBox(height: 4),
                                    Text(
                                      choice.toUpperCase(),
                                      style: const TextStyle(
                                        fontSize: 10,
                                        fontWeight: FontWeight.bold,
                                      ),
                                    ),
                                  ],
                                ),
                              ),
                            ),
                          );
                        }).toList(),
                      ),
                    ],
                  ),
                ),

              const SizedBox(height: 20),

              // Exit Button
              Container(
                width: double.infinity,
                child: ElevatedButton(
                  onPressed: () {
                    Navigator.of(context).pushAndRemoveUntil(
                      MaterialPageRoute(builder: (_) => const OptionScreen()),
                          (route) => false,
                    );
                  },
                  style: ElevatedButton.styleFrom(
                    backgroundColor: const Color(0xFF333333),
                    foregroundColor: const Color(0xFFFF4444),
                    padding: const EdgeInsets.symmetric(vertical: 16),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(12),
                    ),
                  ),
                  child: const Text(
                    "🚪 EXIT ARENA",
                    style: TextStyle(
                      fontSize: 16,
                      fontWeight: FontWeight.bold,
                      letterSpacing: 1,
                    ),
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildScore(String label, int score, Color color) {
    return Column(
      children: [
        Text(
          label,
          style: const TextStyle(
            color: Color(0xFF888888),
            fontSize: 10,
            fontWeight: FontWeight.bold,
          ),
        ),
        const SizedBox(height: 8),
        Container(
          width: 50,
          height: 50,
          decoration: BoxDecoration(
            color: color,
            borderRadius: BorderRadius.circular(25),
            boxShadow: [
              BoxShadow(
                color: color.withOpacity(0.5),
                blurRadius: 10,
                spreadRadius: 2,
              ),
            ],
          ),
          child: Center(
            child: Text(
              score.toString(),
              style: const TextStyle(
                color: Colors.black,
                fontSize: 18,
                fontWeight: FontWeight.bold,
              ),
            ),
          ),
        ),
      ],
    );
  }
}





