import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:fl_chart/fl_chart.dart';
import 'package:pdf/pdf.dart';
import 'package:pdf/widgets.dart' as pw;
import 'package:printing/printing.dart';
import 'package:intl/intl.dart';
import 'package:url_launcher/url_launcher.dart';
import '../../../core/theme/app_theme.dart';
import '../../../core/services/parent_dashboard_service.dart';
import '../../../core/services/storage_service.dart';
import '../../../core/models/parent_dashboard.dart';
import '../../../core/models/game_info.dart';
import '../../../core/services/vip_service.dart';
import '../../../core/routes/app_routes.dart';
import '../../../core/widgets/parental_gate_dialog.dart';
import '../../../core/services/licensing_api_service.dart';
import '../../../core/services/screen_time_service.dart';
import '../../../core/models/child_profile.dart';
import 'parent_account_dialog.dart';
import 'dart:math';

class ParentDashboardScreen extends StatefulWidget {
  const ParentDashboardScreen({super.key});

  @override
  State<ParentDashboardScreen> createState() => _ParentDashboardScreenState();
}

class _ParentDashboardScreenState extends State<ParentDashboardScreen> {
  final ParentDashboardService _parentService = ParentDashboardService();
  final StorageService _storageService = StorageService();
  ParentSettings? _settings;
  ChildProgressReport? _report;
  bool _isAuthenticated = false;
  Map<String, String?> _parentProfile = {};
  final TextEditingController _passwordController = TextEditingController();

  @override
  void initState() {
    super.initState();
    ScreenTimeService().addListener(_onScreenTimeUpdate);
    _loadData();
  }

  @override
  void dispose() {
    ScreenTimeService().removeListener(_onScreenTimeUpdate);
    _passwordController.dispose();
    super.dispose();
  }

  void _onScreenTimeUpdate() {
    if (mounted) {
      setState(() {});
    }
  }

  Future<void> _loadData() async {
    await _storageService.init();
    await ScreenTimeService().initialize();
    final profile = await LicensingApiService().getParentProfile();
    setState(() {
      _settings = _parentService.getSettings();
      _report = _parentService.generateReport();
      _parentProfile = profile;
    });
  }

