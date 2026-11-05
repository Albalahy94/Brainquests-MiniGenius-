import 'dart:math';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import '../../../core/theme/app_theme.dart';
import '../../../core/services/licensing_api_service.dart';

class ParentAccountDialog extends StatefulWidget {
  final VoidCallback? onAccountUpdated;

  const ParentAccountDialog({super.key, this.onAccountUpdated});

  static Future<void> show(BuildContext context, {VoidCallback? onAccountUpdated}) {
    return showDialog(
      context: context,
      barrierDismissible: true,
      builder: (ctx) => ParentAccountDialog(onAccountUpdated: onAccountUpdated),
    );
  }

  @override
  State<ParentAccountDialog> createState() => _ParentAccountDialogState();
}

class _ParentAccountDialogState extends State<ParentAccountDialog> {
  final LicensingApiService _licensingService = LicensingApiService();

  bool _isLoading = true;
  bool _isSubmitting = false;
  bool _isLoggedIn = false;
  bool _isRegisterMode = true;
  bool _obscurePassword = true;

  Map<String, String?> _profile = {};
  String _deviceId = '';

  final _formKey = GlobalKey<FormState>();
  final _nameController = TextEditingController();
  final _phoneController = TextEditingController();
  final _emailController = TextEditingController();
  final _passwordController = TextEditingController();

  @override
  void initState() {
    super.initState();
    _loadProfile();
  }

  @override
  void dispose() {
    _nameController.dispose();
    _phoneController.dispose();
    _emailController.dispose();
    _passwordController.dispose();
    super.dispose();
  }

  Future<void> _loadProfile() async {
    setState(() => _isLoading = true);
    final profile = await _licensingService.getParentProfile();
    final deviceId = await LicensingApiService.getDeviceId();
    setState(() {
      _profile = profile;
      _deviceId = deviceId;
      _isLoggedIn = profile['isLoggedIn'] == 'true';
      _isLoading = false;
    });
  }

