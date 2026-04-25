import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'cell_widget.dart';
import '../logic/game_state.dart';
import '../models/pawn_model.dart';

class BoardWidget extends StatelessWidget {
  const BoardWidget({super.key});

  @override
  Widget build(BuildContext context) {
    return AspectRatio(
      aspectRatio: 1.0,
      child: Container(
        padding: const EdgeInsets.all(8.0),
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(16),
          boxShadow: [
            BoxShadow(
              color: Colors.indigo.withOpacity(0.15),
              blurRadius: 30,
              offset: const Offset(0, 12),
            ),
          ],
          border: Border.all(color: Colors.indigo.withOpacity(0.08), width: 1.5),
        ),
        child: GridView.builder(
          physics: const NeverScrollableScrollPhysics(),
          gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
            crossAxisCount: 15,
          ),
          itemCount: 225,
          itemBuilder: (context, index) {
            int row = index ~/ 15;
            int col = index % 15;

            // Define Home Bases (6x6)
            if ((row < 6 && col < 6) || (row < 6 && col > 8) || (row > 8 && col < 6) || (row > 8 && col > 8)) {
                return _buildBaseCell(row, col, context);
            }

            // Define Finish Center (3x3)
            if (row >= 6 && row <= 8 && col >= 6 && col <= 8) {
              return _buildCenter(row, col);
            }

            // Path cells (Default case: cross-shaped paths)
            Color cellColor = Colors.white;
            bool isSafe = false;

            // Safe spots (Standard Ludo: 2 per arm)
            // Green: (6,1) Start, (8,2) Safe
            // Yellow: (1,8) Start, (2,6) Safe
            // Blue: (8,13) Start, (6,12) Safe
            // Red: (13,6) Start, (12,8) Safe
            List<int> safeSpots = [91, 122, 23, 36, 133, 102, 201, 188];
            
            if (safeSpots.contains(index)) {
              isSafe = true;
              if (index == 91) cellColor = Colors.green.shade600;
              if (index == 23) cellColor = Colors.orange.shade600;
              if (index == 133) cellColor = Colors.blue.shade600;
              if (index == 201) cellColor = Colors.red.shade600;
            }

            // Define Home Paths for perfect 6-cell arms
            if (row == 7) {
              if (col >= 1 && col <= 6) cellColor = Colors.green.shade600; // Green Home
              if (col >= 8 && col <= 13) cellColor = Colors.blue.shade600; // Blue Home
            }
            if (col == 7) {
              if (row >= 1 && row <= 6) cellColor = Colors.orange.shade600; // Yellow Home
              if (row >= 8 && row <= 13) cellColor = Colors.red.shade600; // Red Home
            }

            return CellWidget(index: index, baseColor: cellColor, isSafe: isSafe);
          },
        ),
      ),
    );
  }

  Widget _buildBaseCell(int row, int col, BuildContext context) {
    Color baseColor = Colors.white;
    int playerIndex = -1;

    if (row < 6 && col < 6) { baseColor = Colors.green.shade600; playerIndex = 0; }
    else if (row < 6 && col > 8) { baseColor = Colors.orange.shade600; playerIndex = 1; }
    else if (row > 8 && col < 6) { baseColor = Colors.red.shade600; playerIndex = 3; }
    else if (row > 8 && col > 8) { baseColor = Colors.blue.shade600; playerIndex = 2; }

    // Define 4 pawn slots for each player
    List<Map<String, int>> slots = [];
    if (playerIndex == 0) slots = [{"r": 2, "c": 2}, {"r": 2, "c": 3}, {"r": 3, "c": 2}, {"r": 3, "c": 3}];
    if (playerIndex == 1) slots = [{"r": 2, "c": 11}, {"r": 2, "c": 12}, {"r": 3, "c": 11}, {"r": 3, "c": 12}];
    if (playerIndex == 2) slots = [{"r": 11, "c": 11}, {"r": 11, "c": 12}, {"r": 12, "c": 11}, {"r": 12, "c": 12}];
    if (playerIndex == 3) slots = [{"r": 11, "c": 2}, {"r": 11, "c": 3}, {"r": 12, "c": 2}, {"r": 12, "c": 3}];

    int slotIdx = -1;
    for (int i = 0; i < slots.length; i++) {
        if (slots[i]["r"] == row && slots[i]["c"] == col) {
            slotIdx = i;
            break;
        }
    }

    return Container(
      decoration: BoxDecoration(
        color: baseColor.withValues(alpha: slotIdx != -1 ? 0.3 : 0.1),
        border: Border.all(color: Colors.grey.shade200, width: 0.5),
      ),
      child: slotIdx != -1 ? Consumer<GameState>(
        builder: (context, gameState, child) {
          var pawn = gameState.playersPawns[playerIndex][slotIdx];
          if (pawn.status != PawnStatus.base) return const SizedBox.shrink();

          return Center(
            child: GestureDetector(
                onTap: () => gameState.movePawn(pawn),
                child: Container(
                  width: 20,
                  height: 20,
                  decoration: BoxDecoration(
                    color: baseColor,
                    shape: BoxShape.circle,
                    boxShadow: [
                      BoxShadow(
                        color: Colors.black.withValues(alpha: 0.3),
                        blurRadius: 4,
                        offset: const Offset(1, 1),
                      ),
                    ],
                    border: Border.all(color: Colors.white, width: 2),
                  ),
                ),
            ),
          );
        },
      ) : null,
    );
  }

  Widget _buildCenter(int row, int col) {
    return CustomPaint(
      size: Size.infinite,
      painter: _CenterPainter(row: row, col: col),
    );
  }
}

