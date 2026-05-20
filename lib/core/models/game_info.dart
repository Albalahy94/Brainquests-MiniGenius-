import 'package:flutter/material.dart';

class GameInfo {
  final String id;
  final String name;
  final String description;
  final IconData icon;
  final Color color;
  final String route;

  const GameInfo({
    required this.id,
    required this.name,
    required this.description,
    required this.icon,
    required this.color,
    required this.route,
  });
}

class GameDefinitions {
  static const List<GameInfo> allGames = [
    GameInfo(
      id: 'memory_cards',
      name: 'Memory Cards',
      description: 'Match pairs of cards',
      icon: Icons.credit_card,
      color: Color(0xFF4DB7FF),
      route: '/memory-cards',
    ),
    GameInfo(
      id: 'find_difference',
      name: 'Find the Difference',
      description: 'Spot the differences',
      icon: Icons.find_in_page,
      color: Color(0xFFFFE45C),
      route: '/find-difference',
    ),
    GameInfo(
      id: 'shape_matcher',
      name: 'Shape Matcher',
      description: 'Drag the correct shape',
      icon: Icons.shape_line,
      color: Color(0xFF5ADBB5),
      route: '/shape-matcher',
    ),
    GameInfo(
      id: 'pattern_logic',
      name: 'Pattern Logic',
      description: 'Complete the sequence',
      icon: Icons.pattern,
      color: Color(0xFF4DB7FF),
      route: '/pattern-logic',
    ),
    GameInfo(
      id: 'quick_math',
      name: 'Quick Math',
      description: 'Simple addition/subtraction',
      icon: Icons.calculate,
      color: Color(0xFFFFE45C),
      route: '/quick-math',
    ),
    GameInfo(
      id: 'color_memory',
      name: 'Color Memory',
      description: 'Repeat the color order',
      icon: Icons.palette,
      color: Color(0xFF5ADBB5),
      route: '/color-memory',
    ),
    GameInfo(
      id: 'word_puzzle',
      name: 'Word Puzzle',
      description: 'Build words from letters',
      icon: Icons.text_fields,
      color: Color(0xFF9B59B6),
      route: '/word-puzzle',
    ),
    GameInfo(
      id: 'maze_runner',
      name: 'Maze Runner',
      description: 'Find the correct path',
      icon: Icons.explore,
      color: Color(0xFFE67E22),
      route: '/maze-runner',
    ),
    GameInfo(
      id: 'sorting_game',
      name: 'Sorting Game',
      description: 'Sort items by category',
      icon: Icons.sort,
      color: Color(0xFF1ABC9C),
      route: '/sorting-game',
    ),
    GameInfo(
      id: 'jigsaw_puzzle',
      name: 'Jigsaw Puzzle',
      description: 'Complete the picture',
      icon: Icons.extension,
      color: Color(0xFFE74C3C),
      route: '/jigsaw-puzzle',
    ),
  ];
}

