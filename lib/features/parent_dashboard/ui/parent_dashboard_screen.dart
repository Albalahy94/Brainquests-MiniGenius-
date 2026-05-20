import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:fl_chart/fl_chart.dart';
import 'package:pdf/pdf.dart';
import 'package:pdf/widgets.dart' as pw;
import 'package:printing/printing.dart';
import 'package:intl/intl.dart';
import '../../../core/theme/app_theme.dart';
import '../../../core/services/parent_dashboard_service.dart';
import '../../../core/services/storage_service.dart';
import '../../../core/models/parent_dashboard.dart';
import '../../../core/models/game_info.dart';

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
  final TextEditingController _passwordController = TextEditingController();

  @override
  void initState() {
    super.initState();
    _loadData();
  }

  Future<void> _loadData() async {
    await _storageService.init();
    setState(() {
      _settings = _parentService.getSettings();
      _report = _parentService.generateReport();
    });
  }

  void _authenticate() {
    if (_passwordController.text.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('يرجى إدخال كلمة المرور')),
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
        const SnackBar(
          content: Text('كلمة المرور غير صحيحة'),
          backgroundColor: Colors.red,
        ),
      );
    }
  }

  void _setupPassword() {
    final passwordController = TextEditingController();
    final confirmController = TextEditingController();
    
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('إعداد كلمة المرور'),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            TextField(
              controller: passwordController,
              obscureText: true,
              decoration: const InputDecoration(
                labelText: 'كلمة المرور',
                hintText: 'أدخل كلمة مرور قوية',
              ),
            ),
            const SizedBox(height: 16),
            TextField(
              controller: confirmController,
              obscureText: true,
              decoration: const InputDecoration(
                labelText: 'تأكيد كلمة المرور',
                hintText: 'أعد إدخال كلمة المرور',
              ),
            ),
          ],
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('إلغاء'),
          ),
          TextButton(
            onPressed: () async {
              if (passwordController.text.isEmpty) {
                ScaffoldMessenger.of(context).showSnackBar(
                  const SnackBar(content: Text('يرجى إدخال كلمة المرور')),
                );
                return;
              }
              
              if (passwordController.text != confirmController.text) {
                ScaffoldMessenger.of(context).showSnackBar(
                  const SnackBar(
                    content: Text('كلمات المرور غير متطابقة'),
                    backgroundColor: Colors.red,
                  ),
                );
                return;
              }

              if (passwordController.text.length < 4) {
                ScaffoldMessenger.of(context).showSnackBar(
                  const SnackBar(
                    content: Text('كلمة المرور يجب أن تكون 4 أحرف على الأقل'),
                    backgroundColor: Colors.red,
                  ),
                );
                return;
              }

              await _parentService.setPassword(passwordController.text);
              Navigator.pop(context);
              ScaffoldMessenger.of(context).showSnackBar(
                const SnackBar(
                  content: Text('تم إعداد كلمة المرور بنجاح'),
                  backgroundColor: Colors.green,
                ),
              );
              _loadData();
            },
            child: const Text('حفظ'),
          ),
        ],
      ),
    );
  }

  void _changePassword() {
    final oldPasswordController = TextEditingController();
    final newPasswordController = TextEditingController();
    final confirmController = TextEditingController();
    
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('تغيير كلمة المرور'),
        content: SingleChildScrollView(
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              TextField(
                controller: oldPasswordController,
                obscureText: true,
                decoration: const InputDecoration(
                  labelText: 'كلمة المرور القديمة',
                ),
              ),
              const SizedBox(height: 16),
              TextField(
                controller: newPasswordController,
                obscureText: true,
                decoration: const InputDecoration(
                  labelText: 'كلمة المرور الجديدة',
                ),
              ),
              const SizedBox(height: 16),
              TextField(
                controller: confirmController,
                obscureText: true,
                decoration: const InputDecoration(
                  labelText: 'تأكيد كلمة المرور الجديدة',
                ),
              ),
            ],
          ),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('إلغاء'),
          ),
          TextButton(
            onPressed: () async {
              if (oldPasswordController.text.isEmpty ||
                  newPasswordController.text.isEmpty ||
                  confirmController.text.isEmpty) {
                ScaffoldMessenger.of(context).showSnackBar(
                  const SnackBar(content: Text('يرجى ملء جميع الحقول')),
                );
                return;
              }

              if (newPasswordController.text != confirmController.text) {
                ScaffoldMessenger.of(context).showSnackBar(
                  const SnackBar(
                    content: Text('كلمات المرور الجديدة غير متطابقة'),
                    backgroundColor: Colors.red,
                  ),
                );
                return;
              }

              if (newPasswordController.text.length < 4) {
                ScaffoldMessenger.of(context).showSnackBar(
                  const SnackBar(
                    content: Text('كلمة المرور يجب أن تكون 4 أحرف على الأقل'),
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
                  const SnackBar(
                    content: Text('تم تغيير كلمة المرور بنجاح'),
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
            child: const Text('حفظ'),
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

    if (!_isAuthenticated) {
      return _buildPasswordScreen();
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
                      child: Text(
                        'لوحة تحكم الوالدين',
                        textAlign: TextAlign.center,
                        style: Theme.of(context).textTheme.headlineLarge?.copyWith(
                              color: Colors.white,
                              fontWeight: FontWeight.bold,
                            ),
                      ),
                    ),
                    IconButton(
                      icon: const Icon(Icons.lock, color: Colors.white),
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
                      // Today's Play Time
                      _StatCard(
                        title: 'وقت اللعب اليوم',
                        value: '${_parentService.getTodayPlayTime()} دقيقة',
                        icon: Icons.access_time,
                        color: Colors.blue,
                        subtitle: _settings!.dailyPlayTimeLimit != null
                            ? 'الحد الأقصى: ${_settings!.dailyPlayTimeLimit} دقيقة'
                            : 'لا يوجد حد',
                      ),

                      const SizedBox(height: 16),

                      // Statistics Grid
                      Row(
                        children: [
                          Expanded(
                            child: _StatCard(
                              title: 'الألعاب',
                              value: '${_report!.gamesPlayed}',
                              icon: Icons.games,
                              color: Colors.green,
                            ),
                          ),
                          const SizedBox(width: 16),
                          Expanded(
                            child: _StatCard(
                              title: 'المستويات',
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
                              title: 'النجوم',
                              value: '${_report!.totalStars}',
                              icon: Icons.star,
                              color: Colors.amber,
                            ),
                          ),
                          const SizedBox(width: 16),
                          Expanded(
                            child: _StatCard(
                              title: 'وقت اللعب',
                              value: '${_report!.totalPlayTime} د',
                              icon: Icons.timer,
                              color: Colors.purple,
                            ),
                          ),
                        ],
                      ),

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
                                const Text(
                                  'الرسوم البيانية',
                                  style: TextStyle(
                                    fontSize: 20,
                                    fontWeight: FontWeight.bold,
                                  ),
                                ),
                                IconButton(
                                  icon: const Icon(Icons.picture_as_pdf),
                                  onPressed: () => _exportToPDF(),
                                  tooltip: 'تصدير PDF',
                                ),
                              ],
                            ),
                            const SizedBox(height: 24),
                            
                            // Bar Chart - Game Statistics
                            if (_report!.gameStats.isNotEmpty) ...[
                              const Text(
                                'عدد مرات اللعب لكل لعبة',
                                style: TextStyle(
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
                              const Text(
                                'توزيع الألعاب',
                                style: TextStyle(
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
                              const Padding(
                                padding: EdgeInsets.all(32.0),
                                child: Center(
                                  child: Text(
                                    'لا توجد إحصائيات بعد',
                                    style: TextStyle(color: Colors.grey),
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
                            const Text(
                              'إحصائيات الألعاب',
                              style: TextStyle(
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
                                        _getGameName(entry.key),
                                        style: const TextStyle(fontSize: 16),
                                      ),
                                    ),
                                    Text(
                                      '${entry.value} مرات',
                                      style: TextStyle(
                                        fontSize: 14,
                                        color: Colors.grey[600],
                                      ),
                                    ),
                                    const SizedBox(width: 8),
                                    Text(
                                      'متوسط: ${avgScore.toStringAsFixed(0)}',
                                      style: TextStyle(
                                        fontSize: 14,
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
                            const Text(
                              'الإعدادات',
                              style: TextStyle(
                                fontSize: 20,
                                fontWeight: FontWeight.bold,
                              ),
                            ),
                            const SizedBox(height: 16),
                            SwitchListTile(
                              title: const Text('تفعيل وضع الوالدين'),
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
                              title: const Text('حد وقت اللعب اليومي'),
                              subtitle: Text(
                                _settings!.dailyPlayTimeLimit != null
                                    ? '${_settings!.dailyPlayTimeLimit} دقيقة'
                                    : 'غير محدد',
                              ),
                              trailing: const Icon(Icons.arrow_forward_ios),
                              onTap: () => _showTimeLimitDialog(),
                            ),
                            ListTile(
                              title: const Text('الألعاب المسموحة'),
                              subtitle: Text(
                                _settings!.allowedGameIds.isEmpty
                                    ? 'جميع الألعاب'
                                    : '${_settings!.allowedGameIds.length} لعبة',
                              ),
                              trailing: const Icon(Icons.arrow_forward_ios),
                              onTap: () => _showGameSelectionDialog(),
                            ),
                            const Divider(),
                            ListTile(
                              title: const Text('الفئة العمرية'),
                              subtitle: Text(
                                _settings!.ageGroup != null
                                    ? '${_settings!.ageGroup}-${_settings!.ageGroup! + 2} سنوات'
                                    : 'غير محدد',
                              ),
                              trailing: const Icon(Icons.arrow_forward_ios),
                              onTap: () => _showAgeGroupDialog(),
                            ),
                            SwitchListTile(
                              title: const Text('تنبيهات الإنجازات'),
                              subtitle: const Text('إشعار عند فتح إنجاز جديد'),
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
                              title: const Text('كلمة المرور'),
                              subtitle: Text(
                                _parentService.hasPassword()
                                    ? 'تم إعداد كلمة المرور'
                                    : 'لم يتم إعداد كلمة المرور',
                              ),
                              trailing: const Icon(Icons.arrow_forward_ios),
                              onTap: _parentService.hasPassword()
                                  ? _changePassword
                                  : _setupPassword,
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

  Widget _buildPasswordScreen() {
    return Scaffold(
      body: Container(
        decoration: const BoxDecoration(
          gradient: AppTheme.blueGradient,
        ),
        child: SafeArea(
          child: Center(
            child: Padding(
              padding: const EdgeInsets.all(32.0),
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  const Icon(
                    Icons.lock,
                    size: 80,
                    color: Colors.white,
                  ),
                  const SizedBox(height: 32),
                  const Text(
                    'لوحة تحكم الوالدين',
                    style: TextStyle(
                      color: Colors.white,
                      fontSize: 28,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  const SizedBox(height: 16),
                  Text(
                    _parentService.hasPassword()
                        ? 'يرجى إدخال كلمة المرور'
                        : 'لم يتم إعداد كلمة المرور بعد',
                    style: const TextStyle(
                      color: Colors.white,
                      fontSize: 16,
                    ),
                  ),
                  const SizedBox(height: 32),
                  TextField(
                    controller: _passwordController,
                    obscureText: true,
                    decoration: InputDecoration(
                      filled: true,
                      fillColor: Colors.white,
                      hintText: 'كلمة المرور',
                      border: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(12),
                      ),
                    ),
                    textAlign: TextAlign.center,
                  ),
                  const SizedBox(height: 24),
                  ElevatedButton(
                    onPressed: _parentService.hasPassword()
                        ? _authenticate
                        : _setupPassword,
                    style: ElevatedButton.styleFrom(
                      backgroundColor: Colors.white,
                      foregroundColor: AppTheme.primaryBlue,
                      padding: const EdgeInsets.symmetric(
                        horizontal: 48,
                        vertical: 16,
                      ),
                    ),
                    child: Text(
                      _parentService.hasPassword() ? 'دخول' : 'إعداد كلمة المرور',
                      style: const TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
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

  void _showTimeLimitDialog() {
    int? selectedMinutes;
    showDialog(
      context: context,
      builder: (context) => StatefulBuilder(
        builder: (context, setState) => AlertDialog(
          title: const Text('حد وقت اللعب اليومي'),
          content: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              RadioListTile<int>(
                title: const Text('لا يوجد حد'),
                value: 0,
                groupValue: selectedMinutes ?? (_settings!.dailyPlayTimeLimit ?? 0),
                onChanged: (value) => setState(() => selectedMinutes = value),
              ),
              RadioListTile<int>(
                title: const Text('30 دقيقة'),
                value: 30,
                groupValue: selectedMinutes ?? (_settings!.dailyPlayTimeLimit ?? 0),
                onChanged: (value) => setState(() => selectedMinutes = value),
              ),
              RadioListTile<int>(
                title: const Text('60 دقيقة'),
                value: 60,
                groupValue: selectedMinutes ?? (_settings!.dailyPlayTimeLimit ?? 0),
                onChanged: (value) => setState(() => selectedMinutes = value),
              ),
              RadioListTile<int>(
                title: const Text('90 دقيقة'),
                value: 90,
                groupValue: selectedMinutes ?? (_settings!.dailyPlayTimeLimit ?? 0),
                onChanged: (value) => setState(() => selectedMinutes = value),
              ),
            ],
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.pop(context),
              child: const Text('إلغاء'),
            ),
            TextButton(
              onPressed: () async {
                final limit = selectedMinutes == 0 ? null : selectedMinutes;
                final updated = _settings!.copyWith(dailyPlayTimeLimit: limit);
                await _parentService.updateSettings(updated);
                _loadData();
                Navigator.pop(context);
              },
              child: const Text('حفظ'),
            ),
          ],
        ),
      ),
    );
  }

  void _showGameSelectionDialog() {
    final selectedGames = Set<String>.from(_settings!.allowedGameIds);
    
    showDialog(
      context: context,
      builder: (context) => StatefulBuilder(
        builder: (context, setDialogState) => AlertDialog(
          title: const Text('الألعاب المسموحة'),
          content: SizedBox(
            width: double.maxFinite,
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                CheckboxListTile(
                  title: const Text('جميع الألعاب'),
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
                        title: Text(_getGameName(game.id)),
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
              child: const Text('إلغاء'),
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
                          ? 'تم تفعيل جميع الألعاب'
                          : 'تم تحديث الألعاب المسموحة',
                    ),
                    backgroundColor: Colors.green,
                  ),
                );
              },
              child: const Text('حفظ'),
            ),
          ],
        ),
      ),
    );
  }

  void _showAgeGroupDialog() {
    int? selectedAgeGroup = _settings!.ageGroup;
    
    showDialog(
      context: context,
      builder: (context) => StatefulBuilder(
        builder: (context, setDialogState) => AlertDialog(
          title: const Text('الفئة العمرية للطفل'),
          content: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              RadioListTile<int?>(
                title: const Text('3-5 سنوات'),
                value: 3,
                groupValue: selectedAgeGroup,
                onChanged: (value) => setDialogState(() => selectedAgeGroup = value),
              ),
              RadioListTile<int?>(
                title: const Text('6-8 سنوات'),
                value: 6,
                groupValue: selectedAgeGroup,
                onChanged: (value) => setDialogState(() => selectedAgeGroup = value),
              ),
              RadioListTile<int?>(
                title: const Text('9-12 سنة'),
                value: 9,
                groupValue: selectedAgeGroup,
                onChanged: (value) => setDialogState(() => selectedAgeGroup = value),
              ),
              RadioListTile<int?>(
                title: const Text('13+ سنة'),
                value: 13,
                groupValue: selectedAgeGroup,
                onChanged: (value) => setDialogState(() => selectedAgeGroup = value),
              ),
              RadioListTile<int?>(
                title: const Text('غير محدد'),
                value: null,
                groupValue: selectedAgeGroup,
                onChanged: (value) => setDialogState(() => selectedAgeGroup = value),
              ),
            ],
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.pop(context),
              child: const Text('إلغاء'),
            ),
            TextButton(
              onPressed: () async {
                final updated = _settings!.copyWith(ageGroup: selectedAgeGroup);
                await _parentService.updateSettings(updated);
                _loadData();
                Navigator.pop(context);
              },
              child: const Text('حفظ'),
            ),
          ],
        ),
      ),
    );
  }

  String _getGameName(String gameId) {
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
          Text(
            value,
            style: TextStyle(
              fontSize: 24,
              fontWeight: FontWeight.bold,
              color: color,
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

