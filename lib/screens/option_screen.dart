import 'package:flutter/material.dart';
import 'package:zabimaru/games/snake/snack_game.dart';
import '../games/alieninvasion/alien_invasion.dart';
import '../games/brickbreaker/brick_breaker_game.dart';
import '../games/flappyball/flappy_ball_game.dart';
import '../games/minesweeper/minesweeper_game.dart';
import '../games/rockpaperscissors/rock_paper_scissor.dart';
import '../games/simonsays/simon_says_game.dart';
import '../games/stacktower/stack_tower_game.dart';
import '../games/tapthedot/tap_dot_game.dart';
import '../games/ticTacToe/mode_selection.dart';

class OptionScreen extends StatefulWidget {
  const OptionScreen({super.key});

  @override
  State<OptionScreen> createState() => _OptionScreenState();
}

class _OptionScreenState extends State<OptionScreen>
    with TickerProviderStateMixin {
  String? expandedTitle;
  late AnimationController _staggerController;
  late List<Animation<double>> _cardAnimations;

  @override
  void initState() {
    super.initState();
    _staggerController = AnimationController(
      duration: const Duration(milliseconds: 1500),
      vsync: this,
    );

    _cardAnimations = List.generate(
      games.length,
          (index) => Tween<double>(
        begin: 0.0,
        end: 1.0,
      ).animate(
        CurvedAnimation(
          parent: _staggerController,
          curve: Interval(
            index * 0.1,
            1.0,
            curve: Curves.easeOutBack,
          ),
        ),
      ),
    );

    _staggerController.forward();
  }

  @override
  void dispose() {
    _staggerController.dispose();
    super.dispose();
  }

  void toggleExpansion(String title) {
    setState(() {
      expandedTitle = expandedTitle == title ? null : title;
    });
  }

  final List<GameData> games = [
    GameData(
      title: 'Snake Game',
      color: const Color(0xFF00C851),
      icon: Icons.all_inclusive,
      description: 'Classic snake game. Eat food and survive!',
      gameWidget: const SnakeGame(),
    ),
    GameData(
      title: 'Tic Tac Toe',
      color: const Color(0xFF2196F3),
      icon: Icons.grid_on,
      description: 'Play Tic Tac Toe — vs friend or AI!',
      gameWidget: const TicTacToeModeSelection(),
    ),
    GameData(
      title: 'Tap The Dot',
      color: const Color(0xFFFF4444),
      icon: Icons.touch_app,
      description: 'Tap the dot before it disappears!',
      gameWidget: const TapDotGame(),
    ),
    GameData(
      title: 'Flappy Ball',
      color: const Color(0xFFFF9800),
      icon: Icons.sports_baseball,
      description: 'Tap to flap through pillars. Simple but tricky!',
      gameWidget: const FlappyBallGame(),
    ),
    GameData(
      title: 'Minesweeper',
      color: const Color(0xFFE91E63),
      icon: Icons.dangerous,
      description: 'Avoid bombs, clear the field!',
      gameWidget: const MinesweeperGame(),
    ),
    GameData(
      title: 'Rock Paper Scissors',
      color: const Color(0xFF9C27B0),
      icon: Icons.back_hand,
      description: 'Choose wisely against the AI!',
      gameWidget: const RockPaperScissorsGame(),
    ),
    GameData(
      title: 'Brick Breaker',
      color: const Color(0xFF673AB7),
      icon: Icons.sports_tennis,
      description: 'Bounce the ball & break all the bricks!',
      gameWidget: const BrickBreakerGame(),
    ),
    GameData(
      title: 'Stack Tower',
      color: const Color(0xFFE91E63),
      icon: Icons.layers,
      description: 'Stack the blocks as high as you can!',
      gameWidget: const StackTowerGame(),
    ),
    GameData(
      title: 'Simon Says',
      color: const Color(0xFF5E35B1),
      icon: Icons.memory,
      description: 'Repeat the color pattern without goofing up!',
      gameWidget: const SimonSaysGame(),
    ),
    GameData(
      title: 'Alien Invasion',
      color: const Color(0xFF3F51B5),
      icon: Icons.rocket_launch,
      description: 'Shoot bugs before they reach Earth!',
      gameWidget: const AlienInvasionGame(),
    ),
  ];

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Container(
        decoration: const BoxDecoration(
          gradient: LinearGradient(
            begin: Alignment.topCenter,
            end: Alignment.bottomCenter,
            colors: [
              Color(0xFF0D0D0D),
              Color(0xFF1A1A2E),
              Color(0xFF16213E),
              Color(0xFF0F0F23),
            ],
            stops: [0.0, 0.3, 0.7, 1.0],
          ),
        ),
        child: SafeArea(
          child: Column(
            children: [
              // Custom App Bar
              Container(
                padding: const EdgeInsets.all(20),
                child: Row(
                  children: [
                    Container(
                      decoration: BoxDecoration(
                        color: Colors.white.withOpacity(0.1),
                        borderRadius: BorderRadius.circular(12),
                      ),
                      child: IconButton(
                        icon: const Icon(Icons.arrow_back, color: Colors.white),
                        onPressed: () => Navigator.pop(context),
                      ),
                    ),
                    const SizedBox(width: 16),
                    const Expanded(
                      child: Text(
                        'Choose Your Game',
                        style: TextStyle(
                          color: Colors.white,
                          fontSize: 24,
                          fontWeight: FontWeight.bold,
                          letterSpacing: 0.5,
                        ),
                      ),
                    ),
                    Container(
                      padding: const EdgeInsets.symmetric(
                        horizontal: 12,
                        vertical: 6,
                      ),
                      decoration: BoxDecoration(
                        color: Colors.green.withOpacity(0.2),
                        borderRadius: BorderRadius.circular(16),
                        border: Border.all(
                          color: Colors.green.withOpacity(0.5),
                          width: 1,
                        ),
                      ),
                      child: Text(
                        '${games.length} Games',
                        style: const TextStyle(
                          color: Colors.green,
                          fontSize: 12,
                          fontWeight: FontWeight.w600,
                        ),
                      ),
                    ),
                  ],
                ),
              ),

              // Games List
              Expanded(
                child: ListView.builder(
                  padding: const EdgeInsets.symmetric(horizontal: 20),
                  itemCount: games.length + 1,
                  itemBuilder: (context, index) {
                    if (index == games.length) {
                      return _buildComingSoonCard();
                    }

                    final game = games[index];
                    final isExpanded = expandedTitle == game.title;

                    return AnimatedBuilder(
                      animation: _cardAnimations[index],
                      builder: (context, child) {
                        return Transform.translate(
                          offset: Offset(
                            0,
                            50 * (1 - _cardAnimations[index].value),
                          ),
                          child: Opacity(
                            opacity: _cardAnimations[index].value.clamp(0.0, 1.0),
                            child: _buildGameCard(game, isExpanded),
                          ),
                        );
                      },
                    );
                  },
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildGameCard(GameData game, bool isExpanded) {
    return Container(
      margin: const EdgeInsets.only(bottom: 16),
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(20),
        gradient: LinearGradient(
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
          colors: [
            game.color.withOpacity(0.1),
            game.color.withOpacity(0.05),
          ],
        ),
        border: Border.all(
          color: game.color.withOpacity(0.3),
          width: 1,
        ),
        boxShadow: [
          BoxShadow(
            color: game.color.withOpacity(0.1),
            blurRadius: 10,
            spreadRadius: 1,
          ),
        ],
      ),
      child: ClipRRect(
        borderRadius: BorderRadius.circular(20),
        child: Column(
          children: [
            // Game Header
            InkWell(
              onTap: () => toggleExpansion(game.title),
              child: Container(
                padding: const EdgeInsets.all(20),
                decoration: BoxDecoration(
                  color: Colors.white.withOpacity(0.02),
                ),
                child: Row(
                  children: [
                    Container(
                      width: 50,
                      height: 50,
                      decoration: BoxDecoration(
                        color: game.color.withOpacity(0.2),
                        borderRadius: BorderRadius.circular(12),
                      ),
                      child: Icon(
                        game.icon,
                        color: game.color,
                        size: 28,
                      ),
                    ),
                    const SizedBox(width: 16),
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            game.title,
                            style: const TextStyle(
                              color: Colors.white,
                              fontSize: 18,
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                          const SizedBox(height: 4),
                          Text(
                            game.description,
                            style: TextStyle(
                              color: Colors.white.withOpacity(0.7),
                              fontSize: 14,
                            ),
                            maxLines: 1,
                            overflow: TextOverflow.ellipsis,
                          ),
                        ],
                      ),
                    ),
                    AnimatedRotation(
                      turns: isExpanded ? 0.5 : 0,
                      duration: const Duration(milliseconds: 300),
                      child: Icon(
                        Icons.keyboard_arrow_down,
                        color: Colors.white.withOpacity(0.7),
                        size: 24,
                      ),
                    ),
                  ],
                ),
              ),
            ),

            // Expanded Content
            AnimatedContainer(
              duration: const Duration(milliseconds: 300),
              height: isExpanded ? null : 0,
              child: isExpanded
                  ? Container(
                padding: const EdgeInsets.all(20),
                decoration: BoxDecoration(
                  color: Colors.black.withOpacity(0.2),
                  border: Border(
                    top: BorderSide(
                      color: game.color.withOpacity(0.2),
                      width: 1,
                    ),
                  ),
                ),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      game.description,
                      style: TextStyle(
                        color: Colors.white.withOpacity(0.9),
                        fontSize: 16,
                        height: 1.4,
                      ),
                    ),
                    const SizedBox(height: 20),
                    Center(
                      child: Container(
                        decoration: BoxDecoration(
                          borderRadius: BorderRadius.circular(25),
                          gradient: LinearGradient(
                            colors: [
                              game.color,
                              game.color.withOpacity(0.8),
                            ],
                          ),
                          boxShadow: [
                            BoxShadow(
                              color: game.color.withOpacity(0.3),
                              blurRadius: 15,
                              spreadRadius: 2,
                            ),
                          ],
                        ),
                        child: ElevatedButton(
                          onPressed: () {
                            Navigator.push(
                              context,
                              PageRouteBuilder(
                                pageBuilder: (context, animation,
                                    secondaryAnimation) =>
                                game.gameWidget,
                                transitionsBuilder: (context, animation,
                                    secondaryAnimation, child) {
                                  return SlideTransition(
                                    position: animation.drive(
                                      Tween<Offset>(
                                        begin: const Offset(1.0, 0.0),
                                        end: Offset.zero,
                                      ),
                                    ),
                                    child: child,
                                  );
                                },
                                transitionDuration:
                                const Duration(milliseconds: 300),
                              ),
                            );
                          },
                          style: ElevatedButton.styleFrom(
                            backgroundColor: Colors.transparent,
                            shadowColor: Colors.transparent,
                            padding: const EdgeInsets.symmetric(
                              horizontal: 40,
                              vertical: 15,
                            ),
                            shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(25),
                            ),
                          ),
                          child: const Row(
                            mainAxisSize: MainAxisSize.min,
                            children: [
                              Icon(
                                Icons.play_arrow,
                                color: Colors.white,
                                size: 22,
                              ),
                              SizedBox(width: 8),
                              Text(
                                "PLAY NOW",
                                style: TextStyle(
                                  color: Colors.white,
                                  fontSize: 16,
                                  fontWeight: FontWeight.bold,
                                  letterSpacing: 0.5,
                                ),
                              ),
                            ],
                          ),
                        ),
                      ),
                    ),
                  ],
                ),
              )
                  : null,
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildComingSoonCard() {
    return Container(
      margin: const EdgeInsets.only(bottom: 20),
      padding: const EdgeInsets.all(24),
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(20),
        gradient: LinearGradient(
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
          colors: [
            Colors.purple.withOpacity(0.1),
            Colors.blue.withOpacity(0.1),
          ],
        ),
        border: Border.all(
          color: Colors.purple.withOpacity(0.3),
          width: 1,
        ),
        boxShadow: [
          BoxShadow(
            color: Colors.purple.withOpacity(0.1),
            blurRadius: 10,
            spreadRadius: 1,
          ),
        ],
      ),
      child: Row(
        children: [
          Container(
            width: 60,
            height: 60,
            decoration: BoxDecoration(
              gradient: LinearGradient(
                colors: [
                  Colors.purple.withOpacity(0.3),
                  Colors.blue.withOpacity(0.3),
                ],
              ),
              borderRadius: BorderRadius.circular(15),
            ),
            child: const Icon(
              Icons.games,
              color: Colors.white,
              size: 30,
            ),
          ),
          const SizedBox(width: 20),
          const Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  "More Games Coming Soon!",
                  style: TextStyle(
                    color: Colors.white,
                    fontSize: 18,
                    fontWeight: FontWeight.bold,
                  ),
                ),
                SizedBox(height: 8),
                Text(
                  "Stay tuned for exciting new adventures! 🚀",
                  style: TextStyle(
                    color: Colors.white70,
                    fontSize: 14,
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}

class GameData {
  final String title;
  final Color color;
  final IconData icon;
  final String description;
  final Widget gameWidget;

  GameData({
    required this.title,
    required this.color,
    required this.icon,
    required this.description,
    required this.gameWidget,
  });
}






