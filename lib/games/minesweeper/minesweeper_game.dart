import 'dart:math';
import 'package:flutter/material.dart';
import 'package:zabimaru/screens/option_screen.dart';

class MinesweeperGame extends StatefulWidget {
  const MinesweeperGame({super.key});

  @override
  State<MinesweeperGame> createState() => _MinesweeperGameState();
}

class _MinesweeperGameState extends State<MinesweeperGame> with TickerProviderStateMixin {
  static const int rows = 9;
  static const int cols = 9;
  static const int numMines = 10;

  late List<List<Tile>> grid;
  bool gameOver = false;
  int flagCount = 0;
  late AnimationController _pulseController;
  late Animation<double> _pulseAnimation;

  @override
  void initState() {
    super.initState();
    _initializeGrid();
    _setupAnimations();
  }

  void _setupAnimations() {
    _pulseController = AnimationController(
      duration: const Duration(seconds: 1),
      vsync: this,
    );
    _pulseAnimation = Tween<double>(
      begin: 1.0,
      end: 1.1,
    ).animate(CurvedAnimation(
      parent: _pulseController,
      curve: Curves.easeInOut,
    ));
    _pulseController.repeat(reverse: true);
  }

  @override
  void dispose() {
    _pulseController.dispose();
    super.dispose();
  }

  void _initializeGrid() {
    grid = List.generate(rows, (x) {
      return List.generate(cols, (y) => Tile(x: x, y: y));
    });

    _placeMines();
    _calculateNumbers();
    flagCount = 0;
  }

  void _placeMines() {
    int placed = 0;
    final rand = Random();

    while (placed < numMines) {
      int x = rand.nextInt(rows);
      int y = rand.nextInt(cols);

      if (!grid[x][y].isMine) {
        grid[x][y].isMine = true;
        placed++;
      }
    }
  }

  void _calculateNumbers() {
    for (var row in grid) {
      for (var tile in row) {
        if (!tile.isMine) {
          tile.mineCount = _getAdjacentMines(tile.x, tile.y);
        }
      }
    }
  }

  int _getAdjacentMines(int x, int y) {
    int count = 0;
    for (int dx = -1; dx <= 1; dx++) {
      for (int dy = -1; dy <= 1; dy++) {
        int nx = x + dx;
        int ny = y + dy;

        if (nx >= 0 &&
            ny >= 0 &&
            nx < rows &&
            ny < cols &&
            grid[nx][ny].isMine) {
          count++;
        }
      }
    }
    return count;
  }

  void _revealTile(int x, int y) {
    if (x < 0 || y < 0 || x >= rows || y >= cols) return;
    final tile = grid[x][y];
    if (tile.isRevealed || tile.isFlagged) return;

    setState(() {
      tile.isRevealed = true;
      if (tile.isMine) {
        gameOver = true;
        _showGameOver();
      } else if (tile.mineCount == 0) {
        // recursively reveal
        for (int dx = -1; dx <= 1; dx++) {
          for (int dy = -1; dy <= 1; dy++) {
            _revealTile(x + dx, y + dy);
          }
        }
      }
    });
  }

  void _toggleFlag(int x, int y) {
    if (gameOver) return;
    final tile = grid[x][y];
    if (tile.isRevealed) return;

    setState(() {
      tile.isFlagged = !tile.isFlagged;
      flagCount += tile.isFlagged ? 1 : -1;
    });
  }

  Color _getNumberColor(int count) {
    switch (count) {
      case 1: return const Color(0xFF64B5F6); // Light Blue
      case 2: return const Color(0xFF81C784); // Light Green
      case 3: return const Color(0xFFFFB74D); // Orange
      case 4: return const Color(0xFFBA68C8); // Purple
      case 5: return const Color(0xFFE57373); // Red
      case 6: return const Color(0xFF4FC3F7); // Cyan
      case 7: return const Color(0xFFF06292); // Pink
      case 8: return const Color(0xFF90A4AE); // Blue Grey
      default: return Colors.white;
    }
  }

