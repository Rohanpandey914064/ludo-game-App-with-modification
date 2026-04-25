import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'logic/game_state.dart';
import 'widgets/board_widget.dart';
import 'widgets/dice_widget.dart';

void main() {
  runApp(
    ChangeNotifierProvider(
      create: (_) => GameState(),
      child: const LudoApp(),
    ),
  );
}

class LudoApp extends StatelessWidget {
  const LudoApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      debugShowCheckedModeBanner: false,
      title: 'Ludo Pro',
      theme: ThemeData(
        useMaterial3: true,
        primarySwatch: Colors.indigo,
        scaffoldBackgroundColor: const Color(0xFFF0F2F5),
        colorScheme: ColorScheme.fromSeed(
          seedColor: Colors.indigo,
          primary: Colors.indigo,
          secondary: Colors.amber,
        ),
      ),
      home: const LudoPage(),
    );
  }
}

class LudoPage extends StatelessWidget {
  const LudoPage({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Ludo Premium', 
          style: TextStyle(fontWeight: FontWeight.w900, letterSpacing: 1.2)),
        centerTitle: true,
        backgroundColor: Colors.transparent,
        elevation: 0,
        flexibleSpace: Container(
          decoration: const BoxDecoration(
            gradient: LinearGradient(
              colors: [Colors.indigo, Colors.blueAccent],
              begin: Alignment.topLeft,
              end: Alignment.bottomRight,
            ),
          ),
        ),
        foregroundColor: Colors.white,
      ),
      extendBodyBehindAppBar: true,
      body: Consumer<GameState>(
        builder: (context, gameState, child) {
          return Container(
            width: double.infinity,
            height: MediaQuery.of(context).size.height,
            decoration: BoxDecoration(
              gradient: LinearGradient(
                colors: [Colors.indigo.shade50, Colors.white],
                begin: Alignment.topCenter,
                end: Alignment.bottomCenter,
              ),
            ),
            child: SingleChildScrollView(
              padding: const EdgeInsets.only(top: 100),
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Container(
                    margin: const EdgeInsets.symmetric(horizontal: 16.0),
                    decoration: BoxDecoration(
                      boxShadow: [
                        BoxShadow(
                          color: Colors.black.withOpacity(0.1),
                          blurRadius: 30,
                          spreadRadius: 5,
                        )
                      ],
                    ),
                    child: const BoardWidget(),
                  ),
                  const SizedBox(height: 40),
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                    children: [
                      _buildPlayerInfo(0, "Green", Colors.green, gameState, context),
                      _buildPlayerInfo(1, "Yellow", Colors.orange, gameState, context),
                      const DiceWidget(),
                      _buildPlayerInfo(2, "Blue", Colors.blue, gameState, context),
                      _buildPlayerInfo(3, "Red", Colors.red, gameState, context),
                    ],
                  ),
                  const SizedBox(height: 32),
                ],
              ),
            ),
          );
        },
      ),
    );
  }

  Widget _buildPlayerInfo(int index, String name, Color color, GameState gameState, BuildContext context) {
    bool isCurrentTurn = gameState.currentTurn == index;
    bool isCheatActive = gameState.cheatPlayerIndex == index;

    return GestureDetector(
      onLongPress: () {
        gameState.toggleCheatMode(index);
      },
      child: Column(
        children: [
          AnimatedContainer(
            duration: const Duration(milliseconds: 300),
            padding: const EdgeInsets.all(6),
            decoration: BoxDecoration(
              shape: BoxShape.circle,
              border: isCurrentTurn 
                ? Border.all(color: color, width: 4) 
                : Border.all(color: Colors.transparent, width: 4),
              boxShadow: isCurrentTurn ? [
                BoxShadow(
                  color: color.withOpacity(0.5),
                  blurRadius: 15,
                  spreadRadius: 3,
                )
              ] : [],
            ),
            child: Stack(
              alignment: Alignment.center,
              children: [
                CircleAvatar(
                  backgroundColor: color,
                  radius: 18,
                  child: isCheatActive 
                    ? const Icon(Icons.star, color: Colors.white, size: 16)
                    : null,
                ),
              ],
            ),
          ),
          const SizedBox(height: 8),
          Text(name, style: TextStyle(
            fontSize: 12,
            fontWeight: isCurrentTurn ? FontWeight.bold : FontWeight.w500,
            color: isCurrentTurn ? color : Colors.grey.shade600,
          )),
        ],
      ),
    );
  }
}
