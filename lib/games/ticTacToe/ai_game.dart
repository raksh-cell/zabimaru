import 'dart:async';
import 'dart:math';
import 'package:flutter/material.dart';
import 'package:zabimaru/screens/option_screen.dart';

class AIGame extends StatefulWidget {
  const AIGame({super.key});

  @override
  State<AIGame> createState() => _AIGameState();
}

class _AIGameState extends State<AIGame> with TickerProviderStateMixin {
  List<String> board = List.filled(9, "");
  String currentPlayer = "X"; // Human always "X"
  String? winner;
  bool aiThinking = false;
  int playerScore = 0;
  int aiScore = 0;
  List<int> winningLine = [];

  late AnimationController _pulseController;
  late AnimationController _rotationController;
  late Animation<double> _pulseAnimation;
  late Animation<double> _rotationAnimation;

  @override
  void initState() {
    super.initState();
    _pulseController = AnimationController(
      duration: const Duration(milliseconds: 1000),
      vsync: this,
    );
    _rotationController = AnimationController(
      duration: const Duration(milliseconds: 2000),
      vsync: this,
    );

    _pulseAnimation = Tween<double>(
      begin: 0.8,
      end: 1.2,
    ).animate(CurvedAnimation(
      parent: _pulseController,
      curve: Curves.easeInOut,
    ));

    _rotationAnimation = Tween<double>(
      begin: 0.0,
      end: 1.0,
    ).animate(CurvedAnimation(
      parent: _rotationController,
      curve: Curves.linear,
    ));

    _pulseController.repeat(reverse: true);
    _rotationController.repeat();
  }

  @override
  void dispose() {
    _pulseController.dispose();
    _rotationController.dispose();
    super.dispose();
  }

  void _handleTap(int index) {
    if (board[index] == "" && winner == null && !aiThinking) {
      setState(() {
        board[index] = "X";
        winner = _checkWinner();
        if (winner != null) {
          _updateScore();
        }
      });

      if (winner == null) {
        setState(() {
          aiThinking = true;
        });
        Future.delayed(const Duration(milliseconds: 800), _makeAIMove);
      }
    }
  }

  void _makeAIMove() {
    List<int> emptyCells = [];
    for (int i = 0; i < 9; i++) {
      if (board[i] == "") emptyCells.add(i);
    }

    if (emptyCells.isEmpty) return;

    int bestMove;

    // 25% chance to make a mistake for balanced gameplay
    if (Random().nextDouble() < 0.25) {
      bestMove = emptyCells[Random().nextInt(emptyCells.length)];
    } else {
      bestMove = _getBestMove(board, "O");
    }

    setState(() {
      board[bestMove] = "O";
      winner = _checkWinner();
      aiThinking = false;
      if (winner != null) {
        _updateScore();
      }
    });
  }

  void _updateScore() {
    if (winner == "X") {
      playerScore++;
    } else if (winner == "O") {
      aiScore++;
    }
  }

  int _getBestMove(List<String> boardState, String player) {
    int bestScore = -1000;
    int move = -1;

    for (int i = 0; i < 9; i++) {
      if (boardState[i] == "") {
        boardState[i] = player;
        int score = _minimax(boardState, 0, false);
        boardState[i] = "";
        if (score > bestScore) {
          bestScore = score;
          move = i;
        }
      }
    }

    return move;
  }

