import 'package:flutter/material.dart';
import '../../../core/theme/app_theme.dart';
import '../../../core/services/world_service.dart';
import '../../../core/services/storage_service.dart';
import '../../../core/models/world.dart';

class WorldSelectScreen extends StatefulWidget {
  const WorldSelectScreen({super.key});

  @override
  State<WorldSelectScreen> createState() => _WorldSelectScreenState();
}

class _WorldSelectScreenState extends State<WorldSelectScreen> {
  final WorldService _worldService = WorldService();
  final StorageService _storageService = StorageService();
  int _totalStars = 0;
  bool _isLoading = true;

  @override
  void initState() {
    super.initState();
    _loadData();
  }

  Future<void> _loadData() async {
    try {
      // Initialize with timeout to prevent infinite loading
      await Future.wait([
        _worldService.init().timeout(
          const Duration(seconds: 3),
          onTimeout: () {
            debugPrint('⚠️ WorldService init timeout');
          },
        ),
        _storageService.init().timeout(
          const Duration(seconds: 3),
          onTimeout: () {
            debugPrint('⚠️ StorageService init timeout');
          },
        ),
      ]);

      if (mounted) {
        setState(() {
          _totalStars = _storageService.getUserProgress().totalStars;
          _isLoading = false;
        });
      }
    } catch (e, stackTrace) {
      debugPrint('❌ Error loading world data: $e');
      debugPrint('Stack: $stackTrace');
      if (mounted) {
        setState(() {
          _isLoading = false;
        });
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    if (_isLoading) {
      return Scaffold(
        body: Container(
          decoration: const BoxDecoration(
            gradient: AppTheme.blueGradient,
          ),
          child: const Center(
            child: CircularProgressIndicator(color: Colors.white),
          ),
        ),
      );
    }

    final availableWorlds = _worldService.getAvailableWorlds(_totalStars);

    return Scaffold(
      body: Container(
        decoration: const BoxDecoration(
          gradient: AppTheme.blueGradient,
        ),
        child: SafeArea(
          child: Column(
            children: [
              // Header
              Padding(
                padding: const EdgeInsets.all(20.0),
                child: Row(
                  children: [
                    IconButton(
                      icon: const Icon(Icons.arrow_back, color: Colors.white),
                      onPressed: () => Navigator.pop(context),
                    ),
                    Expanded(
                      child: Text(
                        'العوالم',
                        textAlign: TextAlign.center,
                        style:
                            Theme.of(context).textTheme.headlineLarge?.copyWith(
                                  color: Colors.white,
                                  fontWeight: FontWeight.bold,
                                ),
                      ),
                    ),
                    const SizedBox(width: 48), // Balance back button
                  ],
                ),
              ),

              // Stars indicator
              Container(
                margin:
                    const EdgeInsets.symmetric(horizontal: 20, vertical: 10),
                padding: const EdgeInsets.all(16),
                decoration: BoxDecoration(
                  color: Colors.white.withOpacity(0.2),
                  borderRadius: BorderRadius.circular(16),
                ),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    const Icon(Icons.star, color: Colors.amber, size: 28),
                    const SizedBox(width: 8),
                    Text(
                      '$_totalStars',
                      style: const TextStyle(
                        color: Colors.white,
                        fontSize: 24,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    const SizedBox(width: 4),
                    const Text(
                      'نجمة',
                      style: TextStyle(
                        color: Colors.white,
                        fontSize: 18,
                      ),
                    ),
                  ],
                ),
              ),

              // Worlds Grid
              Expanded(
                child: Padding(
                  padding: const EdgeInsets.all(20.0),
                  child: GridView.builder(
                    gridDelegate:
                        const SliverGridDelegateWithFixedCrossAxisCount(
                      crossAxisCount: 2,
                      crossAxisSpacing: 16,
                      mainAxisSpacing: 16,
                      childAspectRatio: 0.85,
                    ),
                    itemCount: WorldService.allWorlds.length,
                    itemBuilder: (context, index) {
                      try {
                        final world = WorldService.allWorlds[index];
                        // Use WorldService to check if world is unlocked (includes premium check)
                        final isUnlocked = _worldService.isWorldUnlocked(
                            world.id, _totalStars);
                        final worldProgress =
                            _worldService.getOrCreateWorldProgress(world.id);
                        final isAvailable =
                            availableWorlds.any((w) => w.id == world.id);

                        return _WorldCard(
                          world: world,
                          isUnlocked: isUnlocked && isAvailable,
                          totalStars: _totalStars,
                          worldProgress: worldProgress,
                          onTap: () {
                            if (isUnlocked && isAvailable) {
                              Navigator.pushNamed(
                                context,
                                '/world/${world.id}',
                              );
                            } else {
                              // Show message if locked
                              ScaffoldMessenger.of(context).showSnackBar(
                                SnackBar(
                                  content: Text(
                                    'هذا العالم مقفل. تحتاج ${world.requiredStars} نجمة لفتحه.',
                                  ),
                                  duration: const Duration(seconds: 2),
                                ),
                              );
                            }
                          },
                        );
                      } catch (e, stackTrace) {
                        debugPrint(
                            '❌ Error building world card at index $index: $e');
                        debugPrint('Stack: $stackTrace');
                        return const SizedBox.shrink();
                      }
                    },
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

class _WorldCard extends StatelessWidget {
  final World world;
  final bool isUnlocked;
  final int totalStars;
  final WorldProgress worldProgress;
  final VoidCallback onTap;

  const _WorldCard({
    required this.world,
    required this.isUnlocked,
    required this.totalStars,
    required this.worldProgress,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: isUnlocked ? onTap : null,
      child: Container(
        decoration: BoxDecoration(
          color: isUnlocked
              ? world.color.withOpacity(0.9)
              : Colors.grey.withOpacity(0.5),
          borderRadius: BorderRadius.circular(20),
          boxShadow: [
            BoxShadow(
              color: Colors.black.withOpacity(0.2),
              blurRadius: 8,
              offset: const Offset(0, 4),
            ),
          ],
        ),
        child: Stack(
          children: [
            // Lock overlay
            if (!isUnlocked)
              Container(
                decoration: BoxDecoration(
                  color: Colors.black.withOpacity(0.5),
                  borderRadius: BorderRadius.circular(20),
                ),
                child: Center(
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      const Icon(
                        Icons.lock,
                        color: Colors.white,
                        size: 40,
                      ),
                      const SizedBox(height: 8),
                      Text(
                        '${world.requiredStars} ⭐',
                        style: const TextStyle(
                          color: Colors.white,
                          fontSize: 16,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                    ],
                  ),
                ),
              ),

            // Content
            Center(
              child: Padding(
                padding: const EdgeInsets.all(12.0),
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  crossAxisAlignment: CrossAxisAlignment.center,
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Text(
                      world.icon,
                      style: const TextStyle(fontSize: 40),
                    ),
                    const SizedBox(height: 6),
                    Text(
                      world.nameAr,
                      textAlign: TextAlign.center,
                      style: const TextStyle(
                        color: Colors.white,
                        fontSize: 16,
                        fontWeight: FontWeight.bold,
                      ),
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                    ),
                    const SizedBox(height: 3),
                    Flexible(
                      child: Text(
                        world.descriptionAr,
                        textAlign: TextAlign.center,
                        style: TextStyle(
                          color: Colors.white.withOpacity(0.9),
                          fontSize: 11,
                          height: 1.1,
                        ),
                        maxLines: 2,
                        overflow: TextOverflow.ellipsis,
                      ),
                    ),
                    const SizedBox(height: 6),
                    // Show progress if unlocked
                    if (isUnlocked && worldProgress.completedLevels > 0)
                      Column(
                        children: [
                          Text(
                            '${worldProgress.completedLevels}/${world.totalLevels} مستويات',
                            style: TextStyle(
                              color: Colors.white.withOpacity(0.9),
                              fontSize: 12,
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                          const SizedBox(height: 2),
                          Text(
                            '${worldProgress.totalStars} ⭐',
                            style: TextStyle(
                              color: Colors.amber.withOpacity(0.9),
                              fontSize: 11,
                            ),
                          ),
                        ],
                      )
                    else
                      Text(
                        '${world.totalLevels} مستويات',
                        style: TextStyle(
                          color: Colors.white.withOpacity(0.8),
                          fontSize: 12,
                        ),
                      ),
                  ],
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
