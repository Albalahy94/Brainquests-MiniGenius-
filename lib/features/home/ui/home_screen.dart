import 'package:flutter/material.dart';
import 'package:flutter_animate/flutter_animate.dart';
import 'package:minigenius/generated/l10n/app_localizations.dart';
import 'package:provider/provider.dart';
import 'package:minigenius/core/models/game_info.dart';
import 'package:minigenius/core/routes/app_routes.dart';
import 'package:minigenius/core/services/parent_dashboard_service.dart';
import 'package:minigenius/core/providers/app_state_provider.dart';
import '../../../core/widgets/glassmorphic_container.dart';
import '../../../core/widgets/parental_gate_dialog.dart';
import '../widgets/game_card.dart';
import '../widgets/bottom_navigation.dart';
import '../widgets/animated_background.dart';
import '../../../core/services/screen_time_service.dart';

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
                      FittedBox(
                        fit: BoxFit.scaleDown,
                        child: Row(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: [
                            Text(
                              l10n.appTitle,
                              style: theme.textTheme.displayLarge?.copyWith(
                                    color: Colors.white,
                                    fontSize: 38,
                                    shadows: [
                                      Shadow(
                                        offset: const Offset(2, 4),
                                        blurRadius: 8,
                                        color: Colors.black.withOpacity(0.3),
                                      ),
                                    ],
                                  ),
                            ),
                            const SizedBox(width: 8),
                            GestureDetector(
                              onTap: () async {
                                final isParent = await showParentalGateDialog(context);
                                if (isParent && context.mounted) {
                                  Navigator.pushNamed(context, AppRoutes.premium);
                                }
                              },
                              child: Container(
                                padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                                decoration: BoxDecoration(
                                  gradient: const LinearGradient(
                                    colors: [Color(0xFFFFD54F), Color(0xFFFF8F00)],
                                  ),
                                  borderRadius: BorderRadius.circular(12),
                                  boxShadow: [
                                    BoxShadow(
                                      color: Colors.amber.withOpacity(0.4),
                                      blurRadius: 6,
                                      offset: const Offset(0, 2),
                                    ),
                                  ],
                                ),
                                child: const Row(
                                  mainAxisSize: MainAxisSize.min,
                                  children: [
                                    Icon(Icons.workspace_premium, color: Color(0xFF2E1500), size: 14),
                                    SizedBox(width: 3),
                                    Text(
                                      'PRO',
                                      style: TextStyle(
                                        color: Color(0xFF2E1500),
                                        fontSize: 11,
                                        fontWeight: FontWeight.w900,
                                      ),
                                    ),
                                  ],
                                ),
                              ),
                            ),
                          ],
                        ),
                      ).animate().fadeIn(duration: 600.ms).slideY(begin: -0.2, end: 0),
                      // Active Child & Screen Time Indicator Pill
                      AnimatedBuilder(
                        animation: ScreenTimeService(),
                        builder: (context, _) {
                          final screenTime = ScreenTimeService();
                          final child = screenTime.activeChild;
                          final hasLimit = child.isScreenTimeEnabled &&
                              child.dailyLimitMinutes > 0;
                          final rem = child.remainingMinutes;

                          // Only show if the parent has actively enabled screen time limits
                          if (!hasLimit) {
                            return const SizedBox.shrink();
                          }

                          return Container(
                            margin: const EdgeInsets.only(top: 8),
                            padding: const EdgeInsets.symmetric(
                                horizontal: 10, vertical: 4),
                            decoration: BoxDecoration(
                              color: Colors.white.withOpacity(0.14),
                              borderRadius: BorderRadius.circular(12),
                              border: Border.all(
                                color: Colors.white.withOpacity(0.18),
                              ),
                            ),
                            child: Row(
                              mainAxisSize: MainAxisSize.min,
                              children: [
                                const Icon(Icons.face_rounded,
                                    size: 14, color: Colors.amberAccent),
                                const SizedBox(width: 5),
                                Text(
                                  child.name,
                                  style: const TextStyle(
                                    color: Colors.white,
                                    fontSize: 12,
                                    fontWeight: FontWeight.bold,
                                  ),
                                ),
                                if (hasLimit) ...[
                                  const SizedBox(width: 6),
                                  Text(
                                    rem >= 0 ? '• ⏳ باقي $rem د' : '• ⏳ مفتوح',
                                    style: TextStyle(
                                      color: rem > 5
                                          ? Colors.white70
                                          : Colors.amberAccent,
                                      fontSize: 11,
                                    ),
                                  ),
                                ],
                              ],
                            ),
                          );
                        },
                      ),
                      const SizedBox(height: 18),
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
                        childAspectRatio: 0.88,
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
              FittedBox(
                fit: BoxFit.scaleDown,
                child: Text(
                  label,
                  textAlign: TextAlign.center,
                  maxLines: 1,
                  style: const TextStyle(
                    color: Colors.white,
                    fontSize: 10,
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