  void _generateSuggestedPassword() {
    final adjectives = ['Hero', 'Super', 'Smart', 'Safe', 'Star', 'Bright'];
    final numbers = Random().nextInt(900) + 100;
    final symbols = ['@', '#', '!', '*'];
    final randomAdj = adjectives[Random().nextInt(adjectives.length)];
    final randomSym = symbols[Random().nextInt(symbols.length)];
    final suggested = '$randomAdj$numbers$randomSym';

    _passwordController.text = suggested;
    Clipboard.setData(ClipboardData(text: suggested));

    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text('تم توليد كلمة مرور قوية ونسخها: $suggested'),
        backgroundColor: Colors.teal,
        duration: const Duration(seconds: 3),
      ),
    );
    setState(() {});
  }

  Future<void> _handleSubmit() async {
    if (!_formKey.currentState!.validate()) return;

    setState(() => _isSubmitting = true);

    if (_isRegisterMode) {
      final res = await _licensingService.registerParentAccount(
        name: _nameController.text.trim(),
        phone: _phoneController.text.trim(),
        email: _emailController.text.trim(),
        password: _passwordController.text,
      );

      setState(() => _isSubmitting = false);

      if (!mounted) return;

      if (res['status'] == 'success') {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(res['message'] ?? 'تم إنشاء الحساب بنجاح!'),
            backgroundColor: Colors.green,
          ),
        );
        widget.onAccountUpdated?.call();
        _loadProfile();
      } else {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(res['message'] ?? 'فشل إنشاء الحساب'),
            backgroundColor: Colors.redAccent,
          ),
        );
      }
    } else {
      final res = await _licensingService.loginParentAccount(
        identifier: _emailController.text.trim(),
        password: _passwordController.text,
      );

      setState(() => _isSubmitting = false);

      if (!mounted) return;

      if (res['status'] == 'success') {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(res['message'] ?? 'تم تسجيل الدخول بنجاح!'),
            backgroundColor: Colors.green,
          ),
        );
        widget.onAccountUpdated?.call();
        _loadProfile();
      } else {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(res['message'] ?? 'فشل تسجيل الدخول'),
            backgroundColor: Colors.redAccent,
          ),
        );
      }
    }
  }

  Future<void> _handleLogout() async {
    await _licensingService.logoutParentAccount();
    widget.onAccountUpdated?.call();
    _loadProfile();
  }

  Future<void> _handleSyncLicense() async {
    setState(() => _isSubmitting = true);
    final res = await _licensingService.verifyLicense();
    setState(() => _isSubmitting = false);

    if (!mounted) return;

    final isPro = res['data']?['is_pro'] == true ||
        res['data']?['plan'] == 'pro' ||
        res['data']?['plan'] == 'ultimate';

    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(isPro
            ? '✅ تم تحديث الترخيص: حسابك مفعل باقة VIP بنجاح!'
            : 'ℹ️ تم المزامنة بنجاح مع السيرفر المركزي.'),
        backgroundColor: isPro ? Colors.green : Colors.blueGrey,
      ),
    );
    widget.onAccountUpdated?.call();
  }

  @override
  Widget build(BuildContext context) {
    return Dialog(
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(24)),
      elevation: 16,
      insetPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 24),
      child: Container(
        constraints: const BoxConstraints(maxWidth: 480),
        padding: const EdgeInsets.all(24),
        decoration: BoxDecoration(
          borderRadius: BorderRadius.circular(24),
          gradient: LinearGradient(
            begin: Alignment.topRight,
            end: Alignment.bottomLeft,
            colors: [
              Colors.white,
              AppTheme.primaryBlue.withValues(alpha: 0.05),
            ],
          ),
        ),
        child: _isLoading
            ? const Center(
                heightFactor: 4,
                child: CircularProgressIndicator(),
              )
            : SingleChildScrollView(
                child: _isLoggedIn ? _buildProfileView() : _buildAuthForm(),
              ),
      ),
    );
  }

  Widget _buildProfileView() {
    return Column(
      mainAxisSize: MainAxisSize.min,
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            IconButton(
              icon: const Icon(Icons.close),
              onPressed: () => Navigator.of(context).pop(),
            ),
            Row(
              children: [
                Text(
                  'ملف ولي الأمر',
                  style: Theme.of(context).textTheme.titleLarge?.copyWith(
                        fontWeight: FontWeight.bold,
                        color: AppTheme.primaryBlue,
                      ),
                ),
                const SizedBox(width: 8),
                const Icon(Icons.verified_user_rounded, color: Colors.teal),
              ],
            ),
          ],
        ),
        const SizedBox(height: 16),
        Container(
          padding: const EdgeInsets.all(16),
          decoration: BoxDecoration(
            color: Colors.white,
            borderRadius: BorderRadius.circular(16),
            border: Border.all(color: Colors.teal.shade200),
            boxShadow: [
              BoxShadow(
                color: Colors.black.withValues(alpha: 0.04),
                blurRadius: 10,
                offset: const Offset(0, 4),
              ),
            ],
          ),
          child: Column(
            children: [
              CircleAvatar(
                radius: 36,
                backgroundColor: AppTheme.primaryBlue.withValues(alpha: 0.1),
                child: const Icon(
                  Icons.person_rounded,
                  size: 42,
                  color: AppTheme.primaryBlue,
                ),
              ),
              const SizedBox(height: 12),
              Text(
                _profile['name'] ?? 'ولي الأمر',
                style: const TextStyle(
                  fontSize: 18,
                  fontWeight: FontWeight.bold,
                ),
              ),
              const SizedBox(height: 4),
              Text(
                _profile['email'] ?? '',
                style: TextStyle(fontSize: 13, color: Colors.grey.shade600),
              ),
              if (_profile['phone'] != null && _profile['phone']!.isNotEmpty) ...[
                const SizedBox(height: 4),
                Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Text(
                      _profile['phone']!,
                      style: const TextStyle(
                        fontSize: 13,
                        fontWeight: FontWeight.w600,
                        color: Colors.teal,
                      ),
                    ),
                    const SizedBox(width: 4),
                    const Icon(Icons.phone_android_rounded, size: 16, color: Colors.teal),
                  ],
                ),
              ],
            ],
          ),
        ),
        const SizedBox(height: 14),
        Container(
          padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 10),
          decoration: BoxDecoration(
            color: Colors.grey.shade100,
            borderRadius: BorderRadius.circular(12),
          ),
          child: Row(
            children: [
              IconButton(
                icon: const Icon(Icons.copy_rounded, size: 18),
                tooltip: 'نسخ معرف الجهاز',
                onPressed: () {
                  Clipboard.setData(ClipboardData(text: _deviceId));
                  ScaffoldMessenger.of(context).showSnackBar(
                    const SnackBar(
                      content: Text('تم نسخ معرف الجهاز إلى الحافظة'),
                      duration: Duration(seconds: 2),
                    ),
                  );
                },
              ),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.end,
                  children: [
                    const Text(
                      'معرف الجهاز المرتبط (Device ID)',
                      style: TextStyle(fontSize: 11, color: Colors.grey),
                    ),
                    Text(
                      _deviceId,
                      style: const TextStyle(
                        fontSize: 11,
                        fontWeight: FontWeight.bold,
                        fontFamily: 'monospace',
                      ),
                      overflow: TextOverflow.ellipsis,
                    ),
                  ],
                ),
              ),
              const SizedBox(width: 8),
              const Icon(Icons.devices_rounded, size: 20, color: Colors.blueGrey),
            ],
          ),
        ),
        const SizedBox(height: 20),
        ElevatedButton.icon(
          onPressed: _isSubmitting ? null : _handleSyncLicense,
          icon: _isSubmitting
              ? const SizedBox(
                  width: 18,
                  height: 18,
                  child: CircularProgressIndicator(strokeWidth: 2, color: Colors.white),
                )
              : const Icon(Icons.sync_rounded),
          label: const Text('مزامنة حالة اشتراك VIP الآن'),
          style: ElevatedButton.styleFrom(
            backgroundColor: Colors.teal,
            foregroundColor: Colors.white,
            padding: const EdgeInsets.symmetric(vertical: 12),
            shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
          ),
        ),
        const SizedBox(height: 10),
        OutlinedButton.icon(
          onPressed: _handleLogout,
          icon: const Icon(Icons.logout_rounded, color: Colors.redAccent),
          label: const Text(
            'تسجيل الخروج من الحساب',
            style: TextStyle(color: Colors.redAccent),
          ),
          style: OutlinedButton.styleFrom(
            side: const BorderSide(color: Colors.redAccent),
            padding: const EdgeInsets.symmetric(vertical: 12),
            shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
          ),
        ),
      ],
    );
  }

  Widget _buildAuthForm() {
    return Form(
      key: _formKey,
      child: Column(
        mainAxisSize: MainAxisSize.min,
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              IconButton(
                icon: const Icon(Icons.close),
                onPressed: () => Navigator.of(context).pop(),
              ),
              Row(
                children: [
                  Text(
                    _isRegisterMode ? 'إنشاء حساب ولي الأمر' : 'تسجيل دخول ولي الأمر',
                    style: Theme.of(context).textTheme.titleMedium?.copyWith(
                          fontWeight: FontWeight.bold,
                          color: AppTheme.primaryBlue,
                        ),
                  ),
                  const SizedBox(width: 8),
                  const Icon(Icons.family_restroom_rounded, color: AppTheme.primaryBlue),
                ],
              ),
            ],
          ),
          const SizedBox(height: 8),
          Text(
            _isRegisterMode
                ? 'قم بإنشاء حساب لحفظ اشتراكات طفلك، مزامنة تراخيص VIP، وربطها بهاتفك.'
                : 'أهلاً بك مجدداً! سجّل دخولك لمزامنة اشتراكات طفلك وتراخيص الـ VIP.',
            textAlign: TextAlign.center,
            style: TextStyle(fontSize: 12, color: Colors.grey.shade600),
          ),
          const SizedBox(height: 16),
          // Toggle Tabs
          Container(
            padding: const EdgeInsets.all(4),
            decoration: BoxDecoration(
              color: Colors.grey.shade200,
              borderRadius: BorderRadius.circular(12),
            ),
            child: Row(
              children: [
                Expanded(
                  child: InkWell(
                    onTap: () => setState(() => _isRegisterMode = true),
                    child: Container(
                      padding: const EdgeInsets.symmetric(vertical: 8),
                      decoration: BoxDecoration(
                        color: _isRegisterMode ? Colors.white : Colors.transparent,
                        borderRadius: BorderRadius.circular(10),
                        boxShadow: _isRegisterMode
                            ? [
                                BoxShadow(
                                  color: Colors.black.withValues(alpha: 0.05),
                                  blurRadius: 4,
                                )
                              ]
                            : null,
                      ),
                      alignment: Alignment.center,
                      child: Text(
                        'حساب جديد',
                        style: TextStyle(
                          fontSize: 13,
                          fontWeight:
                              _isRegisterMode ? FontWeight.bold : FontWeight.normal,
                          color: _isRegisterMode
                              ? AppTheme.primaryBlue
                              : Colors.grey.shade700,
                        ),
                      ),
                    ),
                  ),
                ),
                Expanded(
                  child: InkWell(
                    onTap: () => setState(() => _isRegisterMode = false),
                    child: Container(
                      padding: const EdgeInsets.symmetric(vertical: 8),
                      decoration: BoxDecoration(
                        color: !_isRegisterMode ? Colors.white : Colors.transparent,
                        borderRadius: BorderRadius.circular(10),
                        boxShadow: !_isRegisterMode
                            ? [
                                BoxShadow(
                                  color: Colors.black.withValues(alpha: 0.05),
                                  blurRadius: 4,
                                )
                              ]
                            : null,
                      ),
                      alignment: Alignment.center,
                      child: Text(
                        'تسجيل الدخول',
                        style: TextStyle(
                          fontSize: 13,
                          fontWeight:
                              !_isRegisterMode ? FontWeight.bold : FontWeight.normal,
                          color: !_isRegisterMode
                              ? AppTheme.primaryBlue
                              : Colors.grey.shade700,
                        ),
                      ),
                    ),
                  ),
                ),
              ],
            ),
          ),
          const SizedBox(height: 16),
          if (_isRegisterMode) ...[
            TextFormField(
              controller: _nameController,
              textAlign: TextAlign.right,
              decoration: InputDecoration(
                labelText: 'الاسم ثلاثي لولي الأمر *',
                hintText: 'مثال: أحمد عبد الله المحمدي',
                prefixIcon: const Icon(Icons.person_outline),
                border: OutlineInputBorder(borderRadius: BorderRadius.circular(12)),
                contentPadding: const EdgeInsets.symmetric(horizontal: 14, vertical: 12),
              ),
              validator: (v) {
                if (v == null || v.trim().isEmpty) return 'يرجى إدخال اسم ولي الأمر';
                final words = v.trim().split(RegExp(r'\s+'));
                if (words.length < 2) return 'يرجى كتابة الاسم ثنائياً أو ثلاثياً على الأقل';
                return null;
              },
            ),
            const SizedBox(height: 12),
            TextFormField(
              controller: _phoneController,
              keyboardType: TextInputType.phone,
              textAlign: TextAlign.right,
              decoration: InputDecoration(
                labelText: 'رقم هاتف الواتساب (للتواصل وتأكيد VIP) *',
                hintText: '01012345678',
                prefixIcon: const Icon(Icons.chat_bubble_outline, color: Colors.teal),
                border: OutlineInputBorder(borderRadius: BorderRadius.circular(12)),
                contentPadding: const EdgeInsets.symmetric(horizontal: 14, vertical: 12),
              ),
              validator: (v) {
                if (v == null || v.trim().isEmpty) return 'يرجى إدخال رقم الواتساب';
                if (v.trim().length < 8) return 'رقم الهاتف غير صالح';
                return null;
              },
            ),
            const SizedBox(height: 12),
          ],
          TextFormField(
            controller: _emailController,
            keyboardType: TextInputType.emailAddress,
            textAlign: TextAlign.right,
            decoration: InputDecoration(
              labelText: _isRegisterMode ? 'البريد الإلكتروني *' : 'البريد الإلكتروني أو اسم المستخدم *',
              hintText: 'parent@example.com',
              prefixIcon: const Icon(Icons.email_outlined),
              border: OutlineInputBorder(borderRadius: BorderRadius.circular(12)),
              contentPadding: const EdgeInsets.symmetric(horizontal: 14, vertical: 12),
            ),
            validator: (v) {
              if (v == null || v.trim().isEmpty) return 'يرجى إدخال البريد الإلكتروني';
              if (_isRegisterMode && !v.contains('@')) return 'صيغة البريد الإلكتروني غير صحيحة';
              return null;
            },
          ),
          const SizedBox(height: 12),
          TextFormField(
            controller: _passwordController,
            obscureText: _obscurePassword,
            textAlign: TextAlign.right,
            decoration: InputDecoration(
              labelText: 'كلمة المرور *',
              prefixIcon: const Icon(Icons.lock_outline),
              suffixIcon: IconButton(
                icon: Icon(_obscurePassword ? Icons.visibility_off : Icons.visibility),
                onPressed: () => setState(() => _obscurePassword = !_obscurePassword),
              ),
              border: OutlineInputBorder(borderRadius: BorderRadius.circular(12)),
              contentPadding: const EdgeInsets.symmetric(horizontal: 14, vertical: 12),
            ),
            validator: (v) {
              if (v == null || v.isEmpty) return 'يرجى إدخال كلمة المرور';
              if (v.length < 6) return 'كلمة المرور يجب ألا تقل عن 6 خانات';
              return null;
            },
          ),
          if (_isRegisterMode) ...[
            const SizedBox(height: 8),
            Align(
              alignment: Alignment.centerLeft,
              child: TextButton.icon(
                onPressed: _generateSuggestedPassword,
                icon: const Icon(Icons.auto_awesome, size: 16, color: Colors.teal),
                label: const Text(
                  'اقتراح كلمة مرور قوية وسهلة',
                  style: TextStyle(fontSize: 12, color: Colors.teal, fontWeight: FontWeight.bold),
                ),
              ),
            ),
          ],
          const SizedBox(height: 16),
          ElevatedButton(
            onPressed: _isSubmitting ? null : _handleSubmit,
            style: ElevatedButton.styleFrom(
              backgroundColor: AppTheme.primaryBlue,
              foregroundColor: Colors.white,
              padding: const EdgeInsets.symmetric(vertical: 14),
              shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
            ),
            child: _isSubmitting
                ? const SizedBox(
                    width: 20,
                    height: 20,
                    child: CircularProgressIndicator(strokeWidth: 2, color: Colors.white),
                  )
                : Text(
                    _isRegisterMode ? 'إنشاء الحساب وتأكيد الربط' : 'تسجيل الدخول ومزامنة VIP',
                    style: const TextStyle(fontSize: 15, fontWeight: FontWeight.bold),
                  ),
          ),
        ],
      ),
    );
  }
}