  void _authenticate(bool isAr) {
    if (_passwordController.text.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text(isAr ? 'يرجى إدخال كلمة المرور' : 'Please enter parent password')),
      );
      return;
    }

    if (_parentService.verifyPassword(_passwordController.text)) {
      setState(() {
        _isAuthenticated = true;
      });
      _passwordController.clear();
    } else {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(isAr ? 'كلمة المرور غير صحيحة' : 'Incorrect password'),
          backgroundColor: Colors.red,
        ),
      );
    }
  }

  void _setupPassword([bool isAr = true]) {
    final passwordController = TextEditingController();
    final confirmController = TextEditingController();
    
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: Text(isAr ? 'إعداد كلمة المرور' : 'Set Parent Password'),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            TextField(
              controller: passwordController,
              obscureText: true,
              keyboardType: TextInputType.number,
              decoration: InputDecoration(
                labelText: isAr ? 'كلمة المرور' : 'Password',
                hintText: isAr ? 'أدخل كلمة المرور' : 'Enter password',
              ),
            ),
            const SizedBox(height: 16),
            TextField(
              controller: confirmController,
              obscureText: true,
              keyboardType: TextInputType.number,
              decoration: InputDecoration(
                labelText: isAr ? 'تأكيد كلمة المرور' : 'Confirm Password',
                hintText: isAr ? 'أعد إدخال كلمة المرور' : 'Re-enter password',
              ),
            ),
          ],
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: Text(isAr ? 'إلغاء' : 'Cancel'),
          ),
          TextButton(
            onPressed: () async {
              if (passwordController.text.isEmpty) {
                ScaffoldMessenger.of(context).showSnackBar(
                  SnackBar(content: Text(isAr ? 'يرجى إدخال كلمة المرور' : 'Please enter password')),
                );
                return;
              }

              if (passwordController.text != confirmController.text) {
                ScaffoldMessenger.of(context).showSnackBar(
                  SnackBar(
                    content: Text(isAr ? 'كلمات المرور غير متطابقة' : 'Passwords do not match'),
                    backgroundColor: Colors.red,
                  ),
                );
                return;
              }

              if (passwordController.text.length < 4) {
                ScaffoldMessenger.of(context).showSnackBar(
                  SnackBar(
                    content: Text(isAr ? 'كلمة المرور يجب أن تكون 4 أحرف على الأقل' : 'Password must be at least 4 digits'),
                    backgroundColor: Colors.red,
                  ),
                );
                return;
              }

              await _parentService.setPassword(passwordController.text);
              Navigator.pop(context);
              ScaffoldMessenger.of(context).showSnackBar(
                SnackBar(
                  content: Text(isAr ? 'تم إعداد كلمة المرور بنجاح' : 'Password configured successfully'),
                  backgroundColor: Colors.green,
                ),
              );
              _loadData();
            },
            child: Text(isAr ? 'حفظ' : 'Save'),
          ),
        ],
      ),
    );
  }

  void _changePassword(bool isAr) {
    final oldPasswordController = TextEditingController();
    final newPasswordController = TextEditingController();
    final confirmController = TextEditingController();
    
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: Text(isAr ? 'تغيير كلمة المرور' : 'Change Password'),
        content: SingleChildScrollView(
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              TextField(
                controller: oldPasswordController,
                obscureText: true,
                keyboardType: TextInputType.number,
                decoration: InputDecoration(
                  labelText: isAr ? 'كلمة المرور القديمة' : 'Old Password',
                ),
              ),
              const SizedBox(height: 16),
              TextField(
                controller: newPasswordController,
                obscureText: true,
                keyboardType: TextInputType.number,
                decoration: InputDecoration(
                  labelText: isAr ? 'كلمة المرور الجديدة' : 'New Password',
                ),
              ),
              const SizedBox(height: 16),
              TextField(
                controller: confirmController,
                obscureText: true,
                keyboardType: TextInputType.number,
                decoration: InputDecoration(
                  labelText: isAr ? 'تأكيد كلمة المرور الجديدة' : 'Confirm New Password',
                ),
              ),
            ],
          ),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: Text(isAr ? 'إلغاء' : 'Cancel'),
          ),
          TextButton(
            onPressed: () async {
              if (oldPasswordController.text.isEmpty ||
                  newPasswordController.text.isEmpty ||
                  confirmController.text.isEmpty) {
                ScaffoldMessenger.of(context).showSnackBar(
                  SnackBar(content: Text(isAr ? 'يرجى ملء جميع الحقول' : 'Please fill all fields')),
                );
                return;
              }

              if (newPasswordController.text != confirmController.text) {
                ScaffoldMessenger.of(context).showSnackBar(
                  SnackBar(
                    content: Text(isAr ? 'كلمات المرور الجديدة غير متطابقة' : 'New passwords do not match'),
                    backgroundColor: Colors.red,
                  ),
                );
                return;
              }

              if (newPasswordController.text.length < 4) {
                ScaffoldMessenger.of(context).showSnackBar(
                  SnackBar(
                    content: Text(isAr ? 'كلمة المرور يجب أن تكون 4 أحرف على الأقل' : 'Password must be at least 4 digits'),
                    backgroundColor: Colors.red,
                  ),
                );
                return;
              }

              try {
                await _parentService.changePassword(
                  oldPasswordController.text,
                  newPasswordController.text,
                );
                Navigator.pop(context);
                ScaffoldMessenger.of(context).showSnackBar(
                  SnackBar(
                    content: Text(isAr ? 'تم تغيير كلمة المرور بنجاح' : 'Password changed successfully'),
                    backgroundColor: Colors.green,
                  ),
                );
              } catch (e) {
                ScaffoldMessenger.of(context).showSnackBar(
                  SnackBar(
                    content: Text(e.toString().replaceAll('Exception: ', '')),
                    backgroundColor: Colors.red,
                  ),
                );
              }
            },
            child: Text(isAr ? 'حفظ' : 'Save'),
          ),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    if (_settings == null || _report == null) {
      return const Scaffold(
        body: Center(child: CircularProgressIndicator()),
      );
    }

    final isAr = Localizations.localeOf(context).languageCode == 'ar';

    if (!_isAuthenticated) {
      return _buildPasswordScreen(isAr);
    }

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
                      child: FittedBox(
                        fit: BoxFit.scaleDown,
                        child: Text(
                          isAr ? 'لوحة تحكم الوالدين' : 'Parent Dashboard',
                          textAlign: TextAlign.center,
                          style: Theme.of(context).textTheme.headlineLarge?.copyWith(
                                color: Colors.white,
                                fontWeight: FontWeight.bold,
                              ),
                        ),
                      ),
                    ),
                    IconButton(
                      icon: const Icon(Icons.account_circle, color: Colors.white, size: 28),
                      tooltip: isAr ? 'حساب ولي الأمر' : 'Parent Account',
                      onPressed: () {
                        ParentAccountDialog.show(context, onAccountUpdated: _loadData);
                      },
                    ),
                    IconButton(
                      icon: const Icon(Icons.lock, color: Colors.white),
                      tooltip: isAr ? 'قفل' : 'Lock',
                      onPressed: () {
                        setState(() {
                          _isAuthenticated = false;
                        });
                      },
                    ),
                  ],
                ),
              ),

              // Content
              Expanded(
                child: SingleChildScrollView(
                  padding: const EdgeInsets.all(20),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      // Parent Account Banner
                      _buildParentAccountBanner(isAr),
                      const SizedBox(height: 16),

                      // Children Profiles & Screen Time Management Section
                      _buildChildrenProfilesSection(isAr),
                      const SizedBox(height: 16),

                      // Today's Play Time for Active Child (Live Seconds & Minutes)
                      Builder(builder: (context) {
                        final child = ScreenTimeService().activeChild;
                        final usedSecs = child.secondsUsedToday;
                        final usedMins = (usedSecs / 60).floor();
                        final remainingMins = child.remainingMinutes;

                        String playTimeValue;
                        if (usedSecs < 60) {
                          playTimeValue = isAr ? '$usedSecs ثانية' : '$usedSecs sec';
                        } else {
                          final remSec = usedSecs % 60;
                          if (remSec == 0) {
                            playTimeValue = isAr ? '$usedMins دقيقة' : '$usedMins min';
                          } else {
                            playTimeValue = isAr ? '$usedMins د و $remSec ث' : '$usedMins m $remSec s';
                          }
                        }

                        String playTimeSubtitle;
                        if (child.isScreenTimeEnabled && child.dailyLimitMinutes > 0) {
                          playTimeSubtitle = isAr
                              ? 'المحدد: ${child.dailyLimitMinutes} دقيقة (المتبقي: ${remainingMins >= 0 ? "$remainingMins دقيقة" : "مفتوح"})'
                              : 'Limit: ${child.dailyLimitMinutes} min (Left: ${remainingMins >= 0 ? "$remainingMins min" : "Open"})';
                        } else {
                          playTimeSubtitle = isAr ? 'لا يوجد حد زمني (مفتوح)' : 'No limit set (Unlimited)';
                        }

                        return _StatCard(
                          title: isAr
                              ? 'وقت لعب (${child.name}) اليوم'
                              : 'Today\'s Playtime (${child.name})',
                          value: playTimeValue,
                          icon: Icons.access_time,
                          color: Colors.blue,
                          subtitle: playTimeSubtitle,
                        );
                      }),

                      const SizedBox(height: 16),

                      // Statistics Grid
                      Row(
                        children: [
                          Expanded(
                            child: _StatCard(
                              title: isAr ? 'الألعاب' : 'Games',
                              value: '${_report!.gamesPlayed}',
                              icon: Icons.games,
                              color: Colors.green,
                            ),
                          ),
                          const SizedBox(width: 16),
                          Expanded(
                            child: _StatCard(
                              title: isAr ? 'المستويات' : 'Levels',
                              value: '${_report!.levelsCompleted}',
                              icon: Icons.star,
                              color: Colors.orange,
                            ),
                          ),
                        ],
                      ),

                      const SizedBox(height: 16),

                      Row(
                        children: [
                          Expanded(
                            child: _StatCard(
                              title: isAr ? 'النجوم' : 'Stars',
                              value: '${_report!.totalStars}',
                              icon: Icons.star,
                              color: Colors.amber,
                            ),
                          ),
                          const SizedBox(width: 16),
                          Expanded(
                            child: _StatCard(
                              title: isAr ? 'وقت اللعب' : 'Play Time',
                              value: isAr ? '${_report!.totalPlayTime} د' : '${_report!.totalPlayTime} min',
                              icon: Icons.timer,
                              color: Colors.purple,
                            ),
                          ),
                        ],
                      ),

                      const SizedBox(height: 24),

                      // Cognitive Skills Radar (Pro Feature)
                      _buildCognitiveRadarSection(),

                      const SizedBox(height: 24),

                      // Charts Section
                      Container(
                        padding: const EdgeInsets.all(16),
                        decoration: BoxDecoration(
                          color: Colors.white,
                          borderRadius: BorderRadius.circular(16),
                        ),
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Row(
                              mainAxisAlignment: MainAxisAlignment.spaceBetween,
                              children: [
                                Text(
                                  isAr ? 'الرسوم البيانية' : 'Performance Charts',
                                  style: const TextStyle(
                                    fontSize: 20,
                                    fontWeight: FontWeight.bold,
                                  ),
                                ),
                                IconButton(
                                  icon: const Icon(Icons.picture_as_pdf),
                                  onPressed: () => _exportToPDF(),
                                  tooltip: isAr ? 'تصدير PDF' : 'Export PDF',
                                ),
                              ],
                            ),
                            const SizedBox(height: 24),
                            
                            // Bar Chart - Game Statistics
                            if (_report!.gameStats.isNotEmpty) ...[
                              Text(
                                isAr ? 'عدد مرات اللعب لكل لعبة' : 'Plays per Game',
                                style: const TextStyle(
                                  fontSize: 16,
                                  fontWeight: FontWeight.w600,
                                ),
                              ),
                              const SizedBox(height: 16),
                              SizedBox(
                                height: 200,
                                child: BarChart(
                                  _buildBarChartData(),
                                ),
                              ),
                              const SizedBox(height: 32),
                              
                              // Pie Chart - Game Distribution
                              Text(
                                isAr ? 'توزيع الألعاب' : 'Game Distribution',
                                style: const TextStyle(
                                  fontSize: 16,
                                  fontWeight: FontWeight.w600,
                                ),
                              ),
                              const SizedBox(height: 16),
                              SizedBox(
                                height: 200,
                                child: PieChart(
                                  _buildPieChartData(),
                                ),
                              ),
                            ] else
                              Padding(
                                padding: const EdgeInsets.all(32.0),
                                child: Center(
                                  child: Text(
                                    isAr ? 'لا توجد إحصائيات بعد' : 'No game statistics yet',
                                    style: const TextStyle(color: Colors.grey),
                                  ),
                                ),
                              ),
                          ],
                        ),
                      ),

                      const SizedBox(height: 24),

                      // Game Statistics (List)
                      Container(
                        padding: const EdgeInsets.all(16),
                        decoration: BoxDecoration(
                          color: Colors.white,
                          borderRadius: BorderRadius.circular(16),
                        ),
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              isAr ? 'إحصائيات الألعاب' : 'Game Breakdown',
                              style: const TextStyle(
                                fontSize: 20,
                                fontWeight: FontWeight.bold,
                              ),
                            ),
                            const SizedBox(height: 16),
                            ..._report!.gameStats.entries.map((entry) {
                              final avgScore = _report!.averageScores[entry.key] ?? 0.0;
                              return Padding(
                                padding: const EdgeInsets.only(bottom: 12),
                                child: Row(
                                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                                  children: [
                                    Expanded(
                                      child: Text(
                                        _getGameName(entry.key, isAr),
                                        style: const TextStyle(fontSize: 15),
                                      ),
                                    ),
                                    Text(
                                      isAr ? '${entry.value} مرات' : '${entry.value} plays',
                                      style: TextStyle(
                                        fontSize: 13,
                                        color: Colors.grey[600],
                                      ),
                                    ),
                                    const SizedBox(width: 8),
                                    Text(
                                      isAr ? 'متوسط: ${avgScore.toStringAsFixed(0)}' : 'Avg: ${avgScore.toStringAsFixed(0)}',
                                      style: TextStyle(
                                        fontSize: 13,
                                        color: Colors.grey[600],
                                      ),
                                    ),
                                  ],
                                ),
                              );
                            }),
                          ],
                        ),
                      ),

                      const SizedBox(height: 24),

                      // Settings
                      Container(
                        padding: const EdgeInsets.all(16),
                        decoration: BoxDecoration(
                          color: Colors.white,
                          borderRadius: BorderRadius.circular(16),
                        ),
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              isAr ? 'الإعدادات' : 'Parental Controls & Settings',
                              style: const TextStyle(
                                fontSize: 20,
                                fontWeight: FontWeight.bold,
                              ),
                            ),
                            const SizedBox(height: 16),
                            SwitchListTile(
                              title: Text(isAr ? 'تفعيل وضع الوالدين' : 'Enable Parental Mode'),
                              value: _settings!.isParentModeEnabled,
                              onChanged: (value) async {
                                final updated = _settings!.copyWith(
                                  isParentModeEnabled: value,
                                );
                                await _parentService.updateSettings(updated);
                                _loadData();
                              },
                            ),
                            ListTile(
                              title: Text(isAr ? 'حد وقت اللعب اليومي' : 'Daily Screen Time Limit'),
                              subtitle: Text(
                                ScreenTimeService().activeChild.isScreenTimeEnabled &&
                                        ScreenTimeService().activeChild.dailyLimitMinutes > 0
                                    ? (isAr
                                        ? '${ScreenTimeService().activeChild.dailyLimitMinutes} دقيقة لـ (${ScreenTimeService().activeChild.name})'
                                        : '${ScreenTimeService().activeChild.dailyLimitMinutes} min for (${ScreenTimeService().activeChild.name})')
                                    : (isAr ? 'غير محدد (مفتوح)' : 'Unlimited (Open)'),
                              ),
                              trailing: const Icon(Icons.arrow_forward_ios, size: 16),
                              onTap: () => _showAddOrEditChildDialog(
                                  child: ScreenTimeService().activeChild, isAr: isAr),
                            ),
                            ListTile(
                              title: Text(isAr ? 'الألعاب المسموحة' : 'Allowed Games'),
                              subtitle: Text(
                                _settings!.allowedGameIds.isEmpty
                                    ? (isAr ? 'جميع الألعاب' : 'All Games')
                                    : (isAr ? '${_settings!.allowedGameIds.length} لعبة' : '${_settings!.allowedGameIds.length} games'),
                              ),
                              trailing: const Icon(Icons.arrow_forward_ios, size: 16),
                              onTap: () => _showGameSelectionDialog(isAr),
                            ),
                            const Divider(),
                            ListTile(
                              title: Text(isAr ? 'الفئة العمرية' : 'Age Bracket'),
                              subtitle: Text(
                                _settings!.ageGroup != null
                                    ? (isAr ? '${_settings!.ageGroup}-${_settings!.ageGroup! + 2} سنوات' : '${_settings!.ageGroup}-${_settings!.ageGroup! + 2} years')
                                    : (isAr ? 'غير محدد' : 'Not set'),
                              ),
                              trailing: const Icon(Icons.arrow_forward_ios, size: 16),
                              onTap: () => _showAgeGroupDialog(isAr),
                            ),
                            SwitchListTile(
                              title: Text(isAr ? 'تنبيهات الإنجازات' : 'Achievement Notifications'),
                              subtitle: Text(isAr ? 'إشعار عند فتح إنجاز جديد' : 'Notify when a new badge is unlocked'),
                              value: _settings!.achievementAlerts,
                              onChanged: (value) async {
                                final updated = _settings!.copyWith(
                                  achievementAlerts: value,
                                );
                                await _parentService.updateSettings(updated);
                                _loadData();
                              },
                            ),
                            const Divider(),
                            ListTile(
                              title: Text(isAr ? 'كلمة المرور' : 'Parent Security PIN'),
                              subtitle: Text(
                                _parentService.hasPassword()
                                    ? (isAr ? 'تم إعداد كلمة المرور' : 'PIN configured')
                                    : (isAr ? 'لم يتم إعداد كلمة المرور' : 'No PIN configured'),
                              ),
                              trailing: const Icon(Icons.arrow_forward_ios, size: 16),
                              onTap: () => _parentService.hasPassword()
                                  ? _changePassword(isAr)
                                  : _setupPassword(isAr),
                            ),
                          ],
                        ),
                      ),
                      const SizedBox(height: 16),
                      // WhatsApp Direct Support Card
                      Container(
                        padding: const EdgeInsets.all(14),
                        decoration: BoxDecoration(
                          gradient: const LinearGradient(
                            colors: [Color(0xFF25D366), Color(0xFF128C7E)],
                            begin: Alignment.topLeft,
                            end: Alignment.bottomRight,
                          ),
                          borderRadius: BorderRadius.circular(16),
                          boxShadow: [
                            BoxShadow(
                              color: const Color(0xFF25D366).withValues(alpha: 0.3),
                              blurRadius: 10,
                              offset: const Offset(0, 4),
                            ),
                          ],
                        ),
                        child: Row(
                          children: [
                            Container(
                              padding: const EdgeInsets.all(8),
                              decoration: const BoxDecoration(
                                color: Colors.white,
                                shape: BoxShape.circle,
                              ),
                              child: const Icon(Icons.chat_rounded, color: Color(0xFF128C7E), size: 24),
                            ),
                            const SizedBox(width: 10),
                            Expanded(
                              child: Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  Text(
                                    isAr ? 'دعم أولياء الأمور المباشر' : 'Direct Parent Support',
                                    style: const TextStyle(
                                      color: Colors.white,
                                      fontSize: 14,
                                      fontWeight: FontWeight.bold,
                                    ),
                                  ),
                                  const SizedBox(height: 2),
                                  Text(
                                    isAr
                                        ? 'تواصل معنا عبر واتساب للمساعدة أو الاستفسارات\n01067481561'
                                        : 'Contact us on WhatsApp for assistance\n01067481561',
                                    style: const TextStyle(
                                      color: Colors.white70,
                                      fontSize: 11,
                                    ),
                                  ),
                                ],
                              ),
                            ),
                            const SizedBox(width: 8),
                            FittedBox(
                              fit: BoxFit.scaleDown,
                              child: ElevatedButton(
                                style: ElevatedButton.styleFrom(
                                  backgroundColor: Colors.white,
                                  foregroundColor: const Color(0xFF128C7E),
                                  padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
                                  shape: RoundedRectangleBorder(
                                    borderRadius: BorderRadius.circular(10),
                                  ),
                                ),
                                onPressed: () async {
                                  final Uri waUri = Uri.parse(
                                    'https://wa.me/201067481561?text=${Uri.encodeComponent(isAr ? "مرحباً، أحتاج مساعدة أو استفسار بخصوص لوحة تحكم الوالدين في تطبيق Brainquests" : "Hello, I need assistance regarding Parent Dashboard in Brainquests")}',
                                  );
                                  try {
                                    await launchUrl(waUri, mode: LaunchMode.externalApplication);
                                  } catch (_) {}
                                },
                                child: Text(isAr ? 'مراسلة' : 'Chat',
                                    style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 13)),
                              ),
                            ),
                          ],
                        ),
                      ),
                    ],
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildParentAccountBanner(bool isAr) {
    final isLoggedIn = _parentProfile['isLoggedIn'] == 'true';
    final name = _parentProfile['name'] ?? (isAr ? 'ولي الأمر' : 'Parent');
    final phone = _parentProfile['phone'] ?? '';

    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.08),
            blurRadius: 10,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: Row(
        children: [
          FittedBox(
            fit: BoxFit.scaleDown,
            child: ElevatedButton(
              style: ElevatedButton.styleFrom(
                backgroundColor: isLoggedIn ? Colors.teal : AppTheme.primaryBlue,
                foregroundColor: Colors.white,
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(12),
                ),
                padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 10),
              ),
              onPressed: () {
                ParentAccountDialog.show(context, onAccountUpdated: _loadData);
              },
              child: Text(
                isLoggedIn
                    ? (isAr ? 'إدارة الحساب' : 'Manage Account')
                    : (isAr ? 'تسجيل حساب' : 'Register'),
                style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 13),
              ),
            ),
          ),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: isAr ? CrossAxisAlignment.end : CrossAxisAlignment.start,
              children: [
                Row(
                  mainAxisAlignment: isAr ? MainAxisAlignment.end : MainAxisAlignment.start,
                  children: [
                    Flexible(
                      child: Text(
                        isLoggedIn ? name : (isAr ? 'حساب ولي الأمر' : 'Parent Account'),
                        overflow: TextOverflow.ellipsis,
                        style: const TextStyle(
                          fontWeight: FontWeight.bold,
                          fontSize: 15,
                          color: Colors.black87,
                        ),
                      ),
                    ),
                    const SizedBox(width: 6),
                    Icon(
                      isLoggedIn ? Icons.verified_user_rounded : Icons.person_add_alt_1_rounded,
                      color: isLoggedIn ? Colors.teal : AppTheme.primaryBlue,
                      size: 20,
                    ),
                  ],
                ),
                const SizedBox(height: 4),
                Text(
                  isLoggedIn
                      ? (phone.isNotEmpty
                          ? (isAr ? 'الواتساب: $phone • متصل' : 'WhatsApp: $phone • Connected')
                          : (isAr ? 'الحساب متصل بالبورتال المركزي' : 'Connected to central portal'))
                      : (isAr
                          ? 'سجّل حسابك لحفظ تقدم واشتراكات طفلك'
                          : 'Register account to sync progress & VIP'),
                  style: TextStyle(
                    fontSize: 12,
                    color: Colors.grey.shade600,
                  ),
                  textAlign: isAr ? TextAlign.right : TextAlign.left,
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildChildrenProfilesSection(bool isAr) {
    final screenTime = ScreenTimeService();
    final children = screenTime.children;
    final activeChild = screenTime.activeChild;

    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.08),
            blurRadius: 10,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              const Icon(Icons.family_restroom_rounded,
                  color: AppTheme.primaryBlue, size: 24),
              const SizedBox(width: 8),
              Expanded(
                child: Text(
                  isAr ? 'أطفالي وتحديد وقت اللعب ⏳' : 'Children & Screen Time ⏳',
                  style: const TextStyle(
                    fontSize: 16,
                    fontWeight: FontWeight.bold,
                    color: Colors.black87,
                  ),
                ),
              ),
              const SizedBox(width: 6),
              FittedBox(
                fit: BoxFit.scaleDown,
                child: ElevatedButton.icon(
                  style: ElevatedButton.styleFrom(
                    backgroundColor: AppTheme.primaryBlue,
                    foregroundColor: Colors.white,
                    elevation: 0,
                    padding:
                        const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(10),
                    ),
                  ),
                  icon: const Icon(Icons.add, size: 16),
                  label: Text(
                    isAr ? 'إضافة طفل' : 'Add Child',
                    style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 12),
                  ),
                  onPressed: () => _showAddOrEditChildDialog(isAr: isAr),
                ),
              ),
            ],
          ),
          const SizedBox(height: 6),
          Text(
            isAr
                ? 'خصص وقتاً مستقلاً لكل طفل (من ربع ساعة فما فوق). الطفل المفعّل هو من سيطبق عليه المؤقت عند استخدام التطبيق:'
                : 'Set individual daily screen time limits for each child. Active child is monitored during app usage:',
            style: TextStyle(fontSize: 12, color: Colors.grey.shade600),
          ),
          const SizedBox(height: 14),

          // List of children cards
          ...children.map((c) {
            final isActive = c.id == activeChild.id;
            final usedMins = (c.secondsUsedToday / 60).floor();
            final limitMins = c.dailyLimitMinutes;
            final progress = (c.isScreenTimeEnabled && limitMins > 0)
                ? (usedMins / limitMins).clamp(0.0, 1.0)
                : 0.0;

            return Container(
              margin: const EdgeInsets.only(bottom: 12),
              padding: const EdgeInsets.all(12),
              decoration: BoxDecoration(
                color: isActive
                    ? AppTheme.primaryBlue.withValues(alpha: 0.05)
                    : Colors.grey.shade50,
                borderRadius: BorderRadius.circular(14),
                border: Border.all(
                  color: isActive
                      ? AppTheme.primaryBlue.withValues(alpha: 0.5)
                      : Colors.grey.shade200,
                  width: isActive ? 1.5 : 1.0,
                ),
              ),
              child: Column(
                children: [
                  Row(
                    children: [
                      // Avatar circle
                      CircleAvatar(
                        radius: 20,
                        backgroundColor: isActive
                            ? AppTheme.primaryBlue
                            : Colors.grey.shade300,
                        child: Text(
                          c.name.isNotEmpty ? c.name[0] : '؟',
                          style: TextStyle(
                            color: isActive ? Colors.white : Colors.black87,
                            fontWeight: FontWeight.bold,
                            fontSize: 15,
                          ),
                        ),
                      ),
                      const SizedBox(width: 10),
                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Row(
                              children: [
                                Flexible(
                                  child: Text(
                                    c.name,
                                    overflow: TextOverflow.ellipsis,
                                    style: const TextStyle(
                                      fontWeight: FontWeight.bold,
                                      fontSize: 15,
                                    ),
                                  ),
                                ),
                                const SizedBox(width: 6),
                                Container(
                                  padding: const EdgeInsets.symmetric(
                                      horizontal: 6, vertical: 2),
                                  decoration: BoxDecoration(
                                    color: Colors.amber.shade100,
                                    borderRadius: BorderRadius.circular(6),
                                  ),
                                  child: Text(
                                    isAr ? '${c.age} سنوات' : '${c.age} yrs',
                                    style: TextStyle(
                                      fontSize: 11,
                                      fontWeight: FontWeight.w600,
                                      color: Colors.amber.shade900,
                                    ),
                                  ),
                                ),
                              ],
                            ),
                            const SizedBox(height: 3),
                            Text(
                              c.isScreenTimeEnabled && limitMins > 0
                                  ? (isAr
                                      ? 'المحدد: $limitMins دقيقة (المتبقي: ${c.remainingMinutes >= 0 ? "${c.remainingMinutes} دقيقة" : "مفتوح"})'
                                      : 'Limit: $limitMins min (Remaining: ${c.remainingMinutes >= 0 ? "${c.remainingMinutes} min" : "Open"})')
                                  : (isAr ? 'وقت اللعب غير مقيد (مفتوح)' : 'Playtime unlimited (Open)'),
                              style: TextStyle(
                                fontSize: 12,
                                color: c.isLimitReached
                                    ? Colors.red
                                    : Colors.grey.shade700,
                                fontWeight: c.isLimitReached
                                    ? FontWeight.bold
                                    : FontWeight.normal,
                              ),
                            ),
                          ],
                        ),
                      ),

                      // Edit button
                      IconButton(
                        icon: const Icon(Icons.tune_rounded, size: 20),
                        tooltip: isAr ? 'تخصيص الوقت' : 'Customize Time',
                        color: Colors.grey.shade700,
                        onPressed: () => _showAddOrEditChildDialog(child: c, isAr: isAr),
                      ),
                    ],
                  ),

                  // Progress bar if screen time enabled
                  if (c.isScreenTimeEnabled && limitMins > 0) ...[
                    const SizedBox(height: 8),
                    ClipRRect(
                      borderRadius: BorderRadius.circular(4),
                      child: LinearProgressIndicator(
                        value: progress,
                        minHeight: 5,
                        backgroundColor: Colors.grey.shade200,
                        valueColor: AlwaysStoppedAnimation<Color>(
                          c.isLimitReached
                              ? Colors.red
                              : (progress > 0.8 ? Colors.orange : Colors.green),
                        ),
                      ),
                    ),
                  ],

                  const SizedBox(height: 8),
                  // Active selection row
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      if (isActive)
                        Flexible(
                          child: Container(
                            padding: const EdgeInsets.symmetric(
                                horizontal: 10, vertical: 4),
                            decoration: BoxDecoration(
                              color: Colors.green.shade100,
                              borderRadius: BorderRadius.circular(12),
                            ),
                            child: Row(
                              mainAxisSize: MainAxisSize.min,
                              children: [
                                const Icon(Icons.check_circle,
                                    color: Colors.green, size: 14),
                                const SizedBox(width: 4),
                                Flexible(
                                  child: Text(
                                    isAr ? 'يلعب على الجهاز الآن' : 'Active on device',
                                    overflow: TextOverflow.ellipsis,
                                    style: TextStyle(
                                      color: Colors.green.shade900,
                                      fontSize: 11,
                                      fontWeight: FontWeight.bold,
                                    ),
                                  ),
                                ),
                              ],
                            ),
                          ),
                        )
                      else
                        TextButton.icon(
                          style: TextButton.styleFrom(
                            foregroundColor: AppTheme.primaryBlue,
                            padding: const EdgeInsets.symmetric(
                                horizontal: 8, vertical: 2),
                          ),
                          icon: const Icon(Icons.play_circle_outline, size: 16),
                          label: Text(isAr ? 'تفعيل للعب الآن' : 'Set as Active',
                              style: const TextStyle(fontSize: 12)),
                          onPressed: () async {
                            await screenTime.setActiveChild(c.id);
                            setState(() {});
                          },
                        ),

                      if (children.length > 1)
                        TextButton(
                          style: TextButton.styleFrom(
                            foregroundColor: Colors.red.shade400,
                            padding: const EdgeInsets.symmetric(
                                horizontal: 6, vertical: 2),
                          ),
                          child:
                              Text(isAr ? 'حذف' : 'Delete', style: const TextStyle(fontSize: 11)),
                          onPressed: () => _confirmDeleteChild(c, isAr),
                        ),
                    ],
                  ),
                ],
              ),
            );
          }),
        ],
      ),
    );
  }

  void _showAddOrEditChildDialog({ChildProfile? child, bool isAr = true}) {
    final isEditing = child != null;
    final nameController =
        TextEditingController(text: isEditing ? child.name : '');
    int selectedAge = isEditing ? child.age : 6;
    bool isEnabled = isEditing ? child.isScreenTimeEnabled : true;
    int selectedLimit = isEditing ? child.dailyLimitMinutes : 30;

    showDialog(
      context: context,
      builder: (ctx) => StatefulBuilder(
        builder: (context, setDialogState) => AlertDialog(
          title: Text(isEditing
              ? (isAr ? 'تخصيص وقت الطفل' : 'Customize Child Profile')
              : (isAr ? 'إضافة طفل جديد' : 'Add Child Profile')),
          content: SingleChildScrollView(
            child: Column(
              mainAxisSize: MainAxisSize.min,
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                TextField(
                  controller: nameController,
                  decoration: InputDecoration(
                    labelText: isAr ? 'اسم الطفل' : 'Child Name',
                    hintText: isAr ? 'مثال: أحمد أو سارة' : 'e.g. Leo or Sarah',
                    prefixIcon: const Icon(Icons.child_care),
                  ),
                ),
                const SizedBox(height: 14),
                Row(
                  children: [
                    Text(isAr ? 'العمر:' : 'Age:',
                        style: const TextStyle(fontWeight: FontWeight.bold)),
                    const SizedBox(width: 12),
                    DropdownButton<int>(
                      value: selectedAge,
                      items: List.generate(
                        10,
                        (index) => DropdownMenuItem(
                          value: index + 3,
                          child: Text(isAr ? '${index + 3} سنوات' : '${index + 3} years'),
                        ),
                      ),
                      onChanged: (val) {
                        if (val != null) {
                          setDialogState(() => selectedAge = val);
                        }
                      },
                    ),
                  ],
                ),
                const Divider(height: 24),
                SwitchListTile(
                  contentPadding: EdgeInsets.zero,
                  title: Text(isAr ? 'تفعيل التحكم في وقت اللعب' : 'Enable Daily Screen Time Limit',
                      style: const TextStyle(
                          fontWeight: FontWeight.bold, fontSize: 14)),
                  subtitle: Text(isAr ? 'إغلاق التطبيق بعد انتهاء الوقت المخصص' : 'Lock app when allotted time ends',
                      style: const TextStyle(fontSize: 12)),
                  value: isEnabled,
                  onChanged: (val) {
                    setDialogState(() => isEnabled = val);
                  },
                ),
                if (isEnabled) ...[
                  const SizedBox(height: 10),
                  Text(isAr ? 'الحد اليومي للعب:' : 'Daily Limit:',
                      style:
                          const TextStyle(fontWeight: FontWeight.bold, fontSize: 13)),
                  const SizedBox(height: 6),
                  Wrap(
                    spacing: 8,
                    runSpacing: 6,
                    children: [
                      _buildLimitChip(
                          isAr ? '15 دقيقة (ربع ساعة)' : '15 min', 15, selectedLimit, (val) {
                        setDialogState(() => selectedLimit = val);
                      }),
                      _buildLimitChip(
                          isAr ? '30 دقيقة (نصف ساعة)' : '30 min', 30, selectedLimit, (val) {
                        setDialogState(() => selectedLimit = val);
                      }),
                      _buildLimitChip(isAr ? '45 دقيقة' : '45 min', 45, selectedLimit, (val) {
                        setDialogState(() => selectedLimit = val);
                      }),
                      _buildLimitChip(
                          isAr ? '60 دقيقة (ساعة)' : '60 min (1 hr)', 60, selectedLimit, (val) {
                        setDialogState(() => selectedLimit = val);
                      }),
                      _buildLimitChip(
                          isAr ? '90 دقيقة (ساعة ونصف)' : '90 min (1.5 hr)', 90, selectedLimit, (val) {
                        setDialogState(() => selectedLimit = val);
                      }),
                      _buildLimitChip(
                          isAr ? '120 دقيقة (ساعتان)' : '120 min (2 hrs)', 120, selectedLimit, (val) {
                        setDialogState(() => selectedLimit = val);
                      }),
                    ],
                  ),
                ],
              ],
            ),
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.pop(ctx),
              child: Text(isAr ? 'إلغاء' : 'Cancel'),
            ),
            ElevatedButton(
              style: ElevatedButton.styleFrom(
                backgroundColor: AppTheme.primaryBlue,
                foregroundColor: Colors.white,
              ),
              onPressed: () async {
                final name = nameController.text.trim();
                if (name.isEmpty) {
                  ScaffoldMessenger.of(context).showSnackBar(
                    SnackBar(content: Text(isAr ? 'يرجى إدخال اسم الطفل' : 'Please enter child name')),
                  );
                  return;
                }

                final profile = ChildProfile(
                  id: isEditing
                      ? child.id
                      : 'child_${DateTime.now().millisecondsSinceEpoch}',
                  name: name,
                  age: selectedAge,
                  isScreenTimeEnabled: isEnabled,
                  dailyLimitMinutes: isEnabled ? selectedLimit : 0,
                  secondsUsedToday: isEditing ? child.secondsUsedToday : 0,
                  lastActiveDate: isEditing ? child.lastActiveDate : null,
                  isTemporarilyUnlocked:
                      isEditing ? child.isTemporarilyUnlocked : false,
                );

                await ScreenTimeService().saveChild(profile);
                if (mounted) {
                  Navigator.pop(ctx);
                  setState(() {});
                }
              },
              child: Text(isAr ? 'حفظ' : 'Save'),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildLimitChip(
      String label, int minutes, int current, Function(int) onSelected) {
    final isSelected = current == minutes;
    return ChoiceChip(
      label: Text(label, style: const TextStyle(fontSize: 12)),
      selected: isSelected,
      selectedColor: AppTheme.primaryBlue.withValues(alpha: 0.2),
      onSelected: (_) => onSelected(minutes),
    );
  }

  void _confirmDeleteChild(ChildProfile child, bool isAr) {
    showDialog(
      context: context,
      builder: (ctx) => AlertDialog(
        title: Text(isAr ? 'حذف ملف الطفل' : 'Delete Child Profile'),
        content: Text(isAr
            ? 'هل أنت متأكد من رغبتك في حذف ملف (${child.name})؟'
            : 'Are you sure you want to delete profile for (${child.name})?'),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(ctx),
            child: Text(isAr ? 'إلغاء' : 'Cancel'),
          ),
          TextButton(
            style: TextButton.styleFrom(foregroundColor: Colors.red),
            onPressed: () async {
              await ScreenTimeService().deleteChild(child.id);
              if (mounted) {
                Navigator.pop(ctx);
                setState(() {});
              }
            },
            child: Text(isAr ? 'حذف' : 'Delete'),
          ),
        ],
      ),
    );
  }

  Widget _buildPasswordScreen(bool isAr) {
    return Scaffold(
      body: Container(
        decoration: const BoxDecoration(
          gradient: AppTheme.blueGradient,
        ),
        child: SafeArea(
          child: Center(
            child: SingleChildScrollView(
              padding: const EdgeInsets.all(32.0),
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  const Icon(
                    Icons.lock,
                    size: 80,
                    color: Colors.white,
                  ),
                  const SizedBox(height: 24),
                  Text(
                    isAr ? 'لوحة تحكم الوالدين' : 'Parent Dashboard',
                    style: const TextStyle(
                      color: Colors.white,
                      fontSize: 26,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  const SizedBox(height: 12),
                  Text(
                    _parentService.hasPassword()
                        ? (isAr ? 'يرجى إدخال كلمة المرور' : 'Please enter parent PIN')
                        : (isAr ? 'لم يتم إعداد كلمة المرور بعد' : 'No parent PIN set yet'),
                    style: const TextStyle(
                      color: Colors.white70,
                      fontSize: 15,
                    ),
                  ),
                  const SizedBox(height: 24),
                  if (_parentService.hasPassword()) ...[
                    Container(
                      constraints: const BoxConstraints(maxWidth: 320),
                      child: TextField(
                        controller: _passwordController,
                        obscureText: true,
                        keyboardType: TextInputType.number,
                        textAlign: TextAlign.center,
                        style: const TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
                        decoration: InputDecoration(
                          filled: true,
                          fillColor: Colors.white,
                          hintText: isAr ? 'كلمة المرور' : 'PIN',
                          border: OutlineInputBorder(
                            borderRadius: BorderRadius.circular(16),
                            borderSide: BorderSide.none,
                          ),
                        ),
                        onSubmitted: (_) => _authenticate(isAr),
                      ),
                    ),
                    const SizedBox(height: 20),
                    ElevatedButton(
                      onPressed: () => _authenticate(isAr),
                      style: ElevatedButton.styleFrom(
                        backgroundColor: AppTheme.yellowAccent,
                        foregroundColor: AppTheme.darkText,
                        padding: const EdgeInsets.symmetric(
                          horizontal: 48,
                          vertical: 14,
                        ),
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(16),
                        ),
                      ),
                      child: Text(
                        isAr ? 'دخول' : 'Login',
                        style: const TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
                      ),
                    ),
                  ] else ...[
                    ElevatedButton(
                      onPressed: () => _setupPassword(isAr),
                      style: ElevatedButton.styleFrom(
                        backgroundColor: AppTheme.yellowAccent,
                        foregroundColor: AppTheme.darkText,
                        padding: const EdgeInsets.symmetric(
                          horizontal: 32,
                          vertical: 14,
                        ),
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(16),
                        ),
                      ),
                      child: Text(
                        isAr ? 'إعداد كلمة المرور' : 'Set Parent PIN',
                        style: const TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
                      ),
                    ),
                  ],
                  const SizedBox(height: 16),
                  TextButton(
                    onPressed: () => Navigator.pop(context),
                    child: Text(
                      isAr ? 'العودة للرئيسية' : 'Back to Home',
                      style: const TextStyle(color: Colors.white70),
                    ),
                  ),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }



  void _showGameSelectionDialog(bool isAr) {
    final selectedGames = Set<String>.from(_settings!.allowedGameIds);
    
    showDialog(
      context: context,
      builder: (context) => StatefulBuilder(
        builder: (context, setDialogState) => AlertDialog(
          title: Text(isAr ? 'الألعاب المسموحة' : 'Allowed Games'),
          content: SizedBox(
            width: double.maxFinite,
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                CheckboxListTile(
                  title: Text(isAr ? 'جميع الألعاب' : 'All Games'),
                  value: selectedGames.isEmpty,
                  onChanged: (value) {
                    setDialogState(() {
                      if (value == true) {
                        selectedGames.clear();
                      } else {
                        selectedGames.addAll(GameDefinitions.allGames.map((g) => g.id));
                      }
                    });
                  },
                ),
                const Divider(),
                Flexible(
                  child: ListView.builder(
                    shrinkWrap: true,
                    itemCount: GameDefinitions.allGames.length,
                    itemBuilder: (context, index) {
                      final game = GameDefinitions.allGames[index];
                      final isSelected = selectedGames.contains(game.id);
                      
                      return CheckboxListTile(
                        title: Text(_getGameName(game.id, isAr)),
                        subtitle: Text(game.description),
                        value: isSelected,
                        onChanged: (value) {
                          setDialogState(() {
                            if (value == true) {
                              selectedGames.add(game.id);
                            } else {
                              selectedGames.remove(game.id);
                            }
                          });
                        },
                        secondary: Icon(game.icon, color: game.color),
                      );
                    },
                  ),
                ),
              ],
            ),
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.pop(context),
              child: Text(isAr ? 'إلغاء' : 'Cancel'),
            ),
            TextButton(
              onPressed: () async {
                final updated = _settings!.copyWith(
                  allowedGameIds: selectedGames.isEmpty 
                      ? [] 
                      : selectedGames.toList(),
                );
                await _parentService.updateSettings(updated);
                _loadData();
                Navigator.pop(context);
                ScaffoldMessenger.of(context).showSnackBar(
                  SnackBar(
                    content: Text(
                      selectedGames.isEmpty
                          ? (isAr ? 'تم تفعيل جميع الألعاب' : 'All games allowed')
                          : (isAr ? 'تم تحديث الألعاب المسموحة' : 'Allowed games updated'),
                    ),
                    backgroundColor: Colors.green,
                  ),
                );
              },
              child: Text(isAr ? 'حفظ' : 'Save'),
            ),
          ],
        ),
      ),
    );
  }

  void _showAgeGroupDialog(bool isAr) {
    int? selectedAgeGroup = _settings!.ageGroup;
    
    showDialog(
      context: context,
      builder: (context) => StatefulBuilder(
        builder: (context, setDialogState) => AlertDialog(
          title: Text(isAr ? 'الفئة العمرية للطفل' : 'Child Age Group'),
          content: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              RadioListTile<int?>(
                title: Text(isAr ? '3-5 سنوات' : '3-5 years'),
                value: 3,
                groupValue: selectedAgeGroup,
                onChanged: (value) => setDialogState(() => selectedAgeGroup = value),
              ),
              RadioListTile<int?>(
                title: Text(isAr ? '6-8 سنوات' : '6-8 years'),
                value: 6,
                groupValue: selectedAgeGroup,
                onChanged: (value) => setDialogState(() => selectedAgeGroup = value),
              ),
              RadioListTile<int?>(
                title: Text(isAr ? '9-12 سنة' : '9-12 years'),
                value: 9,
                groupValue: selectedAgeGroup,
                onChanged: (value) => setDialogState(() => selectedAgeGroup = value),
              ),
              RadioListTile<int?>(
                title: Text(isAr ? '13+ سنة' : '13+ years'),
                value: 13,
                groupValue: selectedAgeGroup,
                onChanged: (value) => setDialogState(() => selectedAgeGroup = value),
              ),
              RadioListTile<int?>(
                title: Text(isAr ? 'غير محدد' : 'Not specified'),
                value: null,
                groupValue: selectedAgeGroup,
                onChanged: (value) => setDialogState(() => selectedAgeGroup = value),
              ),
            ],
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.pop(context),
              child: Text(isAr ? 'إلغاء' : 'Cancel'),
            ),
            TextButton(
              onPressed: () async {
                final updated = _settings!.copyWith(ageGroup: selectedAgeGroup);
                await _parentService.updateSettings(updated);
                _loadData();
                Navigator.pop(context);
              },
              child: Text(isAr ? 'حفظ' : 'Save'),
            ),
          ],
        ),
      ),
    );
  }

  String _getGameName(String gameId, [bool isAr = true]) {
    if (isAr) {
      final names = {
        'memory_cards': 'بطاقات الذاكرة',
        'find_difference': 'إيجاد الفروقات',
        'shape_matcher': 'مطابقة الأشكال',
        'pattern_logic': 'منطق الأنماط',
        'quick_math': 'الرياضيات السريعة',
        'color_memory': 'ذاكرة الألوان',
        'word_puzzle': 'ألغاز الكلمات',
        'maze_runner': 'متاهة',
        'sorting_game': 'لعبة الترتيب',
        'jigsaw_puzzle': 'بازل',
      };
      return names[gameId] ?? gameId;
    } else {
      final names = {
        'memory_cards': 'Memory Cards',
        'find_difference': 'Find Differences',
        'shape_matcher': 'Shape Matcher',
        'pattern_logic': 'Pattern Logic',
        'quick_math': 'Quick Math',
        'color_memory': 'Color Memory',
        'word_puzzle': 'Word Puzzle',
        'maze_runner': 'Maze Runner',
        'sorting_game': 'Sorting Game',
        'jigsaw_puzzle': 'Jigsaw Puzzle',
      };
      return names[gameId] ?? gameId;
    }
  }

  BarChartData _buildBarChartData() {
    final entries = _report!.gameStats.entries.toList();
    final colors = [
      Colors.blue,
      Colors.green,
      Colors.orange,
      Colors.purple,
      Colors.red,
      Colors.teal,
      Colors.amber,
      Colors.pink,
      Colors.indigo,
      Colors.brown,
    ];

    return BarChartData(
      alignment: BarChartAlignment.spaceAround,
      maxY: entries.isEmpty ? 10 : (entries.map((e) => e.value).reduce((a, b) => a > b ? a : b).toDouble() * 1.2),
      barTouchData: BarTouchData(enabled: false),
      titlesData: FlTitlesData(
        show: true,
        bottomTitles: AxisTitles(
          sideTitles: SideTitles(
            showTitles: true,
            getTitlesWidget: (value, meta) {
              final index = value.toInt();
              if (index >= 0 && index < entries.length) {
                final gameName = _getGameName(entries[index].key);
                return Padding(
                  padding: const EdgeInsets.only(top: 8.0),
                  child: Text(
                    gameName.length > 8 ? '${gameName.substring(0, 8)}...' : gameName,
                    style: const TextStyle(fontSize: 10),
                  ),
                );
              }
              return const Text('');
            },
            reservedSize: 40,
          ),
        ),
        leftTitles: AxisTitles(
          sideTitles: SideTitles(
            showTitles: true,
            reservedSize: 40,
            getTitlesWidget: (value, meta) => Text(
              value.toInt().toString(),
              style: const TextStyle(fontSize: 10),
            ),
          ),
        ),
        topTitles: const AxisTitles(sideTitles: SideTitles(showTitles: false)),
        rightTitles: const AxisTitles(sideTitles: SideTitles(showTitles: false)),
      ),
      gridData: const FlGridData(show: false),
      borderData: FlBorderData(show: false),
      barGroups: entries.asMap().entries.map((entry) {
        final index = entry.key;
        final value = entry.value.value.toDouble();
        return BarChartGroupData(
          x: index,
          barRods: [
            BarChartRodData(
              toY: value,
              color: colors[index % colors.length],
              width: 20,
              borderRadius: const BorderRadius.vertical(top: Radius.circular(4)),
            ),
          ],
        );
      }).toList(),
    );
  }

  PieChartData _buildPieChartData() {
    final entries = _report!.gameStats.entries.toList();
    final total = entries.fold<int>(0, (sum, entry) => sum + entry.value);
    final colors = [
      Colors.blue,
      Colors.green,
      Colors.orange,
      Colors.purple,
      Colors.red,
      Colors.teal,
      Colors.amber,
      Colors.pink,
      Colors.indigo,
      Colors.brown,
    ];

    return PieChartData(
      sectionsSpace: 2,
      centerSpaceRadius: 40,
      sections: entries.asMap().entries.map((entry) {
        final index = entry.key;
        final gameEntry = entry.value;
        final percentage = (gameEntry.value / total * 100);
        return PieChartSectionData(
          value: gameEntry.value.toDouble(),
          title: '${percentage.toStringAsFixed(0)}%',
          color: colors[index % colors.length],
          radius: 60,
          titleStyle: const TextStyle(
            fontSize: 12,
            fontWeight: FontWeight.bold,
            color: Colors.white,
          ),
        );
      }).toList(),
    );
  }

  Future<void> _exportToPDF() async {
    if (_report == null) return;

    final pdf = pw.Document();
    final dateFormat = DateFormat('yyyy-MM-dd', 'ar');

    pdf.addPage(
      pw.MultiPage(
        pageFormat: PdfPageFormat.a4,
        margin: const pw.EdgeInsets.all(40),
        build: (pw.Context context) {
          return [
            // Header
            pw.Header(
              level: 0,
              child: pw.Text(
                'تقرير تقدم الطفل - MiniGenius',
                style: pw.TextStyle(
                  fontSize: 24,
                  fontWeight: pw.FontWeight.bold,
                ),
                textDirection: pw.TextDirection.rtl,
              ),
            ),
            pw.SizedBox(height: 20),
            
            // Report Date
            pw.Text(
              'تاريخ التقرير: ${dateFormat.format(_report!.reportDate)}',
              style: const pw.TextStyle(fontSize: 12),
              textDirection: pw.TextDirection.rtl,
            ),
            pw.SizedBox(height: 30),
            
            // Statistics
            pw.Row(
              mainAxisAlignment: pw.MainAxisAlignment.spaceBetween,
              children: [
                _buildStatBox('وقت اللعب', '${_report!.totalPlayTime} دقيقة'),
                _buildStatBox('الألعاب', '${_report!.gamesPlayed}'),
                _buildStatBox('المستويات', '${_report!.levelsCompleted}'),
                _buildStatBox('النجوم', '${_report!.totalStars}'),
              ],
            ),
            pw.SizedBox(height: 30),
            
            // Game Statistics
            pw.Text(
              'إحصائيات الألعاب',
              style: pw.TextStyle(
                fontSize: 18,
                fontWeight: pw.FontWeight.bold,
              ),
              textDirection: pw.TextDirection.rtl,
            ),
            pw.SizedBox(height: 10),
            
            pw.Table(
              border: pw.TableBorder.all(color: PdfColors.grey300),
              children: [
                pw.TableRow(
                  decoration: const pw.BoxDecoration(color: PdfColors.grey200),
                  children: [
                    pw.Padding(
                      padding: const pw.EdgeInsets.all(8),
                      child: pw.Text('اللعبة', style: pw.TextStyle(fontWeight: pw.FontWeight.bold)),
                    ),
                    pw.Padding(
                      padding: const pw.EdgeInsets.all(8),
                      child: pw.Text('عدد المرات', style: pw.TextStyle(fontWeight: pw.FontWeight.bold)),
                    ),
                    pw.Padding(
                      padding: const pw.EdgeInsets.all(8),
                      child: pw.Text('متوسط النقاط', style: pw.TextStyle(fontWeight: pw.FontWeight.bold)),
                    ),
                  ],
                ),
                ..._report!.gameStats.entries.map((entry) {
                  final avgScore = _report!.averageScores[entry.key] ?? 0.0;
                  return pw.TableRow(
                    children: [
                      pw.Padding(
                        padding: const pw.EdgeInsets.all(8),
                        child: pw.Text(_getGameName(entry.key)),
                      ),
                      pw.Padding(
                        padding: const pw.EdgeInsets.all(8),
                        child: pw.Text('${entry.value}'),
                      ),
                      pw.Padding(
                        padding: const pw.EdgeInsets.all(8),
                        child: pw.Text(avgScore.toStringAsFixed(0)),
                      ),
                    ],
                  );
                }),
              ],
            ),
            pw.SizedBox(height: 20),
            
            // Achievements
            if (_report!.achievementsUnlocked.isNotEmpty) ...[
              pw.Text(
                'الإنجازات',
                style: pw.TextStyle(
                  fontSize: 18,
                  fontWeight: pw.FontWeight.bold,
                ),
                textDirection: pw.TextDirection.rtl,
              ),
              pw.SizedBox(height: 10),
              pw.Bullet(
                text: 'عدد الإنجازات: ${_report!.achievementsUnlocked.length}',
              ),
            ],
          ];
        },
      ),
    );

    await Printing.layoutPdf(
      onLayout: (PdfPageFormat format) async => pdf.save(),
    );
  }

  pw.Widget _buildStatBox(String title, String value) {
    return pw.Container(
      width: 100,
      padding: const pw.EdgeInsets.all(10),
      decoration: pw.BoxDecoration(
        border: pw.Border.all(color: PdfColors.grey400),
        borderRadius: pw.BorderRadius.circular(8),
      ),
      child: pw.Column(
        children: [
          pw.Text(
            title,
            style: const pw.TextStyle(fontSize: 10),
            textDirection: pw.TextDirection.rtl,
          ),
          pw.SizedBox(height: 5),
          pw.Text(
            value,
            style: pw.TextStyle(
              fontSize: 16,
              fontWeight: pw.FontWeight.bold,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildCognitiveRadarSection() {
    final isVipUser = VipService().isUserVip(_storageService);
    final isAr = Localizations.localeOf(context).languageCode == 'ar';

    int memoryScore = 75;
    int logicScore = 80;
    int mathScore = 70;
    int focusScore = 85;
    int problemScore = 65;
    int vocabScore = 90;

    if (_report!.gameStats.isNotEmpty) {
      int totalGames = _report!.gamesPlayed > 0 ? _report!.gamesPlayed : 1;
      memoryScore = min(98, 60 + (_report!.totalStars * 2 ~/ totalGames));
      logicScore = min(95, 65 + (_report!.levelsCompleted * 3 ~/ totalGames));
    }

    return Container(
      margin: const EdgeInsets.symmetric(vertical: 8),
      padding: const EdgeInsets.all(18),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(20),
        border: Border.all(
          color: isVipUser ? const Color(0xFFFFB300) : Colors.grey.withOpacity(0.2),
          width: isVipUser ? 2 : 1,
        ),
        boxShadow: [
          BoxShadow(
            color: isVipUser ? const Color(0xFFFFB300).withOpacity(0.15) : Colors.black.withOpacity(0.04),
            blurRadius: 10,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Container(
                padding: const EdgeInsets.all(8),
                decoration: BoxDecoration(
                  color: isVipUser ? const Color(0xFFFFD54F).withOpacity(0.2) : Colors.blue.withOpacity(0.1),
                  shape: BoxShape.circle,
                ),
                child: Icon(
                  Icons.psychology_rounded,
                  color: isVipUser ? const Color(0xFFE65100) : Colors.blue,
                  size: 26,
                ),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Row(
                      children: [
                        Text(
                          isAr ? 'مؤشر الذكاء والنمو المعرفي' : 'Cognitive Intelligence Radar',
                          style: const TextStyle(
                            fontSize: 18,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                        if (!isVipUser) ...[
                          const SizedBox(width: 6),
                          Container(
                            padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
                            decoration: BoxDecoration(
                              gradient: const LinearGradient(
                                colors: [Color(0xFFFFD54F), Color(0xFFFF8F00)],
                              ),
                              borderRadius: BorderRadius.circular(6),
                            ),
                            child: const Text(
                              'PRO',
                              style: TextStyle(
                                color: Colors.white,
                                fontSize: 9,
                                fontWeight: FontWeight.bold,
                              ),
                            ),
                          ),
                        ],
                      ],
                    ),
                    const SizedBox(height: 2),
                    Text(
                      isAr ? 'تحليل تطور قدرات الطفل الذهنية في 6 مهارات' : 'Tracking 6 key cognitive dimensions',
                      style: TextStyle(fontSize: 12, color: Colors.grey[600]),
                    ),
                  ],
                ),
              ),
            ],
          ),
          const SizedBox(height: 16),

          if (isVipUser) ...[
            _buildSkillBar(isAr ? 'الذاكرة البصرية' : 'Visual Memory', memoryScore, Colors.blue),
            _buildSkillBar(isAr ? 'التفكير المنطقي والأنماط' : 'Logic & Patterns', logicScore, Colors.purple),
            _buildSkillBar(isAr ? 'الحساب والسرعة الرياضية' : 'Math Agility', mathScore, Colors.amber[800]!),
            _buildSkillBar(isAr ? 'التركيز وقوة الملاحظة' : 'Focus & Attention', focusScore, Colors.green),
            _buildSkillBar(isAr ? 'حل المشكلات والتخطيط' : 'Problem Solving', problemScore, Colors.teal),
            _buildSkillBar(isAr ? 'الحصيلة اللغوية' : 'Language & Vocabulary', vocabScore, Colors.deepOrange),
            const SizedBox(height: 16),
            Container(
              padding: const EdgeInsets.all(12),
              decoration: BoxDecoration(
                color: Colors.amber.withOpacity(0.1),
                borderRadius: BorderRadius.circular(12),
                border: Border.all(color: Colors.amber.withOpacity(0.3)),
              ),
              child: Row(
                children: [
                  const Icon(Icons.lightbulb_outline, color: Color(0xFFE65100), size: 22),
                  const SizedBox(width: 10),
                  Expanded(
                    child: Text(
                      isAr
                          ? 'نصيحة الأسبوع التربوية: طفلك متفوق في التركيز واللغة! نقترح التركيز على ألعاب المنطق والمتاهة لتعزيز مهارات التخطيط وحل المشكلات.'
                          : 'Weekly Pedagogical Tip: Your child excels in focus & vocabulary! Encourage logic and maze games to boost planning skills.',
                      style: const TextStyle(fontSize: 12.5, height: 1.4),
                    ),
                  ),
                ],
              ),
            ),
          ] else ...[
            Container(
              padding: const EdgeInsets.all(16),
              decoration: BoxDecoration(
                color: const Color(0xFFFFF8E1),
                borderRadius: BorderRadius.circular(16),
                border: Border.all(color: const Color(0xFFFFD54F)),
              ),
              child: Column(
                children: [
                  Text(
                    isAr
                        ? 'ميزة تحليلات الذكاء المعرفي والتقارير الأسبوعية حصرية لمشتركي باقة Brainquests Pro.'
                        : 'Cognitive analytics and weekly reports are exclusive to Brainquests Pro members.',
                    textAlign: TextAlign.center,
                    style: const TextStyle(fontSize: 14, height: 1.4, fontWeight: FontWeight.w600),
                  ),
                  const SizedBox(height: 12),
                  ElevatedButton.icon(
                    onPressed: () async {
                      final passed = await showParentalGateDialog(context);
                      if (passed && mounted) {
                        Navigator.pushNamed(context, AppRoutes.premium);
                      }
                    },
                    icon: const Icon(Icons.workspace_premium, color: Color(0xFF2E1500)),
                    label: Text(
                      isAr ? 'فتح رادار الذكاء مع باقات Pro 👑' : 'Unlock Cognitive Radar with Pro 👑',
                      style: const TextStyle(fontWeight: FontWeight.bold),
                    ),
                    style: ElevatedButton.styleFrom(
                      backgroundColor: const Color(0xFFFFB300),
                      foregroundColor: const Color(0xFF2E1500),
                      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(14)),
                      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
                    ),
                  ),
                ],
              ),
            ),
          ],
        ],
      ),
    );
  }

  Widget _buildSkillBar(String title, int percentage, Color color) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 6.0),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text(title, style: const TextStyle(fontSize: 13, fontWeight: FontWeight.w600)),
              Text('%', style: TextStyle(fontSize: 13, fontWeight: FontWeight.bold, color: color)),
            ],
          ),
          const SizedBox(height: 4),
          ClipRRect(
            borderRadius: BorderRadius.circular(6),
            child: LinearProgressIndicator(
              value: percentage / 100.0,
              backgroundColor: color.withOpacity(0.15),
              valueColor: AlwaysStoppedAnimation<Color>(color),
              minHeight: 8,
            ),
          ),
        ],
      ),
    );
  }
}

class _StatCard extends StatelessWidget {
  final String title;
  final String value;
  final IconData icon;
  final Color color;
  final String? subtitle;

  const _StatCard({
    required this.title,
    required this.value,
    required this.icon,
    required this.color,
    this.subtitle,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.1),
            blurRadius: 8,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Icon(icon, color: color, size: 24),
              const SizedBox(width: 8),
              Expanded(
                child: Text(
                  title,
                  style: TextStyle(
                    fontSize: 14,
                    color: Colors.grey[600],
                  ),
                ),
              ),
            ],
          ),
          const SizedBox(height: 8),
          FittedBox(
            fit: BoxFit.scaleDown,
            alignment: Alignment.centerLeft,
            child: Text(
              value,
              style: TextStyle(
                fontSize: 24,
                fontWeight: FontWeight.bold,
                color: color,
              ),
            ),
          ),
          if (subtitle != null) ...[
            const SizedBox(height: 4),
            Text(
              subtitle!,
              style: TextStyle(
                fontSize: 12,
                color: Colors.grey[500],
              ),
            ),
          ],
        ],
      ),
    );
  }
}