  void _showGameOver() {
    showDialog(
      context: context,
      barrierDismissible: false,
      builder: (_) => AlertDialog(
        backgroundColor: const Color(0xFF1A1A1A),
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(20),
          side: const BorderSide(color: Color(0xFF333333), width: 2),
        ),
        title: Container(
          padding: const EdgeInsets.all(16),
          decoration: BoxDecoration(
            gradient: const LinearGradient(
              colors: [Color(0xFFFF6B6B), Color(0xFFFF8E8E)],
              begin: Alignment.topLeft,
              end: Alignment.bottomRight,
            ),
            borderRadius: BorderRadius.circular(12),
          ),
          child: const Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Text("💥 BOOM! 💥",
                style: TextStyle(
                  color: Colors.white,
                  fontSize: 24,
                  fontWeight: FontWeight.bold,
                  shadows: [
                    Shadow(
                      blurRadius: 10.0,
                      color: Colors.black54,
                      offset: Offset(2.0, 2.0),
                    ),
                  ],
                ),
              ),
            ],
          ),
        ),
        content: const Text(
          "You hit a mine! Better luck next time!",
          style: TextStyle(
            color: Color(0xFFE0E0E0),
            fontSize: 16,
          ),
          textAlign: TextAlign.center,
        ),
        actions: [
          Container(
            width: double.infinity,
            child: Row(
              children: [
                Expanded(
                  child: Container(
                    margin: const EdgeInsets.only(right: 8),
                    child: ElevatedButton(
                      style: ElevatedButton.styleFrom(
                        backgroundColor: const Color(0xFF333333),
                        foregroundColor: const Color(0xFFFF6B6B),
                        padding: const EdgeInsets.symmetric(vertical: 16),
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(12),
                        ),
                      ),
                      onPressed: () {
                        Navigator.of(context).pushAndRemoveUntil(
                          MaterialPageRoute(builder: (_) => const OptionScreen()),
                              (route) => false,
                        );
                      },
                      child: const Text("Exit", style: TextStyle(fontWeight: FontWeight.bold)),
                    ),
                  ),
                ),
                Expanded(
                  child: Container(
                    margin: const EdgeInsets.only(left: 8),
                    child: ElevatedButton(
                      style: ElevatedButton.styleFrom(
                        backgroundColor: const Color(0xFF4CAF50),
                        foregroundColor: Colors.white,
                        padding: const EdgeInsets.symmetric(vertical: 16),
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(12),
                        ),
                      ),
                      onPressed: () {
                        Navigator.of(context).pop();
                        setState(() {
                          gameOver = false;
                          _initializeGrid();
                        });
                      },
                      child: const Text("Restart", style: TextStyle(fontWeight: FontWeight.bold)),
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
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFF0A0A0A),
      appBar: AppBar(
        title: const Text(
          'MINESWEEPER',
          style: TextStyle(
            color: Colors.white,
            fontWeight: FontWeight.bold,
            letterSpacing: 2,
          ),
        ),
        backgroundColor: const Color(0xFF1A1A1A),
        elevation: 0,
        iconTheme: const IconThemeData(color: Colors.white),
        centerTitle: true,
      ),
      body: Column(
        children: [
          // Stats Panel
          Container(
            margin: const EdgeInsets.all(16),
            padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 16),
            decoration: BoxDecoration(
              gradient: const LinearGradient(
                colors: [Color(0xFF2A2A2A), Color(0xFF1A1A1A)],
                begin: Alignment.topLeft,
                end: Alignment.bottomRight,
              ),
              borderRadius: BorderRadius.circular(20),
              border: Border.all(color: const Color(0xFF333333), width: 1),
              boxShadow: [
                BoxShadow(
                  color: Colors.black.withOpacity(0.5),
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
                      'MINES',
                      style: TextStyle(
                        color: Color(0xFF888888),
                        fontSize: 12,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    const SizedBox(height: 4),
                    AnimatedBuilder(
                      animation: _pulseAnimation,
                      builder: (context, child) {
                        return Transform.scale(
                          scale: _pulseAnimation.value,
                          child: Container(
                            padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
                            decoration: BoxDecoration(
                              color: const Color(0xFFFF6B6B),
                              borderRadius: BorderRadius.circular(8),
                            ),
                            child: Text(
                              '${numMines - flagCount}',
                              style: const TextStyle(
                                color: Colors.white,
                                fontSize: 18,
                                fontWeight: FontWeight.bold,
                              ),
                            ),
                          ),
                        );
                      },
                    ),
                  ],
                ),
                Container(
                  height: 40,
                  width: 1,
                  color: const Color(0xFF333333),
                ),
                Column(
                  children: [
                    const Text(
                      'FLAGS',
                      style: TextStyle(
                        color: Color(0xFF888888),
                        fontSize: 12,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    const SizedBox(height: 4),
                    Container(
                      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
                      decoration: BoxDecoration(
                        color: const Color(0xFF4CAF50),
                        borderRadius: BorderRadius.circular(8),
                      ),
                      child: Text(
                        '$flagCount',
                        style: const TextStyle(
                          color: Colors.white,
                          fontSize: 18,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                    ),
                  ],
                ),
              ],
            ),
          ),
          // Game Grid
          Expanded(
            child: Center(
              child: Container(
                margin: const EdgeInsets.all(16),
                padding: const EdgeInsets.all(16),
                decoration: BoxDecoration(
                  gradient: const LinearGradient(
                    colors: [Color(0xFF1A1A1A), Color(0xFF2A2A2A)],
                    begin: Alignment.topLeft,
                    end: Alignment.bottomRight,
                  ),
                  borderRadius: BorderRadius.circular(24),
                  border: Border.all(color: const Color(0xFF333333), width: 2),
                  boxShadow: [
                    BoxShadow(
                      color: Colors.black.withOpacity(0.7),
                      blurRadius: 20,
                      offset: const Offset(0, 10),
                    ),
                  ],
                ),
                child: GridView.builder(
                  shrinkWrap: true,
                  physics: const NeverScrollableScrollPhysics(),
                  gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
                    crossAxisCount: cols,
                    mainAxisSpacing: 4,
                    crossAxisSpacing: 4,
                  ),
                  itemCount: rows * cols,
                  itemBuilder: (context, index) {
                    final x = index ~/ cols;
                    final y = index % cols;
                    final tile = grid[x][y];

                    return GestureDetector(
                      onTap: () {
                        if (!gameOver) _revealTile(x, y);
                      },
                      onLongPress: () {
                        _toggleFlag(x, y);
                      },
                      child: AnimatedContainer(
                        duration: const Duration(milliseconds: 200),
                        alignment: Alignment.center,
                        decoration: BoxDecoration(
                          gradient: LinearGradient(
                            colors: tile.isRevealed
                                ? tile.isMine
                                ? [const Color(0xFFFF6B6B), const Color(0xFFFF8E8E)]
                                : [const Color(0xFF404040), const Color(0xFF2A2A2A)]
                                : tile.isFlagged
                                ? [const Color(0xFF4CAF50), const Color(0xFF66BB6A)]
                                : [const Color(0xFF505050), const Color(0xFF3A3A3A)],
                            begin: Alignment.topLeft,
                            end: Alignment.bottomRight,
                          ),
                          borderRadius: BorderRadius.circular(8),
                          border: Border.all(
                            color: tile.isRevealed
                                ? tile.isMine
                                ? const Color(0xFFFF4444)
                                : const Color(0xFF555555)
                                : tile.isFlagged
                                ? const Color(0xFF4CAF50)
                                : const Color(0xFF666666),
                            width: 1,
                          ),
                          boxShadow: [
                            BoxShadow(
                              color: Colors.black.withOpacity(0.3),
                              blurRadius: 4,
                              offset: const Offset(0, 2),
                            ),
                          ],
                        ),
                        child: _getTileContent(tile),
                      ),
                    );
                  },
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _getTileContent(Tile tile) {
    if (tile.isFlagged && !tile.isRevealed) {
      return const Text(
        "🚩",
        style: TextStyle(fontSize: 20),
      );
    }

    if (tile.isRevealed) {
      if (tile.isMine) {
        return const Text(
          "💣",
          style: TextStyle(fontSize: 20),
        );
      } else if (tile.mineCount > 0) {
        return Text(
          '${tile.mineCount}',
          style: TextStyle(
            color: _getNumberColor(tile.mineCount),
            fontSize: 18,
            fontWeight: FontWeight.bold,
            shadows: [
              Shadow(
                blurRadius: 3.0,
                color: Colors.black.withOpacity(0.5),
                offset: const Offset(1.0, 1.0),
              ),
            ],
          ),
        );
      }
    }

    return const SizedBox.shrink();
  }
}

class Tile {
  final int x, y;
  bool isMine = false;
  bool isRevealed = false;
  bool isFlagged = false;
  int mineCount = 0;

  Tile({required this.x, required this.y});
}


