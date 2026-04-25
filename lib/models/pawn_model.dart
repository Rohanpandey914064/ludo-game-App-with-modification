import 'package:flutter/material.dart';

enum PawnStatus {
  base,      // In the home base
  onPath,    // On the circular path
  reachedHome // Reached the center
}

class PawnModel {
  final int id;
  final Color color;
  int currentPathIndex; // -1 if in base, 0-51 on path, 52-56 on home path
  PawnStatus status;

  PawnModel({
    required this.id,
    required this.color,
    this.currentPathIndex = -1,
    this.status = PawnStatus.base,
  });

  // Helper to check if pawn can move
  bool canMove(int diceValue) {
    if (status == PawnStatus.reachedHome) return false;
    if (status == PawnStatus.base) return diceValue == 6;
    if (currentPathIndex + diceValue > 56) return false; // Must land exactly on 57
    return true;
  }
}
