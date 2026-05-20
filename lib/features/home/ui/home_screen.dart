import 'package:flutter/material.dart';
import 'package:flutter_animate/flutter_animate.dart';
import 'package:minigenius/generated/l10n/app_localizations.dart';
import 'package:provider/provider.dart';
import 'package:minigenius/core/theme/app_theme.dart';
import 'package:minigenius/core/models/game_info.dart';
import 'package:minigenius/core/routes/app_routes.dart';
import 'package:minigenius/core/services/parent_dashboard_service.dart';
import 'package:minigenius/core/providers/app_state_provider.dart';
import '../../../core/widgets/glassmorphic_container.dart';
import '../widgets/game_card.dart';
import '../widgets/bottom_navigation.dart';
import '../widgets/animated_background.dart';

class HomeScreen extends StatefulWidget {
  const HomeScreen({super.key});

  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  int _selectedIndex = 0;
  final ParentDashboardService _parentService = ParentDashboardService();

  void _onItemTapped(int index) {
    setState(() {
      _selectedIndex = index;
    });

    switch (index) {
      case 1:
        Navigator.pushNamed(context, AppRoutes.stickers);
        break;
      case 2:
        Navigator.pushNamed(context, AppRoutes.achievements);
        break;
      case 3:
        Navigator.pushNamed(context, AppRoutes.settings);
        break;
    }
  }

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context)!;
    final theme = Theme.of(context);
    final appState = context.watch<AppStateProvider>();
    final isDark = appState.isDarkMode;

    return Scaffold(
      extendBodyBehindAppBar: true,
      body: Stack(
        children: [
          // Dynamic Animated Background
          Positioned.fill(
            child: AnimatedBackground(isDarkMode: isDark),
          ),
          
          SafeArea(
            child: Column(
              children: [
                // Logo/Header
                Padding(
                  padding: const EdgeInsets.all(24.0),
                  child: Column(
                    children: [
                      Text(
                        l10n.appTitle,
                        style: theme.textTheme.displayLarge?.copyWith(
                              color: Colors.white,
                              fontSize: 42,
                              shadows: [
                                Shadow(
                                  offset: const Offset(2, 4),
                                  blurRadius: 8,
                                  color: Colors.black.withOpacity(0.3),
                                ),
                              ],
                            ),
                      ).animate().fadeIn(duration: 600.ms).slideY(begin: -0.2, end: 0),
                      const SizedBox(height: 24),
                      // Quick Action Buttons
                      Row(
                        mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                        children: [
                          Expanded(
                            child: _QuickActionButton(
                              icon: Icons.public_rounded,
                              label: l10n.worlds,
                              color: Colors.purpleAccent,
                              onTap: () => Navigator.pushNamed(context, AppRoutes.worlds),
                            ).animate().scale(delay: 200.ms),
                          ),
                          Expanded(
                            child: _QuickActionButton(
                              icon: Icons.emoji_events_rounded,
                              label: l10n.dailyChallenge,
                              color: Colors.orangeAccent,
                              onTap: () => Navigator.pushNamed(context, AppRoutes.dailyChallenge),
                            ).animate().scale(delay: 300.ms),
                          ),
                          Expanded(
                            child: _QuickActionButton(
                              icon: Icons.shopping_bag_rounded,
                              label: l10n.shop,
                              color: Colors.lightGreenAccent,
                              onTap: () => Navigator.pushNamed(context, AppRoutes.shop),
                            ).animate().scale(delay: 400.ms),
                          ),
                          Expanded(
                            child: _QuickActionButton(
                              icon: Icons.family_restroom_rounded,
                              label: l10n.parentDashboard,
                              color: Colors.lightBlueAccent,
                              onTap: () => Navigator.pushNamed(context, AppRoutes.parentDashboard),
                            ).animate().scale(delay: 500.ms),
                          ),
                        ],
                      ),
                    ],
                  ),
                ),
                
                // Games Grid
                Expanded(
                  child: Padding(
                    padding: const EdgeInsets.symmetric(horizontal: 20.0),
                    child: GridView.builder(
                      gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
                        crossAxisCount: 2,
                        crossAxisSpacing: 16,
                        mainAxisSpacing: 16,
                        childAspectRatio: 1.0,
                      ),
                      itemCount: GameDefinitions.allGames.length,
                      itemBuilder: (context, index) {
                        final game = GameDefinitions.allGames[index];
                        // Check parent restrictions
                        final settings = _parentService.getSettings();
                        final isGameAllowed = !settings.isParentModeEnabled || 
                            _parentService.isGameAllowed(game.id);
                        final isTimeLimitReached = settings.isParentModeEnabled && 
                            _parentService.isPlayTimeLimitReached();
                        
                        return GameCard(
                          game: game,
                          isLocked: settings.isParentModeEnabled && !isGameAllowed,
                          onTap: () {
                            if (settings.isParentModeEnabled) {
                              if (isTimeLimitReached) {
                                ScaffoldMessenger.of(context).showSnackBar(
                                  SnackBar(
                                    content: Text(l10n.timeLimitReached),
                                    backgroundColor: Colors.orange,
                                  ),
                                );
                                return;
                              }
                              if (!isGameAllowed) {
                                ScaffoldMessenger.of(context).showSnackBar(
                                  SnackBar(
                                    content: Text(l10n.gameRestricted),
                                    backgroundColor: Colors.red,
                                  ),
                                );
                                return;
                              }
                            }
                            Navigator.pushNamed(context, game.route);
                          },
                        ).animate().fadeIn(delay: (100 * index).ms).slideY(begin: 0.1, end: 0);
                      },
                    ),
                  ),
                ),
                
                const SizedBox(height: 16),
                
                // Bottom Navigation
                CustomBottomNavigation(
                  selectedIndex: _selectedIndex,
                  onItemTapped: _onItemTapped,
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}

class _QuickActionButton extends StatelessWidget {
  final IconData icon;
  final String label;
  final Color color;
  final VoidCallback onTap;

  const _QuickActionButton({
    required this.icon,
    required this.label,
    required this.color,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;

    return GestureDetector(
      onTap: onTap,
      child: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 4),
        child: GlassmorphicContainer(
          padding: const EdgeInsets.symmetric(horizontal: 4, vertical: 8),
          color: isDark ? Colors.white.withOpacity(0.1) : Colors.white.withOpacity(0.2),
          borderColor: isDark ? Colors.white.withOpacity(0.1) : Colors.white.withOpacity(0.3),
          borderRadius: 16,
          child: Column(
            mainAxisSize: MainAxisSize.min,
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Icon(icon, color: Colors.white, size: 24),
              const SizedBox(height: 4),
              Text(
                label,
                textAlign: TextAlign.center,
                maxLines: 1,
                overflow: TextOverflow.ellipsis,
                style: const TextStyle(
                  color: Colors.white,
                  fontSize: 10,
                  fontWeight: FontWeight.bold,
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
