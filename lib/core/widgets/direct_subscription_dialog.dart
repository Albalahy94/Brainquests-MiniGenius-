import 'package:flutter/material.dart';
import 'package:url_launcher/url_launcher.dart';
import '../theme/app_theme.dart';
import '../services/licensing_api_service.dart';

class DirectSubscriptionDialog extends StatefulWidget {
  final String? initialPlanId;

  const DirectSubscriptionDialog({super.key, this.initialPlanId});

  static Future<void> show(BuildContext context, {String? initialPlanId}) {
    return showDialog(
      context: context,
      barrierDismissible: true,
      builder: (ctx) => DirectSubscriptionDialog(initialPlanId: initialPlanId),
    );
  }

  @override
  State<DirectSubscriptionDialog> createState() => _DirectSubscriptionDialogState();
}

class _DirectSubscriptionDialogState extends State<DirectSubscriptionDialog> {
  final LicensingApiService _licensingService = LicensingApiService();

  String _selectedPlan = 'yearly';
  bool _isSubmitting = false;
  bool _isSuccess = false;
  String _successMessage = '';

  final _formKey = GlobalKey<FormState>();
  final _nameController = TextEditingController();
  final _phoneController = TextEditingController();
  final _notesController = TextEditingController();

  final List<Map<String, String>> _plans = [
    {
      'id': 'monthly',
      'title': 'اشتراك شهري (Brainquests Pro)',
      'price': '150 ج.م / \$4.99',
      'duration': '30 يوماً',
      'badge': 'تجديد مرن',
    },
    {
      'id': 'yearly',
      'title': 'اشتراك سنوي (العام الذهبي 👑)',
      'price': '990 ج.م / \$39.99',
      'duration': '365 يوماً',
      'badge': 'توفير 35% + تجربة 7 أيام',
    },
    {
      'id': 'lifetime',
      'title': 'الباقة الذهبية مدى الحياة ♾️',
      'price': '1990 ج.م / \$79.99',
      'duration': 'دائم للأبد (جهازين)',
      'badge': 'الأكثر طلباً',
    },
  ];

  @override
  void initState() {
    super.initState();
    if (widget.initialPlanId != null &&
        _plans.any((p) => p['id'] == widget.initialPlanId)) {
      _selectedPlan = widget.initialPlanId!;
    }
    _prefillParentData();
  }

  Future<void> _prefillParentData() async {
    final profile = await _licensingService.getParentProfile();
    if (profile['name'] != null && profile['name']!.isNotEmpty) {
      _nameController.text = profile['name']!;
    }
    if (profile['phone'] != null && profile['phone']!.isNotEmpty) {
      _phoneController.text = profile['phone']!;
    }
  }

  @override
  void dispose() {
    _nameController.dispose();
    _phoneController.dispose();
    _notesController.dispose();
    super.dispose();
  }

