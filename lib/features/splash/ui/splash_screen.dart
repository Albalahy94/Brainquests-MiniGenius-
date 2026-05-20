import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';
import '../../../core/theme/app_theme.dart';
import '../../../core/routes/app_routes.dart';
import '../../../core/services/storage_service.dart';

class SplashScreen extends StatefulWidget {
  const SplashScreen({super.key});

  @override
  State<SplashScreen> createState() => _SplashScreenState();
}

class _SplashScreenState extends State<SplashScreen>
    with SingleTickerProviderStateMixin {
  late AnimationController _controller;
  late Animation<double> _fadeAnimation;
  late Animation<double> _scaleAnimation;

  @override
  void initState() {
    super.initState();
    _controller = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 1500),
    );

    _fadeAnimation = Tween<double>(begin: 0.0, end: 1.0).animate(
      CurvedAnimation(
        parent: _controller,
        curve: Curves.easeIn,
      ),
    );

    _scaleAnimation = Tween<double>(begin: 0.5, end: 1.0).animate(
      CurvedAnimation(
        parent: _controller,
        curve: Curves.elasticOut,
      ),
    );

    _controller.forward();
    _initializeApp();
  }

  Future<void> _initializeApp() async {
    try {
      // Initialize storage with timeout
      final storageService = StorageService();
      await storageService.init().timeout(
        const Duration(seconds: 5),
        onTimeout: () {
          debugPrint('⚠️ Storage initialization timeout - continuing anyway');
        },
      );
      debugPrint('✅ Storage initialized');
    } catch (e, stackTrace) {
      debugPrint('❌ Error initializing storage: $e');
      debugPrint('Stack: $stackTrace');
      // Continue even if storage initialization fails
    }

    // Wait for animation to complete (minimum 1.5 seconds)
    await Future.delayed(const Duration(milliseconds: 1500));

    if (!mounted) {
      debugPrint('⚠️ Widget not mounted, skipping navigation');
      return;
    }

    try {
      final prefs = await SharedPreferences.getInstance();
      final isFirstLaunch = prefs.getBool('is_first_launch') ?? true;

      debugPrint('🔄 Navigating...');
      if (isFirstLaunch) {
        Navigator.pushReplacementNamed(context, AppRoutes.onboarding);
      } else {
        Navigator.pushReplacementNamed(context, AppRoutes.home);
      }
      debugPrint('✅ Navigation successful');
    } catch (e, stackTrace) {
      debugPrint('❌ Error navigating: $e');
      debugPrint('Stack: $stackTrace');
      // Try again after a short delay
      await Future.delayed(const Duration(milliseconds: 500));
      if (mounted) {
        try {
          debugPrint('🔄 Retrying navigation...');
          Navigator.pushReplacementNamed(context, AppRoutes.home);
          debugPrint('✅ Retry navigation successful');
        } catch (e2, stackTrace2) {
          debugPrint('❌ Error navigating to home (retry): $e2');
          debugPrint('Stack: $stackTrace2');
        }
      }
    }
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Container(
        decoration: const BoxDecoration(
          gradient: AppTheme.blueGradient,
        ),
        child: SafeArea(
          child: Stack(
            children: [
              // Floating stars animation
              ...List.generate(5, (index) {
                return Positioned(
                  left: (index * 80.0) % MediaQuery.of(context).size.width,
                  top: (index * 100.0) % MediaQuery.of(context).size.height,
                  child: FadeTransition(
                    opacity: _fadeAnimation,
                    child: const Icon(
                      Icons.star,
                      color: AppTheme.yellowAccent,
                      size: 30,
                    ),
                  ),
                );
              }),
              // Main content
              Center(
                child: FadeTransition(
                  opacity: _fadeAnimation,
                  child: ScaleTransition(
                    scale: _scaleAnimation,
                    child: Column(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        // Brain icon/mascot
                        Container(
                          width: 120,
                          height: 120,
                          decoration: BoxDecoration(
                            color: AppTheme.white,
                            shape: BoxShape.circle,
                            boxShadow: [
                              BoxShadow(
                                color: Colors.black.withOpacity(0.2),
                                blurRadius: 20,
                                offset: const Offset(0, 10),
                              ),
                            ],
                          ),
                          child: const Icon(
                            Icons.psychology,
                            size: 60,
                            color: AppTheme.primaryBlue,
                          ),
                        ),
                        const SizedBox(height: 24),
                        // App name
                        Text(
                          'MiniGenius',
                          style: Theme.of(context).textTheme.displayLarge?.copyWith(
                                color: AppTheme.white,
                                fontWeight: FontWeight.bold,
                                shadows: [
                                  Shadow(
                                    offset: const Offset(2, 2),
                                    blurRadius: 4,
                                    color: Colors.black.withOpacity(0.3),
                                  ),
                                ],
                              ),
                        ),
                        const SizedBox(height: 8),
                        Text(
                          'Brain Training for Kids',
                          style: Theme.of(context).textTheme.titleMedium?.copyWith(
                                color: AppTheme.white.withOpacity(0.9),
                              ),
                        ),
                      ],
                    ),
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

