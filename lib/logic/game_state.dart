import 'dart:math';
import 'package:flutter/material.dart';
import '../models/pawn_model.dart';

class GameState extends ChangeNotifier {
  // Current player turn (0: Green, 1: Yellow, 2: Blue, 3: Red)
  int _currentTurn = 0;
  int get currentTurn => _currentTurn;

  int _diceValue = 1;
  int get diceValue => _diceValue;

  bool _isRolling = false;
  bool get isRolling => _isRolling;

  int? _cheatPlayerIndex;
  int? get cheatPlayerIndex => _cheatPlayerIndex;

  bool _canRoll = true;
  bool get canRoll => _canRoll;

  // 4 Players, each with 4 pawns
  final List<List<PawnModel>> playersPawns = [
    // Green (Top Left)
    List.generate(4, (i) => PawnModel(id: i, color: Colors.green)),
    // Yellow (Top Right)
    List.generate(4, (i) => PawnModel(id: i, color: Colors.yellow)),
    // Blue (Bottom Right)
    List.generate(4, (i) => PawnModel(id: i, color: Colors.blue)),
    // Red (Bottom Left)
    List.generate(4, (i) => PawnModel(id: i, color: Colors.red)),
  ];

  // Map of path indices for each player (52 shared + 5 home path + 1 finish)
  // These are 1D indices in a 15x15 grid (0-224)
  final List<List<int>> paths = [
    // Green Path
    [
      91, 92, 93, 94, 95, 81, 66, 51, 36, 21, 6, 7, 8, 23, 38, 53, 68, 83, 99, 100, 101, 102, 103, 104, 119, 134, 133, 132, 131, 130, 129, 143, 158, 173, 188, 203, 218, 217, 216, 201, 186, 171, 156, 141, 125, 124, 123, 122, 121, 120, 105, 106, 107, 108, 109, 110, 111, 112
    ],
    // Yellow Path
    [
       23, 38, 53, 68, 83, 99, 100, 101, 102, 103, 104, 119, 134, 133, 132, 131, 130, 129, 143, 158, 173, 188, 203, 218, 217, 216, 201, 186, 171, 156, 141, 125, 124, 123, 122, 121, 120, 105, 90, 91, 92, 93, 94, 95, 81, 66, 51, 36, 21, 6, 7, 22, 37, 52, 67, 82, 97, 112
    ],
    // Blue Path (simplified for now, will refine)
    [
      133, 132, 131, 130, 129, 143, 158, 173, 188, 203, 218, 217, 216, 201, 186, 171, 156, 141, 125, 124, 123, 122, 121, 120, 105, 90, 91, 92, 93, 94, 95, 81, 66, 51, 36, 21, 6, 7, 8, 23, 38, 53, 68, 83, 99, 100, 101, 102, 103, 104, 119, 118, 117, 116, 115, 114, 113, 112
    ],
    // Red Path
    [
      201, 186, 171, 156, 141, 125, 124, 123, 122, 121, 120, 105, 90, 91, 92, 93, 94, 95, 81, 66, 51, 36, 21, 6, 7, 8, 23, 38, 53, 68, 83, 99, 100, 101, 102, 103, 104, 119, 134, 133, 132, 131, 130, 129, 143, 158, 173, 188, 203, 218, 217, 202, 187, 172, 157, 142, 127, 112
    ],
  ];

  Future<void> rollDice() async {
    if (!_canRoll) return;
    
    _isRolling = true;
    _canRoll = false;
    notifyListeners();

    // Simulate dice animation
    await Future.delayed(const Duration(milliseconds: 500));
    
    // Chitt Mode Logic: 40% chance of getting a 6 if cheat is active for current player
    if (_cheatPlayerIndex == _currentTurn && Random().nextDouble() < 0.4) {
      _diceValue = 6;
    } else {
      _diceValue = Random().nextInt(6) + 1;
    }
    
    _isRolling = false;

    // Check if player can move any pawn
    bool checkCanMove = false;
    for (var pawn in playersPawns[_currentTurn]) {
      if (pawn.canMove(_diceValue)) {
        checkCanMove = true;
        break;
      }
    }

    if (!checkCanMove) {
      // Small delay before switching turn if no moves possible
      await Future.delayed(const Duration(seconds: 1));
      _nextTurn();
    }
    
    notifyListeners();
  }

  void movePawn(PawnModel pawn) {
    if (_canRoll) return; // Must roll first
    if (pawn.color != _getColorByIndex(_currentTurn)) return; // Not your turn
    if (!pawn.canMove(_diceValue)) return;

    if (pawn.status == PawnStatus.base) {
      if (_diceValue == 6) {
        pawn.status = PawnStatus.onPath;
        pawn.currentPathIndex = 0;
      }
    } else {
      pawn.currentPathIndex += _diceValue;
      if (pawn.currentPathIndex == 57) {
        pawn.status = PawnStatus.reachedHome;
      }
    }

    // Check for kills (if on shared path)
    _checkKill(pawn);

    // If dice was 6, roll again, otherwise next turn
    if (_diceValue == 6) {
      _canRoll = true;
    } else {
      _nextTurn();
    }
    
    notifyListeners();
  }

  void _checkKill(PawnModel movedPawn) {
    // Only kill on shared path (indices 0-50 for Green, etc.)
    // For simplicity, we'll check grid index equality
    int gridIndex = paths[_currentTurn][movedPawn.currentPathIndex];
    
    // Don't kill in safe zones (start spots)
    List<int> safeSpots = [91, 23, 133, 201];
    if (safeSpots.contains(gridIndex)) return;

    for (int i = 0; i < 4; i++) {
        if (i == _currentTurn) continue;
        for (var otherPawn in playersPawns[i]) {
            if (otherPawn.status == PawnStatus.onPath) {
                int otherGridIndex = paths[i][otherPawn.currentPathIndex];
                if (gridIndex == otherGridIndex) {
                    otherPawn.status = PawnStatus.base;
                    otherPawn.currentPathIndex = -1;
                    _canRoll = true; // Bonus roll for kill
                }
            }
        }
    }
  }

  void _nextTurn() {
    _currentTurn = (_currentTurn + 1) % 4;
    _canRoll = true;
  }

  Color _getColorByIndex(int index) {
    switch (index) {
      case 0: return Colors.green;
      case 1: return Colors.yellow;
      case 2: return Colors.blue;
      case 3: return Colors.red;
      default: return Colors.grey;
    }
  }

  void toggleCheatMode(int index) {
    if (_cheatPlayerIndex == index) {
      _cheatPlayerIndex = null;
    } else {
      _cheatPlayerIndex = index;
    }
    notifyListeners();
  }
}
