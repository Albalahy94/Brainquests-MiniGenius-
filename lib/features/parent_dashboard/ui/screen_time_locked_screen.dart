import 'package:flutter/material.dart';
import '../../../core/theme/app_theme.dart';
import '../../../core/services/screen_time_service.dart';
import '../../../core/services/parent_dashboard_service.dart';
import '../../../core/widgets/parental_gate_dialog.dart';
import '../../../core/routes/app_routes.dart';

class ScreenTimeLockedScreen extends StatelessWidget {
  const ScreenTimeLockedScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final screenTime = ScreenTimeService();
    final child = screenTime.activeChild;

    return PopScope(
      canPop: false,
      child: Scaffold(
        body: Container(
          width: double.infinity,
          height: double.infinity,
          decoration: const BoxDecoration(
            gradient: LinearGradient(
              begin: Alignment.topCenter,
              end: Alignment.bottomCenter,
              colors: [
                Color(0xFF0F172A),
                Color(0xFF1E1B4B),
                Color(0xFF311042),
              ],
            ),
          ),
          child: SafeArea(
            child: LayoutBuilder(
              builder: (context, constraints) {
                return SingleChildScrollView(
                  physics: const BouncingScrollPhysics(),
                  child: ConstrainedBox(
                    constraints: BoxConstraints(minHeight: constraints.maxHeight),
                    child: IntrinsicHeight(
                      child: Padding(
                        padding: const EdgeInsets.symmetric(horizontal: 24.0, vertical: 20),
                        child: Column(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: [
                            const Spacer(),

                            // Bedtime / Sleeping Moon Visual
                            Container(
                              width: 120,
                              height: 120,
                              decoration: BoxDecoration(
                                shape: BoxShape.circle,
                                gradient: RadialGradient(
                                  colors: [
                                    Colors.amber.withOpacity(0.35),
                                    Colors.transparent,
                                  ],
                                ),
                              ),
                              child: Center(
                                child: Container(
                                  width: 84,
                                  height: 84,
                                  decoration: BoxDecoration(
                                    shape: BoxShape.circle,
                                    color: Colors.amber.shade200,
                                    boxShadow: [
                                      BoxShadow(
                                        color: Colors.amber.withOpacity(0.5),
                                        blurRadius: 25,
                                        spreadRadius: 4,
                                      ),
                                    ],
                                  ),
                                  child: const Icon(
                                    Icons.bedtime_rounded,
                                    size: 48,
                                    color: Color(0xFFD97706),
                                  ),
                                ),
                              ),
                            ),

                            const SizedBox(height: 20),

                            // Child Name Badge
                            Container(
                              padding:
                                  const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
                              decoration: BoxDecoration(
                                color: Colors.white.withOpacity(0.12),
                                borderRadius: BorderRadius.circular(20),
                                border: Border.all(
                                  color: Colors.white.withOpacity(0.25),
                                ),
                              ),
                              child: Row(
                                mainAxisSize: MainAxisSize.min,
                                children: [
                                  const Icon(Icons.face_rounded,
                                      color: Colors.amberAccent, size: 20),
                                  const SizedBox(width: 8),
                                  Flexible(
                                    child: Text(
                                      child.name,
                                      overflow: TextOverflow.ellipsis,
                                      style: const TextStyle(
                                        color: Colors.white,
                                        fontSize: 16,
                                        fontWeight: FontWeight.bold,
                                      ),
                                    ),
                                  ),
                                ],
                              ),
                            ),

                            const SizedBox(height: 18),

                            // Gentle Kid-Friendly Title
                            const Text(
                              'انتهى وقت اللعب اليوم يا بطل! 🌙',
                              textAlign: TextAlign.center,
                              style: TextStyle(
                                color: Colors.white,
                                fontSize: 22,
                                fontWeight: FontWeight.bold,
                                height: 1.3,
                              ),
                            ),

                            const SizedBox(height: 12),

                            // Warm Caring Subtitle
                            Text(
                              'أحسنت يا ${child.name}! لقد تعلمت واستمتعت كثيراً اليوم.\nحان وقت أخذ راحة لعينيك الجميلتين واللعب مع عائلتك أو النوم بسلام ✨',
                              textAlign: TextAlign.center,
                              style: TextStyle(
                                color: Colors.white.withOpacity(0.85),
                                fontSize: 14,
                                height: 1.5,
                              ),
                            ),

                            const Spacer(),
                            const SizedBox(height: 20),

                            // Parent Unlock Action Button
                            OutlinedButton.icon(
                              style: OutlinedButton.styleFrom(
                                foregroundColor: Colors.white70,
                                side: BorderSide(color: Colors.white.withOpacity(0.3)),
                                padding: const EdgeInsets.symmetric(
                                    horizontal: 24, vertical: 12),
                                shape: RoundedRectangleBorder(
                                  borderRadius: BorderRadius.circular(24),
                                ),
                              ),
                              icon: const Icon(Icons.vpn_key_rounded, size: 18),
                              label: const Text(
                                'أنا ولي الأمر (إدارة الوقت)',
                                style: TextStyle(fontSize: 14),
                              ),
                              onPressed: () => _handleParentUnlock(context),
                            ),

                            const SizedBox(height: 12),
                          ],
                        ),
                      ),
                    ),
                  ),
                );
              },
            ),
          ),
        ),
      ),
    );
  }

  Future<void> _handleParentUnlock(BuildContext context) async {
    // Protected by Parental Gate (Math puzzle or Parent Password)
    final parentService = ParentDashboardService();
    final parentSettings = parentService.getSettings();

    if (parentSettings.parentPassword != null &&
        parentSettings.parentPassword!.isNotEmpty) {
      _showPasswordDialog(context);
    } else {
      final passed = await showParentalGateDialog(context);
      if (passed == true && context.mounted) {
        _showParentUnlockMenu(context);
      }
    }
  }

  void _showPasswordDialog(BuildContext context) {
    final controller = TextEditingController();
    showDialog(
      context: context,
      builder: (ctx) => AlertDialog(
        title: const Text('كلمة مرور ولي الأمر'),
        content: TextField(
          controller: controller,
          obscureText: true,
          decoration: const InputDecoration(
            labelText: 'أدخل كلمة المرور',
            prefixIcon: Icon(Icons.lock),
          ),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(ctx),
            child: const Text('إلغاء'),
          ),
          ElevatedButton(
            onPressed: () {
              final ok =
                  ParentDashboardService().verifyPassword(controller.text);
              if (ok) {
                Navigator.pop(ctx);
                _showParentUnlockMenu(context);
              } else {
                ScaffoldMessenger.of(context).showSnackBar(
                  const SnackBar(
                    content: Text('كلمة المرور غير صحيحة'),
                    backgroundColor: Colors.red,
                  ),
                );
              }
            },
            child: const Text('تأكيد'),
          ),
        ],
      ),
    );
  }

  void _showParentUnlockMenu(BuildContext context) {
    final screenTime = ScreenTimeService();
    final current = screenTime.activeChild;

    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (ctx) => Container(
        padding: const EdgeInsets.all(24),
        decoration: const BoxDecoration(
          color: Color(0xFF1E293B),
          borderRadius: BorderRadius.vertical(top: Radius.circular(28)),
        ),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            Row(
              children: [
                const Icon(Icons.shield_rounded,
                    color: Colors.amberAccent, size: 28),
                const SizedBox(width: 10),
                Text(
                  'خيارات ولي الأمر - ${current.name}',
                  style: const TextStyle(
                    color: Colors.white,
                    fontSize: 18,
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ],
            ),
            const SizedBox(height: 18),

            // Option 1: Add 15 Minutes
            ListTile(
              leading: const CircleAvatar(
                backgroundColor: Color(0xFF0284C7),
                child: Icon(Icons.add_alarm_rounded, color: Colors.white),
              ),
              title: const Text('إضافة 15 دقيقة لعب إضافية',
                  style: TextStyle(color: Colors.white)),
              subtitle: const Text('تمديد الوقت للطفل الحالي',
                  style: TextStyle(color: Colors.white60)),
              onTap: () async {
                Navigator.pop(ctx);
                await screenTime.addExtraMinutes(15);
              },
            ),

            // Option 2: Add 30 Minutes
            ListTile(
              leading: const CircleAvatar(
                backgroundColor: Color(0xFF059669),
                child: Icon(Icons.more_time_rounded, color: Colors.white),
              ),
              title: const Text('إضافة 30 دقيقة لعب إضافية',
                  style: TextStyle(color: Colors.white)),
              subtitle: const Text('وقت إضافي للاستمتاع بالألعاب',
                  style: TextStyle(color: Colors.white60)),
              onTap: () async {
                Navigator.pop(ctx);
                await screenTime.addExtraMinutes(30);
              },
            ),

            // Option 3: Unlock for today
            ListTile(
              leading: const CircleAvatar(
                backgroundColor: Color(0xFF7C3AED),
                child: Icon(Icons.lock_open_rounded, color: Colors.white),
              ),
              title: const Text('إلغاء القفل لبقية اليوم',
                  style: TextStyle(color: Colors.white)),
              subtitle: const Text('السماح باللعب بدون قيد حتى الغد',
                  style: TextStyle(color: Colors.white60)),
              onTap: () async {
                Navigator.pop(ctx);
                await screenTime.unlockForToday();
              },
            ),

            // Option 4: Switch child profile
            if (screenTime.children.length > 1)
              ListTile(
                leading: const CircleAvatar(
                  backgroundColor: Color(0xFFEA580C),
                  child: Icon(Icons.switch_account_rounded, color: Colors.white),
                ),
                title: const Text('تبديل الطفل الحالي',
                    style: TextStyle(color: Colors.white)),
                subtitle: const Text('تمكين طفل آخر من اللعب بوقته الخاص',
                    style: TextStyle(color: Colors.white60)),
                onTap: () {
                  Navigator.pop(ctx);
                  _showSwitchChildDialog(context);
                },
              ),

            // Option 5: Go to Parent Dashboard
            ListTile(
              leading: const CircleAvatar(
                backgroundColor: Colors.white24,
                child: Icon(Icons.settings_rounded, color: Colors.white),
              ),
              title: const Text('لوحة تحكم الوالدين الكاملة',
                  style: TextStyle(color: Colors.white)),
              onTap: () {
                Navigator.pop(ctx);
                Navigator.pushNamed(context, AppRoutes.parentDashboard);
              },
            ),
            const SizedBox(height: 12),
          ],
        ),
      ),
    );
  }

  void _showSwitchChildDialog(BuildContext context) {
    final screenTime = ScreenTimeService();
    showDialog(
      context: context,
      builder: (ctx) => AlertDialog(
        title: const Text('اختيار الطفل الذي سيلعب الآن'),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          children: screenTime.children.map((c) {
            final isCurrent = c.id == screenTime.activeChild.id;
            return ListTile(
              leading: CircleAvatar(
                backgroundColor:
                    isCurrent ? AppTheme.primaryBlue : Colors.grey.shade300,
                child: Text(
                  c.name.isNotEmpty ? c.name[0] : '؟',
                  style: TextStyle(
                    color: isCurrent ? Colors.white : Colors.black87,
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ),
              title: Text(c.name,
                  style: TextStyle(
                      fontWeight:
                          isCurrent ? FontWeight.bold : FontWeight.normal)),
              subtitle: Text(
                c.isScreenTimeEnabled
                    ? 'المحدد: ${c.dailyLimitMinutes} دقيقة - المتبقي: ${c.remainingMinutes >= 0 ? "${c.remainingMinutes} دقيقة" : "مفتوح"}'
                    : 'بدون قيد زمني',
              ),
              trailing: isCurrent
                  ? const Icon(Icons.check_circle, color: Colors.green)
                  : null,
              onTap: () async {
                Navigator.pop(ctx);
                await screenTime.setActiveChild(c.id);
              },
            );
          }).toList(),
        ),
      ),
    );
  }
}
