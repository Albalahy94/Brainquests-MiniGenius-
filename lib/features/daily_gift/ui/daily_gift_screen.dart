import 'package:flutter/material.dart';
import '../../../core/theme/app_theme.dart';
import '../../../core/services/daily_gift_service.dart';
import '../../../core/services/storage_service.dart';

class DailyGiftScreen extends StatefulWidget {
  const DailyGiftScreen({super.key});

  @override
  State<DailyGiftScreen> createState() => _DailyGiftScreenState();
}

class _DailyGiftScreenState extends State<DailyGiftScreen>
    with SingleTickerProviderStateMixin {
  late DailyGiftService _dailyGiftService;
  late AnimationController _controller;
  bool _isClaiming = false;
  DailyGiftResult? _result;

  @override
  void initState() {
    super.initState();
    final storageService = StorageService();
    storageService.init().then((_) {
      setState(() {
        _dailyGiftService = DailyGiftService(storageService);
      });
    });

    _controller = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 1000),
    );
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  Future<void> _claimGift() async {
    setState(() {
      _isClaiming = true;
    });

    final result = await _dailyGiftService.claimDailyGift();
    
    setState(() {
      _result = result;
      _isClaiming = false;
    });

    if (result.success) {
      _controller.forward();
    }

    if (mounted) {
      Future.delayed(const Duration(seconds: 2), () {
        if (mounted) {
          Navigator.pop(context);
        }
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    final isAvailable = _dailyGiftService.isGiftAvailable();
    final consecutiveDays = _dailyGiftService.getConsecutiveDays();
    final nextGiftTime = _dailyGiftService.getNextGiftTime();

    return Scaffold(
      appBar: AppBar(
        title: const Text('Daily Gift'),
      ),
      body: Container(
        decoration: const BoxDecoration(
          gradient: AppTheme.blueGradient,
        ),
        child: SafeArea(
          child: Padding(
            padding: const EdgeInsets.all(24.0),
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                // Gift icon
                ScaleTransition(
                  scale: Tween<double>(begin: 0.8, end: 1.0).animate(
                    CurvedAnimation(parent: _controller, curve: Curves.elasticOut),
                  ),
                  child: Container(
                    width: 120,
                    height: 120,
                    decoration: BoxDecoration(
                      color: AppTheme.yellowAccent,
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
                      Icons.card_giftcard,
                      size: 60,
                      color: AppTheme.darkText,
                    ),
                  ),
                ),
                const SizedBox(height: 32),
                // Title
                Text(
                  isAvailable ? 'Your Daily Gift!' : 'Come Back Tomorrow!',
                  style: Theme.of(context).textTheme.displayMedium?.copyWith(
                        color: AppTheme.white,
                        fontWeight: FontWeight.bold,
                      ),
                  textAlign: TextAlign.center,
                ),
                const SizedBox(height: 16),
                // Consecutive days
                if (consecutiveDays > 0)
                  Container(
                    padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
                    decoration: BoxDecoration(
                      color: AppTheme.white.withOpacity(0.2),
                      borderRadius: BorderRadius.circular(20),
                    ),
                    child: Text(
                      '$consecutiveDays day${consecutiveDays > 1 ? 's' : ''} in a row!',
                      style: Theme.of(context).textTheme.titleMedium?.copyWith(
                            color: AppTheme.white,
                          ),
                    ),
                  ),
                const SizedBox(height: 32),
                // Rewards preview
                if (isAvailable && !_isClaiming && _result == null) ...[
                  _buildRewardPreview('⭐', 'Stars', consecutiveDays >= 7 ? '3' : (consecutiveDays >= 3 ? '2' : '1')),
                  const SizedBox(height: 16),
                  _buildRewardPreview('💎', 'Points', consecutiveDays >= 7 ? '50' : (consecutiveDays >= 3 ? '25' : '10')),
                ],
                // Result
                if (_result != null && _result!.success) ...[
                  Text(
                    'You received:',
                    style: Theme.of(context).textTheme.titleLarge?.copyWith(
                          color: AppTheme.white,
                        ),
                  ),
                  const SizedBox(height: 16),
                  Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      _buildRewardItem('⭐', '${_result!.stars} Stars'),
                      const SizedBox(width: 24),
                      _buildRewardItem('💎', '${_result!.points} Points'),
                    ],
                  ),
                  if (_result!.stickerReward != null) ...[
                    const SizedBox(height: 16),
                    _buildRewardItem('🎁', 'New Sticker!'),
                  ],
                ],
                const Spacer(),
                // Claim button or timer
                if (isAvailable && _result == null)
                  SizedBox(
                    width: double.infinity,
                    child: ElevatedButton(
                      onPressed: _isClaiming ? null : _claimGift,
                      style: ElevatedButton.styleFrom(
                        backgroundColor: AppTheme.yellowAccent,
                        foregroundColor: AppTheme.darkText,
                        padding: const EdgeInsets.symmetric(vertical: 16),
                      ),
                      child: _isClaiming
                          ? const CircularProgressIndicator()
                          : Text(
                              'Claim Gift',
                              style: Theme.of(context).textTheme.titleLarge,
                            ),
                    ),
                  )
                else if (!isAvailable)
                  Column(
                    children: [
                      Text(
                        nextGiftTime,
                        style: Theme.of(context).textTheme.titleMedium?.copyWith(
                              color: AppTheme.white,
                            ),
                      ),
                      const SizedBox(height: 16),
                      SizedBox(
                        width: double.infinity,
                        child: OutlinedButton(
                          onPressed: () => Navigator.pop(context),
                          style: OutlinedButton.styleFrom(
                            foregroundColor: AppTheme.white,
                            side: const BorderSide(color: AppTheme.white),
                            padding: const EdgeInsets.symmetric(vertical: 16),
                          ),
                          child: const Text('Close'),
                        ),
                      ),
                    ],
                  ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildRewardPreview(String emoji, String label, String amount) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 12),
      decoration: BoxDecoration(
        color: AppTheme.white.withOpacity(0.2),
        borderRadius: BorderRadius.circular(16),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Text(emoji, style: const TextStyle(fontSize: 24)),
          const SizedBox(width: 12),
          Text(
            '$label: $amount',
            style: Theme.of(context).textTheme.titleMedium?.copyWith(
                  color: AppTheme.white,
                ),
          ),
        ],
      ),
    );
  }

  Widget _buildRewardItem(String emoji, String label) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
      decoration: BoxDecoration(
        color: AppTheme.white,
        borderRadius: BorderRadius.circular(16),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Text(emoji, style: const TextStyle(fontSize: 24)),
          const SizedBox(width: 8),
          Text(
            label,
            style: Theme.of(context).textTheme.titleMedium?.copyWith(
                  color: AppTheme.darkText,
                  fontWeight: FontWeight.bold,
                ),
          ),
        ],
      ),
    );
  }
}

