import 'package:flutter/material.dart';
import 'package:zabimaru/screens/option_screen.dart';

class TwoPlayerGame extends StatefulWidget {
  const TwoPlayerGame({super.key});

  @override
  State<TwoPlayerGame> createState() => _TwoPlayerGameState();
}

class _TwoPlayerGameState extends State<TwoPlayerGame> with TickerProviderStateMixin {
  List<String> board = List.filled(9, "");
  String currentPlayer = "X";
  String? winner;
  int player1Score = 0;
  int player2Score = 0;
  List<int> winningLine = [];

  late AnimationController _pulseController;
  late AnimationController _turnController;
  late Animation<double> _pulseAnimation;
  late Animation<double> _turnAnimation;

  @override
  void initState() {
    super.initState();
    _pulseController = AnimationController(
      duration: const Duration(milliseconds: 1000),
      vsync: this,
    );
    _turnController = AnimationController(
      duration: const Duration(milliseconds: 500),
      vsync: this,
    );

    _pulseAnimation = Tween<double>(
      begin: 0.8,
      end: 1.2,
    ).animate(CurvedAnimation(
      parent: _pulseController,
      curve: Curves.easeInOut,
    ));

    _turnAnimation = Tween<double>(
      begin: 0.0,
      end: 1.0,
    ).animate(CurvedAnimation(
      parent: _turnController,
      curve: Curves.elasticOut,
    ));

    _pulseController.repeat(reverse: true);
  }

  @override
  void dispose() {
    _pulseController.dispose();
    _turnController.dispose();
    super.dispose();
  }

  void _handleTap(int index) {
    if (board[index] == "" && winner == null) {
      setState(() {
        board[index] = currentPlayer;
        winner = _checkWinner();
        if (winner != null) {
          _updateScore();
        }
        currentPlayer = currentPlayer == "X" ? "O" : "X";
      });

      _turnController.reset();
      _turnController.forward();
    }
  }

  void _updateScore() {
    if (winner == "X") {
      player1Score++;
    } else if (winner == "O") {
      player2Score++;
    }
  }

  String? _checkWinner() {
    const winPatterns = [
      [0, 1, 2], [3, 4, 5], [6, 7, 8], // rows
      [0, 3, 6], [1, 4, 7], [2, 5, 8], // columns
      [0, 4, 8], [2, 4, 6], // diagonals
    ];

    for (var pattern in winPatterns) {
      String a = board[pattern[0]];
      String b = board[pattern[1]];
      String c = board[pattern[2]];
      if (a != "" && a == b && b == c) {
        winningLine = pattern;
        return a;
      }
    }

    if (!board.contains("")) return "Draw";
    return null;
  }

  void _resetGame() {
    setState(() {
      board = List.filled(9, "");
      currentPlayer = "X";
      winner = null;
      winningLine = [];
    });
  }

