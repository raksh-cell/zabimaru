import 'package:flutter/material.dart';
import 'package:zabimaru/screens/option_screen.dart';

class Block {
  final double width;
  final double left;

  Block({required this.width, required this.left});
}

class StackTowerGame extends StatefulWidget {
  const StackTowerGame({super.key});

  @override
  State<StackTowerGame> createState() => _StackTowerGameState();
}

class _StackTowerGameState extends State<StackTowerGame>
    with SingleTickerProviderStateMixin {
  late AnimationController _controller;
  late Animation<double> _animation;

  List<Block> stackedBlocks = [];
  double blockWidth = 200;
  double blockHeight = 20;
  double blockX = 0;
  double speed = 2.5;
  bool movingRight = true;
  bool isGameOver = false;

  final double baseOffset = 100;

  // Dark theme colors
  final Color backgroundColor = const Color(0xFF0A0A0A);
  final Color blockColor = const Color(0xFF2D2D2D);
  final Color accentColor = const Color(0xFF4A90E2);
  final Color movingBlockColor = const Color(0xFF64B5F6);
  final Color textColor = const Color(0xFFE0E0E0);
  final Color dialogBackgroundColor = const Color(0xFF1E1E1E);

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) => _setupGame());
  }

  void _setupGame() {
    final screenWidth = MediaQuery.of(context).size.width;
    final startLeft = (screenWidth - blockWidth) / 2;
    stackedBlocks.add(Block(width: blockWidth, left: startLeft));

    _controller = AnimationController(
      vsync: this,
      duration: const Duration(days: 1),
    );

    _animation = Tween<double>(begin: 0, end: 1).animate(_controller)
      ..addListener(() {
        if (!isGameOver) {
          setState(() {
            blockX += movingRight ? speed : -speed;
            if (blockX <= 0 ||
                blockX + blockWidth >= MediaQuery.of(context).size.width) {
              movingRight = !movingRight;
            }
          });
        }
      });

    _controller.forward();
  }

  void dropBlock() async {
    if (stackedBlocks.isEmpty) return;

    final newLeft = blockX;
    final newRight = blockX + blockWidth;

    final lastBlock = stackedBlocks.last;
    final lastLeft = lastBlock.left;
    final lastRight = lastBlock.left + lastBlock.width;

    final overlapLeft = newLeft > lastLeft ? newLeft : lastLeft;
    final overlapRight = newRight < lastRight ? newRight : lastRight;
    final newBlockWidth = overlapRight - overlapLeft;

    if (newBlockWidth <= 10) {
      isGameOver = true;
      _controller.stop();
      showGameOver();
      return;
    }

    setState(() {
      stackedBlocks.add(Block(width: newBlockWidth, left: overlapLeft));
    });

    await Future.delayed(const Duration(milliseconds: 200));

    setState(() {
      blockWidth = newBlockWidth;
      blockX = 0;
      movingRight = true;
    });
  }

  void showGameOver() {
    showDialog(
      context: context,
      barrierColor: Colors.black87,
      builder: (_) => AlertDialog(
        backgroundColor: dialogBackgroundColor,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(16),
          side: BorderSide(color: accentColor.withOpacity(0.3), width: 1),
        ),
        title: Row(
          children: [
            Icon(Icons.games, color: accentColor, size: 28),
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
                padding: const EdgeInsets.all(16),
                decoration: BoxDecoration(
                  color: accentColor.withOpacity(0.1),
                  borderRadius: BorderRadius.circular(12),
                  border: Border.all(color: accentColor.withOpacity(0.3)),
                ),
                child: Column(
                  children: [
                    Text(
                      'Final Score',
                      style: TextStyle(
                        color: textColor.withOpacity(0.7),
                        fontSize: 14,
                        fontWeight: FontWeight.w500,
                      ),
                    ),
                    const SizedBox(height: 8),
                    Text(
                      '${stackedBlocks.length - 1}',
                      style: TextStyle(
                        color: accentColor,
                        fontSize: 32,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    Text(
                      'blocks stacked',
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
              Navigator.of(context).pushAndRemoveUntil(
                MaterialPageRoute(builder: (_) => const OptionScreen()),
                    (route) => false,
              );
            },
            style: TextButton.styleFrom(
              padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 12),
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(8),
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
              resetGame();
            },
            style: TextButton.styleFrom(
              backgroundColor: accentColor,
              padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 12),
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(8),
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

  void resetGame() {
    final screenWidth = MediaQuery.of(context).size.width;
    final startLeft = (screenWidth - 200) / 2;

    setState(() {
      stackedBlocks = [Block(width: 200, left: startLeft)];
      blockWidth = 200;
      blockX = 0;
      movingRight = true;
      isGameOver = false;
    });

    _controller.forward();
  }

  Color getBlockColor(int index) {
    // Create a subtle gradient effect with dark theme colors
    final List<Color> darkColors = [
      const Color(0xFF2D2D2D),
      const Color(0xFF3A3A3A),
      const Color(0xFF404040),
      const Color(0xFF4A4A4A),
      const Color(0xFF505050),
      const Color(0xFF5A5A5A),
    ];
    return darkColors[index % darkColors.length];
  }

  @override
  void dispose() {
    _controller.dispose();
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
              backgroundColor.withOpacity(0.8),
              const Color(0xFF111111),
            ],
          ),
        ),
        child: GestureDetector(
          behavior: HitTestBehavior.opaque,
          onTap: dropBlock,
          child: SizedBox.expand(
            child: Stack(
              children: [
                // Background grid pattern
                Positioned.fill(
                  child: CustomPaint(
                    painter: GridPainter(color: Colors.white.withOpacity(0.03)),
                  ),
                ),

                // Stacked blocks
                ...stackedBlocks.map((block) {
                  final index = stackedBlocks.indexOf(block);
                  return Positioned(
                    bottom: baseOffset + index * blockHeight,
                    left: block.left,
                    child: Container(
                      width: block.width,
                      height: blockHeight,
                      decoration: BoxDecoration(
                        color: getBlockColor(index),
                        borderRadius: BorderRadius.circular(4),
                        border: Border.all(
                          color: Colors.white.withOpacity(0.1),
                          width: 0.5,
                        ),
                        boxShadow: [
                          BoxShadow(
                            color: Colors.black.withOpacity(0.3),
                            blurRadius: 4,
                            offset: const Offset(0, 2),
                          ),
                        ],
                      ),
                    ),
                  );
                }).toList(),

                // Moving block
                Positioned(
                  bottom: baseOffset + stackedBlocks.length * blockHeight,
                  left: blockX,
                  child: Container(
                    width: blockWidth,
                    height: blockHeight,
                    decoration: BoxDecoration(
                      color: movingBlockColor,
                      borderRadius: BorderRadius.circular(4),
                      border: Border.all(
                        color: Colors.white.withOpacity(0.2),
                        width: 1,
                      ),
                      boxShadow: [
                        BoxShadow(
                          color: movingBlockColor.withOpacity(0.3),
                          blurRadius: 8,
                          offset: const Offset(0, 4),
                        ),
                      ],
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
                      color: dialogBackgroundColor.withOpacity(0.8),
                      borderRadius: BorderRadius.circular(25),
                      border: Border.all(
                        color: accentColor.withOpacity(0.3),
                        width: 1,
                      ),
                      boxShadow: [
                        BoxShadow(
                          color: Colors.black.withOpacity(0.2),
                          blurRadius: 8,
                          offset: const Offset(0, 4),
                        ),
                      ],
                    ),
                    child: Row(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        Icon(
                          Icons.layers,
                          color: accentColor,
                          size: 20,
                        ),
                        const SizedBox(width: 8),
                        Text(
                          "${stackedBlocks.length - 1}",
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

                // Instructions
                Positioned(
                  bottom: 30,
                  left: 0,
                  right: 0,
                  child: Center(
                    child: Container(
                      padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 10),
                      decoration: BoxDecoration(
                        color: Colors.black.withOpacity(0.5),
                        borderRadius: BorderRadius.circular(20),
                        border: Border.all(
                          color: Colors.white.withOpacity(0.1),
                          width: 1,
                        ),
                      ),
                      child: Text(
                        "Tap to drop blocks",
                        style: TextStyle(
                          color: textColor.withOpacity(0.8),
                          fontSize: 16,
                          fontWeight: FontWeight.w500,
                        ),
                      ),
                    ),
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}

// Custom painter for background grid
class GridPainter extends CustomPainter {
  final Color color;

  GridPainter({required this.color});

  @override
  void paint(Canvas canvas, Size size) {
    final paint = Paint()
      ..color = color
      ..strokeWidth = 1;

    const spacing = 30.0;

    // Draw vertical lines
    for (double x = 0; x <= size.width; x += spacing) {
      canvas.drawLine(Offset(x, 0), Offset(x, size.height), paint);
    }

    // Draw horizontal lines
    for (double y = 0; y <= size.height; y += spacing) {
      canvas.drawLine(Offset(0, y), Offset(size.width, y), paint);
    }
  }

  @override
  bool shouldRepaint(CustomPainter oldDelegate) => false;
}