class _CenterPainter extends CustomPainter {
  final int row;
  final int col;
  _CenterPainter({required this.row, required this.col});

  @override
  void paint(Canvas canvas, Size size) {
    final paint = Paint()..style = PaintingStyle.fill;
    
    // Relative coordinates in the 3x3 center
    int r = row - 6;
    int c = col - 6;

    // We want 4 large triangles meeting at the center point of the 3x3 area
    // This is simplified by drawing specifically for each cell
    
    if (r == 0) { // Top row of center 3x3
      if (c == 0) {
        paint.color = Colors.green.shade600;
        var path = Path()..moveTo(0, 0)..lineTo(size.width, 0)..lineTo(size.width, size.height)..close();
        canvas.drawPath(path, paint);
        paint.color = Colors.orange.shade600;
        path = Path()..moveTo(0, 0)..lineTo(size.width, 0)..lineTo(0, size.height)..close();
        canvas.drawPath(path, paint);
      } else if (c == 1) {
        paint.color = Colors.orange.shade600;
        canvas.drawRect(Rect.fromLTWH(0, 0, size.width, size.height), paint);
      } else if (c == 2) {
        paint.color = Colors.orange.shade600;
        var path = Path()..moveTo(0, 0)..lineTo(size.width, 0)..lineTo(size.width, size.height)..close();
        canvas.drawPath(path, paint);
        paint.color = Colors.blue.shade600;
        path = Path()..moveTo(size.width, 0)..lineTo(0, 0)..lineTo(size.width, size.height)..close();
        canvas.drawPath(path, paint);
      }
    } else if (r == 1) { // Middle row
      if (c == 0) {
        paint.color = Colors.green.shade600;
        canvas.drawRect(Rect.fromLTWH(0, 0, size.width, size.height), paint);
      } else if (c == 1) {
        // Center cell: 4 triangles meeting
        paint.color = Colors.orange.shade600;
        canvas.drawPath(Path()..moveTo(0, 0)..lineTo(size.width, 0)..lineTo(size.width/2, size.height/2)..close(), paint);
        paint.color = Colors.blue.shade600;
        canvas.drawPath(Path()..moveTo(size.width, 0)..lineTo(size.width, size.height)..lineTo(size.width/2, size.height/2)..close(), paint);
        paint.color = Colors.red.shade600;
        canvas.drawPath(Path()..moveTo(size.width, size.height)..lineTo(0, size.height)..lineTo(size.width/2, size.height/2)..close(), paint);
        paint.color = Colors.green.shade600;
        canvas.drawPath(Path()..moveTo(0, size.height)..lineTo(0, 0)..lineTo(size.width/2, size.height/2)..close(), paint);
      } else if (c == 2) {
        paint.color = Colors.blue.shade600;
        canvas.drawRect(Rect.fromLTWH(0, 0, size.width, size.height), paint);
      }
    } else if (r == 2) { // Bottom row
      if (c == 0) {
        paint.color = Colors.green.shade600;
        var path = Path()..moveTo(0, 0)..lineTo(0, size.height)..lineTo(size.width, size.height)..close();
        canvas.drawPath(path, paint);
        paint.color = Colors.red.shade600;
        path = Path()..moveTo(0, size.height)..lineTo(size.width, size.height)..lineTo(size.width, 0)..close();
        canvas.drawPath(path, paint);
      } else if (c == 1) {
        paint.color = Colors.red.shade600;
        canvas.drawRect(Rect.fromLTWH(0, 0, size.width, size.height), paint);
      } else if (c == 2) {
        paint.color = Colors.blue.shade600;
        var path = Path()..moveTo(size.width, 0)..lineTo(size.width, size.height)..lineTo(0, size.height)..close();
        canvas.drawPath(path, paint);
        paint.color = Colors.red.shade600;
        path = Path()..moveTo(size.width, size.height)..lineTo(0, size.height)..lineTo(0, 0)..close();
        canvas.drawPath(path, paint);
      }
    }
  }

  @override
  bool shouldRepaint(covariant CustomPainter oldDelegate) => false;
}