  Future<void> _submitRequest() async {
    if (!_formKey.currentState!.validate()) return;

    setState(() => _isSubmitting = true);

    final selectedPlanObj = _plans.firstWhere(
      (p) => p['id'] == _selectedPlan,
      orElse: () => _plans[1],
    );

    final res = await _licensingService.submitSubscriptionRequest(
      planId: selectedPlanObj['id']!,
      planName: selectedPlanObj['title']!,
      price: selectedPlanObj['price']!,
      parentName: _nameController.text.trim(),
      parentPhone: _phoneController.text.trim(),
    );

    setState(() => _isSubmitting = false);

    if (!mounted) return;

    if (res['status'] == 'success') {
      setState(() {
        _isSuccess = true;
        _successMessage = res['message'] ?? 'تم إرسال طلبك بنجاح وهو قيد المراجعة حالياً من الإدارة!';
      });
    } else {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(res['message'] ?? 'حدث خطأ في إرسال الطلب'),
          backgroundColor: Colors.redAccent,
        ),
      );
    }
  }

  Future<void> _openWhatsAppSupport() async {
    final selectedPlanObj = _plans.firstWhere(
      (p) => p['id'] == _selectedPlan,
      orElse: () => _plans[1],
    );
    final deviceId = await LicensingApiService.getDeviceId();
    final message = Uri.encodeComponent(
      'مرحباً مهندس سعيد، أنا ولي أمر الطفل ${_nameController.text.trim()} '
      'وقمت بإرسال طلب اشتراك VIP في تطبيق Brainquests لباقة ${selectedPlanObj['title']} '
      '(${selectedPlanObj['price']}).\n'
      'معرّف جهازي هو:\n$deviceId\n'
      'أرجو إرسال تفاصيل التحويل وتأكيد التفعيل وشكراً لك!',
    );
    final uri = Uri.parse('https://wa.me/201067481561?text=$message');
    if (await canLaunchUrl(uri)) {
      await launchUrl(uri, mode: LaunchMode.externalApplication);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Dialog(
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(24)),
      elevation: 16,
      insetPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 24),
      child: Container(
        constraints: const BoxConstraints(maxWidth: 500),
        padding: const EdgeInsets.all(24),
        decoration: BoxDecoration(
          borderRadius: BorderRadius.circular(24),
          color: Colors.white,
        ),
        child: SingleChildScrollView(
          child: _isSuccess ? _buildSuccessView() : _buildFormView(),
        ),
      ),
    );
  }

  Widget _buildSuccessView() {
    return Column(
      mainAxisSize: MainAxisSize.min,
      children: [
        const CircleAvatar(
          radius: 36,
          backgroundColor: Color(0xFFE0F2F1),
          child: Icon(Icons.mark_email_read_rounded, size: 50, color: Colors.teal),
        ),
        const SizedBox(height: 16),
        const Text(
          'تم استلام طلبك بنجاح وهو قيد المراجعة ⏳',
          style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold, color: Colors.teal),
          textAlign: TextAlign.center,
        ),
        const SizedBox(height: 10),
        Text(
          _successMessage.isNotEmpty
              ? _successMessage
              : 'تم تسجيل طلبك لدى الإدارة وسيتم مراجعته وتأكيد التفعيل فور استلام التحويل.',
          style: TextStyle(fontSize: 13, color: Colors.grey.shade700, height: 1.5),
          textAlign: TextAlign.center,
        ),
        const SizedBox(height: 20),
        Container(
          padding: const EdgeInsets.all(14),
          decoration: BoxDecoration(
            color: Colors.teal.shade50,
            borderRadius: BorderRadius.circular(14),
            border: Border.all(color: Colors.teal.shade200),
          ),
          child: const Row(
            children: [
              Icon(Icons.flash_on_rounded, color: Colors.teal),
              SizedBox(width: 8),
              Expanded(
                child: Text(
                  'طرق الدفع المدعومة: إنستاباي (InstaPay)، فودافون كاش، محافظ إلكترونية، أو فيزا بنكية.',
                  style: TextStyle(fontSize: 12, fontWeight: FontWeight.w600, color: Colors.teal),
                ),
              ),
            ],
          ),
        ),
        const SizedBox(height: 24),
        ElevatedButton.icon(
          onPressed: _openWhatsAppSupport,
          icon: const Icon(Icons.chat_rounded, color: Colors.white),
          label: const Text(
            'تأكيد الدفع والتفعيل مع الإدارة عبر واتساب',
            style: TextStyle(fontSize: 14, fontWeight: FontWeight.bold),
          ),
          style: ElevatedButton.styleFrom(
            backgroundColor: const Color(0xFF25D366),
            foregroundColor: Colors.white,
            padding: const EdgeInsets.symmetric(vertical: 14, horizontal: 16),
            shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
          ),
        ),
        const SizedBox(height: 10),
        TextButton(
          onPressed: () => Navigator.of(context).pop(),
          child: const Text('إغلاق'),
        ),
      ],
    );
  }

  Widget _buildFormView() {
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
              Expanded(
                child: FittedBox(
                  fit: BoxFit.scaleDown,
                  alignment: Alignment.centerRight,
                  child: Row(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      Text(
                        'طلب اشتراك وتفعيل VIP مباشر',
                        style: Theme.of(context).textTheme.titleMedium?.copyWith(
                              fontWeight: FontWeight.bold,
                              color: AppTheme.primaryBlue,
                            ),
                      ),
                      const SizedBox(width: 8),
                      const Icon(Icons.stars_rounded, color: Colors.amber),
                    ],
                  ),
                ),
              ),
            ],
          ),
          const SizedBox(height: 6),
          Text(
            'اختر الباقة المناسبة وسيقوم فريق المنظومة بالتواصل معك لتأكيد التفعيل فودافون كاش أو إنستاباي.',
            textAlign: TextAlign.center,
            style: TextStyle(fontSize: 12, color: Colors.grey.shade600),
          ),
          const SizedBox(height: 16),
          // Plan Selector Cards
          ..._plans.map((p) {
            final isSelected = p['id'] == _selectedPlan;
            return InkWell(
              onTap: () => setState(() => _selectedPlan = p['id']!),
              borderRadius: BorderRadius.circular(14),
              child: Container(
                margin: const EdgeInsets.only(bottom: 8),
                padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 12),
                decoration: BoxDecoration(
                  borderRadius: BorderRadius.circular(14),
                  border: Border.all(
                    color: isSelected ? Colors.amber.shade700 : Colors.grey.shade300,
                    width: isSelected ? 2 : 1,
                  ),
                  color: isSelected ? Colors.amber.shade50 : Colors.white,
                ),
                child: Row(
                  children: [
                    Radio<String>(
                      value: p['id']!,
                      groupValue: _selectedPlan,
                      onChanged: (val) => setState(() => _selectedPlan = val!),
                      activeColor: Colors.amber.shade800,
                    ),
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.end,
                        children: [
                          Row(
                            mainAxisAlignment: MainAxisAlignment.spaceBetween,
                            children: [
                              Container(
                                padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 2),
                                decoration: BoxDecoration(
                                  color: isSelected ? Colors.amber.shade200 : Colors.grey.shade200,
                                  borderRadius: BorderRadius.circular(8),
                                ),
                                child: Text(
                                  p['badge']!,
                                  style: TextStyle(
                                    fontSize: 10,
                                    fontWeight: FontWeight.bold,
                                    color: isSelected ? Colors.amber.shade900 : Colors.grey.shade700,
                                  ),
                                ),
                              ),
                              const SizedBox(width: 6),
                              Expanded(
                                child: Text(
                                  p['title']!,
                                  textAlign: TextAlign.end,
                                  maxLines: 1,
                                  overflow: TextOverflow.ellipsis,
                                  style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 13),
                                ),
                              ),
                            ],
                          ),
                          const SizedBox(height: 4),
                          Text(
                            p['price']!,
                            style: TextStyle(
                              fontSize: 13,
                              fontWeight: FontWeight.bold,
                              color: isSelected ? Colors.amber.shade900 : Colors.black87,
                            ),
                          ),
                        ],
                      ),
                    ),
                  ],
                ),
              ),
            );
          }),
          const SizedBox(height: 14),
          TextFormField(
            controller: _nameController,
            textAlign: TextAlign.right,
            decoration: InputDecoration(
              labelText: 'اسم ولي الأمر ثلاثي *',
              hintText: 'مثال: محمد عبد العزيز سالم',
              prefixIcon: const Icon(Icons.person_outline),
              border: OutlineInputBorder(borderRadius: BorderRadius.circular(12)),
              contentPadding: const EdgeInsets.symmetric(horizontal: 14, vertical: 12),
            ),
            validator: (v) {
              if (v == null || v.trim().isEmpty) return 'يرجى إدخال اسم ولي الأمر';
              if (v.trim().split(RegExp(r'\s+')).length < 2) {
                return 'يرجى كتابة الاسم ثنائياً أو ثلاثياً على الأقل';
              }
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
          const SizedBox(height: 18),
          ElevatedButton(
            onPressed: _isSubmitting ? null : _submitRequest,
            style: ElevatedButton.styleFrom(
              backgroundColor: Colors.amber.shade800,
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
                : const Text(
                    'إرسال طلب التفعيل المباشر',
                    style: TextStyle(fontSize: 15, fontWeight: FontWeight.bold),
                  ),
          ),
        ],
      ),
    );
  }
}