  Widget _buildBoard() {
    return Container(
      padding: const EdgeInsets.all(20),
      child: AspectRatio(
        aspectRatio: 1.0,
        child: Container(
          decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(20),
            boxShadow: [
              BoxShadow(
                color: Colors.cyan.withOpacity(0.3),
                blurRadius: 20,
                spreadRadius: 5,
              ),
            ],
          ),
          child: GridView.builder(
            physics: const NeverScrollableScrollPhysics(),
            gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
              crossAxisCount: 3,
              crossAxisSpacing: 8,
              mainAxisSpacing: 8,
            ),
            itemCount: 9,
            itemBuilder: (ctx, i) => _buildCell(i),
          ),
        ),
      ),
    );
  }

  Widget _buildCell(int index) {
    bool isWinningCell = winningLine.contains(index);
    bool isEmpty = board[index] == "";

    return GestureDetector(
      onTap: () => _handleTap(index),
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 300),
        decoration: BoxDecoration(
          gradient: LinearGradient(
            begin: Alignment.topLeft,
            end: Alignment.bottomRight,
            colors: isWinningCell
                ? [Colors.yellowAccent.withOpacity(0.8), Colors.amber.withOpacity(0.6)]
                : isEmpty
                ? [Colors.grey[800]!, Colors.grey[900]!]
                : [Colors.grey[700]!, Colors.grey[800]!],
          ),
          borderRadius: BorderRadius.circular(15),
          border: Border.all(
            color: isWinningCell
                ? Colors.yellowAccent
                : isEmpty
                ? Colors.cyan.withOpacity(0.3)
                : Colors.transparent,
            width: 2,
          ),
          boxShadow: [
            BoxShadow(
              color: isWinningCell
                  ? Colors.yellowAccent.withOpacity(0.5)
                  : Colors.black.withOpacity(0.3),
              blurRadius: isWinningCell ? 10 : 5,
              offset: const Offset(0, 2),
            ),
          ],
        ),
        child: Center(
          child: AnimatedSwitcher(
            duration: const Duration(milliseconds: 300),
            child: board[index] == ""
                ? const SizedBox.shrink()
                : AnimatedBuilder(
              animation: isWinningCell ? _pulseAnimation : _turnAnimation,
              builder: (context, child) {
                return Transform.scale(
                  scale: isWinningCell ? _pulseAnimation.value : _turnAnimation.value,
                  child: Text(
                    board[index] == "X" ? "⚡" : "🔥",
                    style: TextStyle(
                      fontSize: 36,
                      shadows: [
                        Shadow(
                          color: board[index] == "X" ? Colors.yellow : Colors.orange,
                          blurRadius: 10,
                        ),
                      ],
                    ),
                  ),
                );
              },
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildScoreBoard() {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 15),
      margin: const EdgeInsets.symmetric(horizontal: 20),
      decoration: BoxDecoration(
        gradient: LinearGradient(
          colors: [Colors.purple[900]!, Colors.indigo[900]!],
        ),
        borderRadius: BorderRadius.circular(15),
        boxShadow: [
          BoxShadow(
            color: Colors.purple.withOpacity(0.3),
            blurRadius: 10,
            offset: const Offset(0, 5),
          ),
        ],
      ),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceEvenly,
        children: [
          _buildPlayerScore("⚡ Player 1", player1Score, Colors.yellow, currentPlayer == "X"),
          Container(
            width: 2,
            height: 40,
            color: Colors.white.withOpacity(0.3),
          ),
          _buildPlayerScore("🔥 Player 2", player2Score, Colors.orange, currentPlayer == "O"),
        ],
      ),
    );
  }

  Widget _buildPlayerScore(String label, int score, Color color, bool isActive) {
    return AnimatedContainer(
      duration: const Duration(milliseconds: 300),
      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 5),
      decoration: BoxDecoration(
        color: isActive ? color.withOpacity(0.2) : Colors.transparent,
        borderRadius: BorderRadius.circular(10),
        border: isActive ? Border.all(color: color.withOpacity(0.5), width: 2) : null,
      ),
      child: Column(
        children: [
          Text(
            label,
            style: TextStyle(
              color: isActive ? color : color.withOpacity(0.7),
              fontSize: 16,
              fontWeight: FontWeight.bold,
            ),
          ),
          const SizedBox(height: 5),
          Text(
            "$score",
            style: TextStyle(
              color: isActive ? Colors.white : Colors.white.withOpacity(0.7),
              fontSize: 24,
              fontWeight: FontWeight.bold,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildStatusMessage() {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 20),
      child: AnimatedSwitcher(
        duration: const Duration(milliseconds: 300),
        child: Text(
          winner == null
              ? currentPlayer == "X"
              ? "⚡ Player 1's Turn"
              : "🔥 Player 2's Turn"
              : winner == "Draw"
              ? "🤝 It's a Draw!"
              : winner == "X"
              ? "🎉 Player 1 Wins!"
              : "🎉 Player 2 Wins!",
          key: ValueKey(winner ?? currentPlayer),
          style: TextStyle(
            color: winner == null
                ? (currentPlayer == "X" ? Colors.yellow : Colors.orange)
                : winner == "Draw"
                ? Colors.cyan
                : Colors.green,
            fontSize: 24,
            fontWeight: FontWeight.bold,
            shadows: [
              Shadow(
                color: winner == null
                    ? (currentPlayer == "X" ? Colors.yellow : Colors.orange)
                    : winner == "Draw"
                    ? Colors.cyan
                    : Colors.green,
                blurRadius: 10,
              ),
            ],
          ),
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.black,
      appBar: AppBar(
        title: const Text(
          "⚡ 2 Player Battle 🔥",
          style: TextStyle(
            color: Colors.white,
            fontWeight: FontWeight.bold,
          ),
        ),
        backgroundColor: Colors.transparent,
        elevation: 0,
        flexibleSpace: Container(
          decoration: BoxDecoration(
            gradient: LinearGradient(
              colors: [Colors.purple[900]!, Colors.indigo[900]!],
            ),
          ),
        ),
      ),
      body: Column(
        children: [
          const SizedBox(height: 20),
          _buildScoreBoard(),
          const SizedBox(height: 20),
          _buildStatusMessage(),
          const SizedBox(height: 20),
          Expanded(child: _buildBoard()),
          const SizedBox(height: 20),
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 20),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceEvenly,
              children: [
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
                  onPressed: _resetGame,
                  style: TextButton.styleFrom(
                    backgroundColor: const Color(0xFF4A90E2), // accentColor
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
          ),
          const SizedBox(height: 20),
        ],
      ),
    );
  }
}