  int _minimax(List<String> boardState, int depth, bool isMaximizing) {
    String? result = _checkWinnerForMinimax(boardState);
    if (result != null) {
      if (result == "O") return 10 - depth;
      if (result == "X") return depth - 10;
      if (result == "Draw") return 0;
    }

    if (isMaximizing) {
      int bestScore = -1000;
      for (int i = 0; i < 9; i++) {
        if (boardState[i] == "") {
          boardState[i] = "O";
          int score = _minimax(boardState, depth + 1, false);
          boardState[i] = "";
          bestScore = max(score, bestScore);
        }
      }
      return bestScore;
    } else {
      int bestScore = 1000;
      for (int i = 0; i < 9; i++) {
        if (boardState[i] == "") {
          boardState[i] = "X";
          int score = _minimax(boardState, depth + 1, true);
          boardState[i] = "";
          bestScore = min(score, bestScore);
        }
      }
      return bestScore;
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

  String? _checkWinnerForMinimax(List<String> b) {
    const winPatterns = [
      [0, 1, 2], [3, 4, 5], [6, 7, 8],
      [0, 3, 6], [1, 4, 7], [2, 5, 8],
      [0, 4, 8], [2, 4, 6],
    ];

    for (var pattern in winPatterns) {
      String a = b[pattern[0]];
      String b1 = b[pattern[1]];
      String c = b[pattern[2]];
      if (a != "" && a == b1 && b1 == c) return a;
    }

    if (!b.contains("")) return "Draw";
    return null;
  }

  void _resetGame() {
    setState(() {
      board = List.filled(9, "");
      currentPlayer = "X";
      winner = null;
      aiThinking = false;
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
              animation: isWinningCell ? _pulseAnimation : _rotationAnimation,
              builder: (context, child) {
                return Transform.scale(
                  scale: isWinningCell ? _pulseAnimation.value : 1.0,
                  child: Transform.rotate(
                    angle: board[index] == "O" && !isWinningCell
                        ? _rotationAnimation.value * 2 * pi * 0.1
                        : 0,
                    child: Text(
                      board[index] == "X" ? "⚡" : "🤖",
                      style: TextStyle(
                        fontSize: 36,
                        shadows: [
                          Shadow(
                            color: board[index] == "X" ? Colors.yellow : Colors.cyan,
                            blurRadius: 10,
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
      ),
    );
  }

  Widget _buildStatusBar() {
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
          Column(
            children: [
              const Text(
                "⚡ YOU",
                style: TextStyle(
                  color: Colors.yellow,
                  fontSize: 16,
                  fontWeight: FontWeight.bold,
                ),
              ),
              Text(
                "$playerScore",
                style: const TextStyle(
                  color: Colors.white,
                  fontSize: 24,
                  fontWeight: FontWeight.bold,
                ),
              ),
            ],
          ),
          Container(
            width: 2,
            height: 40,
            color: Colors.white.withOpacity(0.3),
          ),
          Column(
            children: [
              const Text(
                "🤖 AI",
                style: TextStyle(
                  color: Colors.cyan,
                  fontSize: 16,
                  fontWeight: FontWeight.bold,
                ),
              ),
              Text(
                "$aiScore",
                style: const TextStyle(
                  color: Colors.white,
                  fontSize: 24,
                  fontWeight: FontWeight.bold,
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.black,
      appBar: AppBar(
        title: const Text(
          "⚡ TIC TAC TOE vs AI 🤖",
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
          _buildStatusBar(),
          const SizedBox(height: 20),
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 20),
            child: AnimatedSwitcher(
              duration: const Duration(milliseconds: 300),
              child: Text(
                winner == null
                    ? (aiThinking ? "🤖 AI is thinking..." : "⚡ Your Turn")
                    : (winner == "Draw"
                    ? "🤝 It's a Draw!"
                    : winner == "X"
                    ? "🎉 You Win!"
                    : "🤖 AI Wins!"),
                key: ValueKey(winner ?? (aiThinking ? "thinking" : "your_turn")),
                style: TextStyle(
                  color: winner == null
                      ? (aiThinking ? Colors.cyan : Colors.yellow)
                      : winner == "Draw"
                      ? Colors.orange
                      : winner == "X"
                      ? Colors.green
                      : Colors.red,
                  fontSize: 24,
                  fontWeight: FontWeight.bold,
                  shadows: [
                    Shadow(
                      color: winner == null
                          ? (aiThinking ? Colors.cyan : Colors.yellow)
                          : winner == "Draw"
                          ? Colors.orange
                          : winner == "X"
                          ? Colors.green
                          : Colors.red,
                      blurRadius: 10,
                    ),
                  ],
                ),
              ),
            ),
          ),
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
                    backgroundColor: const Color(0xFF4A90E2),
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































// import 'dart:async';
// import 'dart:math';
// import 'package:flutter/material.dart';
//
// class AIGame extends StatefulWidget {
//   const AIGame({super.key});
//
//   @override
//   State<AIGame> createState() => _AIGameState();
// }
//
// class _AIGameState extends State<AIGame> with TickerProviderStateMixin {
//   List<String> board = List.filled(9, "");
//   String currentPlayer = "X"; // Human always "X"
//   String? winner;
//   bool aiThinking = false;
//   int playerScore = 0;
//   int aiScore = 0;
//   List<int> winningLine = [];
//
//   late AnimationController _pulseController;
//   late AnimationController _rotationController;
//   late Animation<double> _pulseAnimation;
//   late Animation<double> _rotationAnimation;
//
//   @override
//   void initState() {
//     super.initState();
//     _pulseController = AnimationController(
//       duration: const Duration(milliseconds: 1000),
//       vsync: this,
//     );
//     _rotationController = AnimationController(
//       duration: const Duration(milliseconds: 2000),
//       vsync: this,
//     );
//
//     _pulseAnimation = Tween<double>(
//       begin: 0.8,
//       end: 1.2,
//     ).animate(CurvedAnimation(
//       parent: _pulseController,
//       curve: Curves.easeInOut,
//     ));
//
//     _rotationAnimation = Tween<double>(
//       begin: 0.0,
//       end: 1.0,
//     ).animate(CurvedAnimation(
//       parent: _rotationController,
//       curve: Curves.linear,
//     ));
//
//     _pulseController.repeat(reverse: true);
//     _rotationController.repeat();
//   }
//
//   @override
//   void dispose() {
//     _pulseController.dispose();
//     _rotationController.dispose();
//     super.dispose();
//   }
//
//   void _handleTap(int index) {
//     if (board[index] == "" && winner == null && !aiThinking) {
//       setState(() {
//         board[index] = "X";
//         winner = _checkWinner();
//         if (winner != null) {
//           _updateScore();
//         }
//       });
//
//       if (winner == null) {
//         setState(() {
//           aiThinking = true;
//         });
//         Future.delayed(const Duration(milliseconds: 800), _makeAIMove);
//       }
//     }
//   }
//
//   void _makeAIMove() {
//     List<int> emptyCells = [];
//     for (int i = 0; i < 9; i++) {
//       if (board[i] == "") emptyCells.add(i);
//     }
//
//     if (emptyCells.isEmpty) return;
//
//     int bestMove;
//
//     // 25% chance to make a mistake for balanced gameplay
//     if (Random().nextDouble() < 0.25) {
//       bestMove = emptyCells[Random().nextInt(emptyCells.length)];
//     } else {
//       bestMove = _getBestMove(board, "O");
//     }
//
//     setState(() {
//       board[bestMove] = "O";
//       winner = _checkWinner();
//       aiThinking = false;
//       if (winner != null) {
//         _updateScore();
//       }
//     });
//   }
//
//   void _updateScore() {
//     if (winner == "X") {
//       playerScore++;
//     } else if (winner == "O") {
//       aiScore++;
//     }
//   }
//
//   int _getBestMove(List<String> boardState, String player) {
//     int bestScore = -1000;
//     int move = -1;
//
//     for (int i = 0; i < 9; i++) {
//       if (boardState[i] == "") {
//         boardState[i] = player;
//         int score = _minimax(boardState, 0, false);
//         boardState[i] = "";
//
//         if (score > bestScore) {
//           bestScore = score;
//           move = i;
//         }
//       }
//     }
//
//     return move;
//   }
//
//   int _minimax(List<String> boardState, int depth, bool isMaximizing) {
//     String? result = _checkWinnerForMinimax(boardState);
//     if (result != null) {
//       if (result == "O") return 10 - depth;
//       if (result == "X") return depth - 10;
//       if (result == "Draw") return 0;
//     }
//
//     if (isMaximizing) {
//       int bestScore = -1000;
//       for (int i = 0; i < 9; i++) {
//         if (boardState[i] == "") {
//           boardState[i] = "O";
//           int score = _minimax(boardState, depth + 1, false);
//           boardState[i] = "";
//           bestScore = max(score, bestScore);
//         }
//       }
//       return bestScore;
//     } else {
//       int bestScore = 1000;
//       for (int i = 0; i < 9; i++) {
//         if (boardState[i] == "") {
//           boardState[i] = "X";
//           int score = _minimax(boardState, depth + 1, true);
//           boardState[i] = "";
//           bestScore = min(score, bestScore);
//         }
//       }
//       return bestScore;
//     }
//   }
//
//   String? _checkWinner() {
//     const winPatterns = [
//       [0, 1, 2], [3, 4, 5], [6, 7, 8], // rows
//       [0, 3, 6], [1, 4, 7], [2, 5, 8], // columns
//       [0, 4, 8], [2, 4, 6], // diagonals
//     ];
//
//     for (var pattern in winPatterns) {
//       String a = board[pattern[0]];
//       String b = board[pattern[1]];
//       String c = board[pattern[2]];
//       if (a != "" && a == b && b == c) {
//         winningLine = pattern;
//         return a;
//       }
//     }
//
//     if (!board.contains("")) return "Draw";
//     return null;
//   }
//
//   String? _checkWinnerForMinimax(List<String> b) {
//     const winPatterns = [
//       [0, 1, 2], [3, 4, 5], [6, 7, 8],
//       [0, 3, 6], [1, 4, 7], [2, 5, 8],
//       [0, 4, 8], [2, 4, 6],
//     ];
//
//     for (var pattern in winPatterns) {
//       String a = b[pattern[0]];
//       String b1 = b[pattern[1]];
//       String c = b[pattern[2]];
//       if (a != "" && a == b1 && b1 == c) return a;
//     }
//
//     if (!b.contains("")) return "Draw";
//     return null;
//   }
//
//   void _resetGame() {
//     setState(() {
//       board = List.filled(9, "");
//       currentPlayer = "X";
//       winner = null;
//       aiThinking = false;
//       winningLine = [];
//     });
//   }
//
//   void _resetScores() {
//     setState(() {
//       playerScore = 0;
//       aiScore = 0;
//     });
//     _resetGame();
//   }
//
//   Widget _buildBoard() {
//     return Container(
//       padding: const EdgeInsets.all(20),
//       child: AspectRatio(
//         aspectRatio: 1.0,
//         child: Container(
//           decoration: BoxDecoration(
//             borderRadius: BorderRadius.circular(20),
//             boxShadow: [
//               BoxShadow(
//                 color: Colors.cyan.withOpacity(0.3),
//                 blurRadius: 20,
//                 spreadRadius: 5,
//               ),
//             ],
//           ),
//           child: GridView.builder(
//             physics: const NeverScrollableScrollPhysics(),
//             gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
//               crossAxisCount: 3,
//               crossAxisSpacing: 8,
//               mainAxisSpacing: 8,
//             ),
//             itemCount: 9,
//             itemBuilder: (ctx, i) => _buildCell(i),
//           ),
//         ),
//       ),
//     );
//   }
//
//   Widget _buildCell(int index) {
//     bool isWinningCell = winningLine.contains(index);
//     bool isEmpty = board[index] == "";
//
//     return GestureDetector(
//       onTap: () => _handleTap(index),
//       child: AnimatedContainer(
//         duration: const Duration(milliseconds: 300),
//         decoration: BoxDecoration(
//           gradient: LinearGradient(
//             begin: Alignment.topLeft,
//             end: Alignment.bottomRight,
//             colors: isWinningCell
//                 ? [Colors.yellowAccent.withOpacity(0.8), Colors.amber.withOpacity(0.6)]
//                 : isEmpty
//                 ? [Colors.grey[800]!, Colors.grey[900]!]
//                 : [Colors.grey[700]!, Colors.grey[800]!],
//           ),
//           borderRadius: BorderRadius.circular(15),
//           border: Border.all(
//             color: isWinningCell
//                 ? Colors.yellowAccent
//
//                 : isEmpty
//                 ? Colors.cyan.withOpacity(0.3)
//                 : Colors.transparent,
//             width: 2,
//           ),
//           boxShadow: [
//             BoxShadow(
//               color: isWinningCell
//                   ? Colors.yellowAccent.withOpacity(0.5)
//                   : Colors.black.withOpacity(0.3),
//               blurRadius: isWinningCell ? 10 : 5,
//               offset: const Offset(0, 2),
//             ),
//           ],
//         ),
//         child: Center(
//           child: AnimatedSwitcher(
//             duration: const Duration(milliseconds: 300),
//             child: board[index] == ""
//                 ? const SizedBox.shrink()
//                 : AnimatedBuilder(
//               animation: isWinningCell ? _pulseAnimation : _rotationAnimation,
//               builder: (context, child) {
//                 return Transform.scale(
//                   scale: isWinningCell ? _pulseAnimation.value : 1.0,
//                   child: Transform.rotate(
//                     angle: board[index] == "O" && !isWinningCell
//                         ? _rotationAnimation.value * 2 * pi * 0.1
//                         : 0,
//                     child: Text(
//                       board[index] == "X" ? "⚡" : "🤖",
//                       style: TextStyle(
//                         fontSize: 36,
//                         shadows: [
//                           Shadow(
//                             color: board[index] == "X"
//                                 ? Colors.yellow
//                                 : Colors.cyan,
//                             blurRadius: 10,
//                           ),
//                         ],
//                       ),
//                     ),
//                   ),
//                 );
//               },
//             ),
//           ),
//         ),
//       ),
//     );
//   }
//
//   Widget _buildStatusBar() {
//     return Container(
//       padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 15),
//       margin: const EdgeInsets.symmetric(horizontal: 20),
//       decoration: BoxDecoration(
//         gradient: LinearGradient(
//           colors: [Colors.purple[900]!, Colors.indigo[900]!],
//         ),
//         borderRadius: BorderRadius.circular(15),
//         boxShadow: [
//           BoxShadow(
//             color: Colors.purple.withOpacity(0.3),
//             blurRadius: 10,
//             offset: const Offset(0, 5),
//           ),
//         ],
//       ),
//       child: Row(
//         mainAxisAlignment: MainAxisAlignment.spaceEvenly,
//         children: [
//           Column(
//             children: [
//               const Text(
//                 "⚡ YOU",
//                 style: TextStyle(
//                   color: Colors.yellow,
//                   fontSize: 16,
//                   fontWeight: FontWeight.bold,
//                 ),
//               ),
//               Text(
//                 "$playerScore",
//                 style: const TextStyle(
//                   color: Colors.white,
//                   fontSize: 24,
//                   fontWeight: FontWeight.bold,
//                 ),
//               ),
//             ],
//           ),
//           Container(
//             width: 2,
//             height: 40,
//             color: Colors.white.withOpacity(0.3),
//           ),
//           Column(
//             children: [
//               const Text(
//                 "🤖 AI",
//                 style: TextStyle(
//                   color: Colors.cyan,
//                   fontSize: 16,
//                   fontWeight: FontWeight.bold,
//                 ),
//               ),
//               Text(
//                 "$aiScore",
//                 style: const TextStyle(
//                   color: Colors.white,
//                   fontSize: 24,
//                   fontWeight: FontWeight.bold,
//                 ),
//               ),
//             ],
//           ),
//         ],
//       ),
//     );
//   }
//
//   @override
//   Widget build(BuildContext context) {
//     return Scaffold(
//       backgroundColor: Colors.black,
//       appBar: AppBar(
//         title: const Text(
//           "⚡ TIC TAC TOE vs AI 🤖",
//           style: TextStyle(
//             color: Colors.white,
//             fontWeight: FontWeight.bold,
//           ),
//         ),
//         backgroundColor: Colors.transparent,
//         elevation: 0,
//         flexibleSpace: Container(
//           decoration: BoxDecoration(
//             gradient: LinearGradient(
//               colors: [Colors.purple[900]!, Colors.indigo[900]!],
//             ),
//           ),
//         ),
//       ),
//       body: Column(
//         children: [
//           const SizedBox(height: 20),
//           _buildStatusBar(),
//           const SizedBox(height: 20),
//           Container(
//             padding: const EdgeInsets.symmetric(horizontal: 20),
//             child: AnimatedSwitcher(
//               duration: const Duration(milliseconds: 300),
//               child: Text(
//                 winner == null
//                     ? (aiThinking ? "🤖 AI is thinking..." : "⚡ Your Turn")
//                     : (winner == "Draw"
//                     ? "🤝 It's a Draw!"
//                     : winner == "X"
//                     ? "🎉 You Win!"
//                     : "🤖 AI Wins!"),
//                 key: ValueKey(winner ?? (aiThinking ? "thinking" : "your_turn")),
//                 style: TextStyle(
//                   color: winner == null
//                       ? (aiThinking ? Colors.cyan : Colors.yellow)
//                       : winner == "Draw"
//                       ? Colors.orange
//                       : winner == "X"
//                       ? Colors.green
//                       : Colors.red,
//                   fontSize: 24,
//                   fontWeight: FontWeight.bold,
//                   shadows: [
//                     Shadow(
//                       color: winner == null
//                           ? (aiThinking ? Colors.cyan : Colors.yellow)
//                           : winner == "Draw"
//                           ? Colors.orange
//                           : winner == "X"
//                           ? Colors.green
//                           : Colors.red,
//                       blurRadius: 10,
//                     ),
//                   ],
//                 ),
//               ),
//             ),
//           ),
//           const SizedBox(height: 20),
//           Expanded(child: _buildBoard()),
//           const SizedBox(height: 20),
//           Padding(
//             padding: const EdgeInsets.symmetric(horizontal: 20),
//             child: Row(
//               mainAxisAlignment: MainAxisAlignment.spaceEvenly,
//               children: [
//                 ElevatedButton.icon(
//                   onPressed: _resetGame,
//                   icon: const Icon(Icons.refresh, color: Colors.white),
//                   label: const Text("New Game"),
//                   style: ElevatedButton.styleFrom(
//                     backgroundColor: Colors.blue[700],
//                     foregroundColor: Colors.white,
//                     padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 12),
//                     shape: RoundedRectangleBorder(
//                       borderRadius: BorderRadius.circular(10),
//                     ),
//                   ),
//                 ),
//                 ElevatedButton.icon(
//                   onPressed: _resetScores,
//                   icon: const Icon(Icons.restart_alt, color: Colors.white),
//                   label: const Text("Reset Scores"),
//                   style: ElevatedButton.styleFrom(
//                     backgroundColor: Colors.red[700],
//                     foregroundColor: Colors.white,
//                     padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 12),
//                     shape: RoundedRectangleBorder(
//                       borderRadius: BorderRadius.circular(10),
//                     ),
//                   ),
//                 ),
//               ],
//             ),
//           ),
//           const SizedBox(height: 20),
//         ],
//       ),
//     );
//   }
// }
//
//
//
//
