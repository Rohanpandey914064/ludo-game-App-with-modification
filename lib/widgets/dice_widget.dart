import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../logic/game_state.dart';

class DiceWidget extends StatefulWidget {
  const DiceWidget({super.key});

  @override
  State<DiceWidget> createState() => _DiceWidgetState();
}

class _DiceWidgetState extends State<DiceWidget> with SingleTickerProviderStateMixin {
  late AnimationController _controller;
  late Animation<double> _animation;

  @override
  void initState() {
    super.initState();
    _controller = AnimationController(
      duration: const Duration(milliseconds: 500),
      vsync: this,
    );
    _animation = CurvedAnimation(parent: _controller, curve: Curves.elasticOut);
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Consumer<GameState>(
      builder: (context, gameState, child) {
        if (gameState.isRolling && !_controller.isAnimating) {
          _controller.forward(from: 0.0);
        }

        return GestureDetector(
          onTap: gameState.canRoll ? () => gameState.rollDice() : null,
          child: Column(
            children: [
              ScaleTransition(
                scale: _animation,
                child: RotationTransition(
                  turns: _animation,
                  child: Container(
                    width: 70,
                    height: 70,
                    decoration: BoxDecoration(
                      color: Colors.white,
                      borderRadius: BorderRadius.circular(15),
                      boxShadow: [
                        BoxShadow(
                          color: _getTurnColor(gameState.currentTurn).withOpacity(0.3),
                          blurRadius: 20,
                          spreadRadius: 2,
                          offset: const Offset(0, 8),
                        ),
                      ],
                      gradient: LinearGradient(
                        colors: [Colors.white, Colors.grey.shade100],
                        begin: Alignment.topLeft,
                        end: Alignment.bottomRight,
                      ),
                      border: Border.all(
                        color: _getTurnColor(gameState.currentTurn).withOpacity(0.5),
                        width: 3,
                      ),
                    ),
                    child: Center(
                      child: gameState.isRolling 
                        ? CircularProgressIndicator(
                            strokeWidth: 3,
                            valueColor: AlwaysStoppedAnimation<Color>(_getTurnColor(gameState.currentTurn)),
                          ) 
                        : _buildDiceFace(gameState.diceValue, _getTurnColor(gameState.currentTurn)),
                    ),
                  ),
                ),
              ),
              const SizedBox(height: 12),
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 6),
                decoration: BoxDecoration(
                  color: _getTurnColor(gameState.currentTurn).withOpacity(0.1),
                  borderRadius: BorderRadius.circular(20),
                ),
                child: Text(
                  gameState.canRoll ? "Roll Now" : "Move Pawn",
                  style: TextStyle(
                    fontWeight: FontWeight.w900,
                    fontSize: 12,
                    letterSpacing: 0.5,
                    color: _getTurnColor(gameState.currentTurn),
                  ),
                ),
              ),
            ],
          ),
        );
      },
    );
  }

  Widget _buildDiceFace(int value, Color color) {
    return Container(
      padding: const EdgeInsets.all(8),
      child: Column(
        mainAxisAlignment: MainAxisAlignment.spaceEvenly,
        children: [
          if (value == 1) _buildRow([false, false, false], [false, true, false], [false, false, false], color),
          if (value == 2) _buildRow([true, false, false], [false, false, false], [false, false, true], color),
          if (value == 3) _buildRow([true, false, false], [false, true, false], [false, false, true], color),
          if (value == 4) _buildRow([true, false, true], [false, false, false], [true, false, true], color),
          if (value == 5) _buildRow([true, false, true], [false, true, false], [true, false, true], color),
          if (value == 6) _buildRow([true, false, true], [true, false, true], [true, false, true], color),
        ],
      ),
    );
  }

  Widget _buildRow(List<bool> top, List<bool> mid, List<bool> bot, Color color) {
    return Column(
      children: [
        Row(mainAxisAlignment: MainAxisAlignment.spaceEvenly, children: top.map((e) => _buildDot(e, color)).toList()),
        const SizedBox(height: 4),
        Row(mainAxisAlignment: MainAxisAlignment.spaceEvenly, children: mid.map((e) => _buildDot(e, color)).toList()),
        const SizedBox(height: 4),
        Row(mainAxisAlignment: MainAxisAlignment.spaceEvenly, children: bot.map((e) => _buildDot(e, color)).toList()),
      ],
    );
  }

  Widget _buildDot(bool visible, Color color) {
    return Container(
      width: 8,
      height: 8,
      decoration: BoxDecoration(
        color: visible ? color : Colors.transparent,
        shape: BoxShape.circle,
        boxShadow: visible ? [
          BoxShadow(color: color.withOpacity(0.4), blurRadius: 2, spreadRadius: 1)
        ] : [],
      ),
    );
  }

  Color _getTurnColor(int turn) {
    switch (turn) {
      case 0: return Colors.green.shade700;
      case 1: return Colors.orange;
      case 2: return Colors.blue.shade700;
      case 3: return Colors.red.shade700;
      default: return Colors.grey;
    }
  }
}
