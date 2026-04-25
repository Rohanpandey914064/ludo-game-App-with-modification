import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../logic/game_state.dart';
import '../models/pawn_model.dart';

class CellWidget extends StatelessWidget {
  final int index;
  final Color baseColor;
  final bool isSafe;

  const CellWidget({
    super.key,
    required this.index,
    this.baseColor = Colors.white,
    this.isSafe = false,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: BoxDecoration(
        color: baseColor.withOpacity(baseColor == Colors.white ? 0.05 : 0.8),
        border: Border.all(color: Colors.grey.withOpacity(0.2), width: 0.5),
      ),
      child: Stack(
        alignment: Alignment.center,
        children: [
          if (isSafe)
            Icon(Icons.shield, color: baseColor.withOpacity(0.4), size: 14),
          
          // Render pawns on this cell
          Consumer<GameState>(
            builder: (context, gameState, child) {
              List<PawnModel> pawnsOnCell = [];
              for (int i = 0; i < 4; i++) {
                for (var pawn in gameState.playersPawns[i]) {
                  if (pawn.status == PawnStatus.onPath && 
                      gameState.paths[i][pawn.currentPathIndex] == index) {
                    pawnsOnCell.add(pawn);
                  }
                }
              }

              if (pawnsOnCell.isEmpty) return const SizedBox.shrink();

              // If multiple pawns, stack them slightly offset or show a number
              return GestureDetector(
                onTap: () {
                  // Only allow moving if it's the current player's pawn
                  for (var pawn in pawnsOnCell) {
                      if (pawn.color == _getColorByTurn(gameState.currentTurn)) {
                          gameState.movePawn(pawn);
                          break;
                      }
                  }
                },
                child: AnimatedContainer(
                  duration: const Duration(milliseconds: 200),
                  width: 24,
                  height: 24,
                  decoration: BoxDecoration(
                    color: pawnsOnCell.first.color,
                    shape: BoxShape.circle,
                    boxShadow: [
                      BoxShadow(
                        color: pawnsOnCell.first.color.withOpacity(0.4),
                        blurRadius: 8,
                        spreadRadius: 1,
                        offset: const Offset(0, 2),
                      ),
                    ],
                    gradient: RadialGradient(
                      colors: [
                        Colors.white.withOpacity(0.4),
                        Colors.transparent,
                      ],
                      center: const Alignment(-0.3, -0.3),
                      radius: 0.5,
                    ),
                    border: Border.all(color: Colors.white, width: 2.5),
                  ),
                  child: pawnsOnCell.length > 1 
                    ? Center(
                        child: Text(
                          '${pawnsOnCell.length}', 
                          style: const TextStyle(
                            fontSize: 10, 
                            color: Colors.white, 
                            fontWeight: FontWeight.bold
                          )
                        )
                      )
                    : null,
                ),
              );
            },
          ),
        ],
      ),
    );
  }

  Color _getColorByTurn(int turn) {
    switch (turn) {
      case 0: return Colors.green.shade600;
      case 1: return Colors.orange.shade600;
      case 2: return Colors.blue.shade600;
      case 3: return Colors.red.shade600;
      default: return Colors.grey;
    }
  }
}
