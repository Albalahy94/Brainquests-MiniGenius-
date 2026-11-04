import 'package:flutter/material.dart';
import '../routes/app_routes.dart';
import '../widgets/parental_gate_dialog.dart';
import 'storage_service.dart';

class VipService {
  static final VipService _instance = VipService._internal();
  factory VipService() => _instance;
  VipService._internal();

  /// Total levels available per game (10 Free + 10 VIP Pro)
  static const int totalLevelsPerGame = 20;
  static const int freeLevelsCount = 10;

  /// Check if a specific level is a VIP exclusive level
  static bool isVipLevel(int levelNumber) {
    return levelNumber > freeLevelsCount;
  }

  /// Check if the user currently has VIP / Pro access
  bool isUserVip(StorageService storageService) {
    final progress = storageService.getUserProgress();
    return progress.isPremium || (progress.isTestMode ?? false);
  }

  /// Show the VIP upgrade dialog with Parental Gate protection
  Future<void> showVipLockedDialog(
    BuildContext context, {
    String? gameName,
    int? levelNumber,
  }) async {
    final isAr = Directionality.of(context) == TextDirection.rtl;

    final shouldShowPaywall = await showDialog<bool>(
      context: context,
      builder: (ctx) => AlertDialog(
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(24)),
        title: Row(
          children: [
            Container(
              padding: const EdgeInsets.all(8),
              decoration: BoxDecoration(
                color: Colors.amber.withOpacity(0.2),
                shape: BoxShape.circle,
              ),
              child: const Icon(
                Icons.workspace_premium,
                color: Colors.amber,
                size: 28,
              ),
            ),
            const SizedBox(width: 12),
            Expanded(
              child: Text(
                isAr ? 'مرحلة المحترفين (VIP) 👑' : 'VIP Pro Level 👑',
                style: const TextStyle(fontWeight: FontWeight.bold),
              ),
            ),
          ],
        ),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              isAr
                  ? 'المرحلة رقم ${levelNumber ?? 11} ${gameName != null ? "في لعبة $gameName" : ""} مصممة للأطفال المتقدمين وهي حصرية لمشتركي باقة Brainquests Pro.'
                  : 'Level ${levelNumber ?? 11} ${gameName != null ? "in $gameName" : ""} features advanced cognitive challenges exclusive to Brainquests Pro subscribers.',
              style: const TextStyle(fontSize: 15, height: 1.4),
            ),
            const SizedBox(height: 16),
            Container(
              padding: const EdgeInsets.all(12),
              decoration: BoxDecoration(
                color: Colors.amber.withOpacity(0.1),
                borderRadius: BorderRadius.circular(16),
                border: Border.all(color: Colors.amber.withOpacity(0.3)),
              ),
              child: Column(
                children: [
                  _buildBenefitRow(
                    Icons.star_rounded,
                    isAr ? '+100 مستوى وتحدي ذكاء جديد' : '+100 New Pro levels & challenges',
                  ),
                  const SizedBox(height: 8),
                  _buildBenefitRow(
                    Icons.palette_rounded,
                    isAr ? 'أشكال وثيمات حصرية للألعاب' : 'Exclusive game themes & shapes',
                  ),
                  const SizedBox(height: 8),
                  _buildBenefitRow(
                    Icons.psychology_rounded,
                    isAr ? 'رادار قياس ذكاء وتطور الطفل' : 'Cognitive development radar',
                  ),
                ],
              ),
            ),
          ],
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(ctx, false),
            child: Text(isAr ? 'لاحقاً' : 'Later'),
          ),
          ElevatedButton(
            onPressed: () => Navigator.pop(ctx, true),
            style: ElevatedButton.styleFrom(
              backgroundColor: Colors.amber[700],
              foregroundColor: Colors.white,
              shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(14)),
              padding: const EdgeInsets.symmetric(horizontal: 18, vertical: 12),
            ),
            child: Text(
              isAr ? 'استكشاف باقات الاشتراك 🚀' : 'Explore Subscriptions 🚀',
              style: const TextStyle(fontWeight: FontWeight.bold),
            ),
          ),
        ],
      ),
    );

    if (shouldShowPaywall == true && context.mounted) {
      // Must pass Parental Gate before navigating to purchase screen
      final passedGate = await showParentalGateDialog(context);
      if (passedGate && context.mounted) {
        Navigator.pushNamed(context, AppRoutes.premium);
      }
    }
  }

  static Widget _buildBenefitRow(IconData icon, String text) {
    return Row(
      children: [
        Icon(icon, size: 18, color: Colors.amber[800]),
        const SizedBox(width: 8),
        Expanded(
          child: Text(
            text,
            style: const TextStyle(fontSize: 13, fontWeight: FontWeight.w600),
          ),
        ),
      ],
    );
  }
}
