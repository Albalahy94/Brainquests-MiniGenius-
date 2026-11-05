import 'package:flutter/material.dart';
import 'package:url_launcher/url_launcher.dart';
import '../../../core/theme/app_theme.dart';
import '../../../core/services/iap_service.dart';
import '../../../core/routes/app_routes.dart';
import '../../../core/widgets/redeem_code_dialog.dart';
import '../../../core/widgets/direct_subscription_dialog.dart';

class PremiumScreen extends StatefulWidget {
  const PremiumScreen({super.key});

  @override
  State<PremiumScreen> createState() => _PremiumScreenState();
}

class _PremiumScreenState extends State<PremiumScreen> {
  final IAPService _iapService = IAPService();
  bool _isLoading = false;
  int _selectedPlanIndex = 0; // 0 = Yearly (Best Value), 1 = Monthly, 2 = Lifetime

  @override
  void initState() {
    super.initState();
    _iapService.loadProducts();
  }

  Future<void> _handlePurchase() async {
    setState(() {
      _isLoading = true;
    });

    try {
      bool success = false;
      if (_selectedPlanIndex == 0) {
        success = await _iapService.purchaseYearly();
      } else if (_selectedPlanIndex == 1) {
        success = await _iapService.purchaseMonthly();
      } else {
        success = await _iapService.purchaseLifetime();
      }

      if (success) {
        if (mounted) {
          final isAr = Directionality.of(context) == TextDirection.rtl;
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
              content: Text(isAr
                  ? 'تم تفعيل اشتراك Brainquests Pro بنجاح! 🎉'
                  : 'Brainquests Pro activated successfully! 🎉'),
              backgroundColor: AppTheme.mintGreen,
            ),
          );
          Navigator.pop(context, true);
        }
      } else {
        if (mounted) {
          final isAr = Directionality.of(context) == TextDirection.rtl;
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
              content: Text(isAr
                  ? 'تعذر إتمام عملية الشراء. يرجى المحاولة مرة أخرى.'
                  : 'Purchase could not be completed. Please try again.'),
              backgroundColor: Colors.red,
            ),
          );
        }
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Error: $e'),
            backgroundColor: Colors.red,
          ),
        );
      }
    } finally {
      if (mounted) {
        setState(() {
          _isLoading = false;
        });
      }
    }
  }

  Future<void> _restorePurchases() async {
    setState(() {
      _isLoading = true;
    });

    try {
      await _iapService.restorePurchases();
      if (mounted) {
        final isAr = Directionality.of(context) == TextDirection.rtl;
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(isAr
                ? 'تم استعادة مشترياتك بنجاح!'
                : 'Purchases restored successfully!'),
            backgroundColor: AppTheme.mintGreen,
          ),
        );
        Navigator.pop(context, true);
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Error: $e'),
            backgroundColor: Colors.red,
          ),
        );
      }
    } finally {
      if (mounted) {
        setState(() {
          _isLoading = false;
        });
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    final isAr = Directionality.of(context) == TextDirection.rtl;
    final yearlyProduct = _iapService.getYearlyProduct();
    final monthlyProduct = _iapService.getMonthlyProduct();
    final lifetimeProduct = _iapService.getLifetimeProduct();

    final yearlyPrice = yearlyProduct?.price ?? '\$39.99';
    final monthlyPrice = monthlyProduct?.price ?? '\$4.99';
    final lifetimePrice = lifetimeProduct?.price ?? '\$79.99';

    return Scaffold(
      body: Container(
        decoration: const BoxDecoration(
          gradient: LinearGradient(
            colors: [Color(0xFF0F172A), Color(0xFF1E1B4B), Color(0xFF311042)],
            begin: Alignment.topCenter,
            end: Alignment.bottomCenter,
          ),
        ),
        child: SafeArea(
          child: Column(
            children: [
              // Header bar
              Padding(
                padding: const EdgeInsets.symmetric(horizontal: 16.0, vertical: 8.0),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    IconButton(
                      icon: const Icon(Icons.close_rounded, color: Colors.white70, size: 28),
                      onPressed: () => Navigator.pop(context),
                    ),
                    TextButton(
                      onPressed: _isLoading ? null : _restorePurchases,
                      child: Text(
                        isAr ? 'استعادة المشتريات' : 'Restore',
                        style: const TextStyle(
                          color: Colors.amberAccent,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                    ),
                  ],
                ),
              ),

              // Scrollable content
              Expanded(
                child: SingleChildScrollView(
                  padding: const EdgeInsets.symmetric(horizontal: 20.0),
                  child: Column(
                    children: [
                      // Golden glowing crown badge
                      Container(
                        width: 90,
                        height: 90,
                        decoration: BoxDecoration(
                          gradient: const LinearGradient(
                            colors: [Color(0xFFFFD54F), Color(0xFFFF9800)],
                            begin: Alignment.topLeft,
                            end: Alignment.bottomRight,
                          ),
                          shape: BoxShape.circle,
                          boxShadow: [
                            BoxShadow(
                              color: const Color(0xFFFF9800).withOpacity(0.5),
                              blurRadius: 20,
                              offset: const Offset(0, 6),
                            ),
                          ],
                        ),
                        child: const Icon(
                          Icons.workspace_premium_rounded,
                          size: 54,
                          color: Color(0xFF2E1500),
                        ),
                      ),
                      const SizedBox(height: 16),

                      Text(
                        isAr ? 'Brainquests Pro' : 'Brainquests Pro',
                        style: const TextStyle(
                          color: Colors.white,
                          fontSize: 28,
                          fontWeight: FontWeight.w900,
                          letterSpacing: 0.5,
                        ),
                      ),
                      const SizedBox(height: 6),
                      Text(
                        isAr
                            ? 'أطلق العنان لقدرات طفلك الذهنية مع المحتوى الاحترافي'
                            : 'Unlock your child\'s full cognitive potential',
                        textAlign: TextAlign.center,
                        style: TextStyle(
                          color: Colors.white.withOpacity(0.8),
                          fontSize: 14,
                        ),
                      ),
                      const SizedBox(height: 24),

                      // Subscription Plans Selector
                      _buildPlanCard(
                        index: 0,
                        title: isAr ? 'الاشتراك السنوي' : 'Annual Plan',
                        price: yearlyPrice,
                        subtext: isAr ? 'فقط \$3.33 / شهر (وفر 40%)' : 'Just \$3.33 / month (Save 40%)',
                        badge: isAr ? 'الأكثر توفيراً + 7 أيام مجاناً 👑' : 'BEST VALUE + 7 DAYS FREE 👑',
                        isSelected: _selectedPlanIndex == 0,
                      ),
                      const SizedBox(height: 12),

                      _buildPlanCard(
                        index: 1,
                        title: isAr ? 'الاشتراك الشهري' : 'Monthly Plan',
                        price: monthlyPrice,
                        subtext: isAr ? 'تجديد شهري مرن، إلغاء في أي وقت' : 'Flexible monthly renewal, cancel anytime',
                        isSelected: _selectedPlanIndex == 1,
                      ),
                      const SizedBox(height: 12),

                      _buildPlanCard(
                        index: 2,
                        title: isAr ? 'العضوية الدائمة (مدى الحياة)' : 'Lifetime Family Pass',
                        price: lifetimePrice,
                        subtext: isAr ? 'دفعة واحدة لجميع أطفالك مدى الحياة' : 'One-time payment for all children forever',
                        isSelected: _selectedPlanIndex == 2,
                      ),
                      const SizedBox(height: 16),

                      // Promo Code Banner
                      InkWell(
                        onTap: () async {
                          final success = await showRedeemCodeDialog(context);
                          if (success == true && mounted) {
                            Navigator.pop(context, true);
                          }
                        },
                        borderRadius: BorderRadius.circular(16),
                        child: Container(
                          padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
                          decoration: BoxDecoration(
                            color: Colors.white.withOpacity(0.08),
                            borderRadius: BorderRadius.circular(16),
                            border: Border.all(color: Colors.white24),
                          ),
                          child: Row(
                            children: [
                              const Icon(Icons.vpn_key_rounded, color: Colors.amber, size: 22),
                              const SizedBox(width: 10),
                              Expanded(
                                child: Text(
                                  isAr ? 'هل تمتلك كود تفعيل أو ترخيص مسبق؟' : 'Have a license or promo code?',
                                  style: const TextStyle(color: Colors.white, fontSize: 13, fontWeight: FontWeight.w600),
                                ),
                              ),
                              Text(
                                isAr ? 'تفعيل الكود' : 'Redeem',
                                style: const TextStyle(color: Colors.amber, fontWeight: FontWeight.bold, fontSize: 13),
                              ),
                            ],
                          ),
                        ),
                      ),
                      const SizedBox(height: 12),

                      // Direct Subscription Request Banner
                      InkWell(
                        onTap: () {
                          DirectSubscriptionDialog.show(
                            context,
                            initialPlanId: _selectedPlanIndex == 0
                                ? 'yearly'
                                : (_selectedPlanIndex == 1 ? 'monthly' : 'lifetime'),
                          );
                        },
                        borderRadius: BorderRadius.circular(16),
                        child: Container(
                          padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
                          decoration: BoxDecoration(
                            gradient: LinearGradient(
                              colors: [
                                Colors.teal.shade700.withOpacity(0.4),
                                Colors.teal.shade900.withOpacity(0.3),
                              ],
                            ),
                            borderRadius: BorderRadius.circular(16),
                            border: Border.all(color: Colors.tealAccent.withOpacity(0.4)),
                          ),
                          child: Row(
                            children: [
                              const Icon(Icons.flash_on_rounded, color: Colors.tealAccent, size: 22),
                              const SizedBox(width: 10),
                              Expanded(
                                child: Text(
                                  isAr
                                      ? 'دفع محلي عبر إنستاباي أو فودافون كاش؟'
                                      : 'Local payment via InstaPay / Vodafone Cash?',
                                  style: const TextStyle(
                                      color: Colors.white, fontSize: 13, fontWeight: FontWeight.w600),
                                ),
                              ),
                              Text(
                                isAr ? 'طلب اشتراك مباشر' : 'Direct Request',
                                style: const TextStyle(
                                    color: Colors.tealAccent, fontWeight: FontWeight.bold, fontSize: 13),
                              ),
                            ],
                          ),
                        ),
                      ),
                      const SizedBox(height: 20),

                      // Features List
                      Container(
                        padding: const EdgeInsets.all(16),
                        decoration: BoxDecoration(
                          color: Colors.white.withOpacity(0.06),
                          borderRadius: BorderRadius.circular(20),
                          border: Border.all(color: Colors.white.withOpacity(0.12)),
                        ),
                        child: Column(
                          children: [
                            _buildFeatureRow(
                              Icons.extension_rounded,
                              isAr ? '+100 مستوى احترافي جديد' : '+100 New Pro Levels',
                              isAr
                                  ? 'فتح المراحل 11-20 في جميع الألعاب العشر الموجودة'
                                  : 'Unlock Levels 11-20 across all 10 core games',
                            ),
                            const Divider(color: Colors.white12, height: 20),
                            _buildFeatureRow(
                              Icons.category_rounded,
                              isAr ? 'أشكال وثيمات حصرية لكل لعبة' : 'Exclusive Themes & Shapes',
                              isAr
                                  ? 'أشكال هندسية مركبة، بطاقات الفضاء والديناصورات، وألغاز متقدمة'
                                  : 'New geometric shapes, cosmic & dino cards, advanced puzzles',
                            ),
                            const Divider(color: Colors.white12, height: 20),
                            _buildFeatureRow(
                              Icons.psychology_rounded,
                              isAr ? 'رادار النمو والذكاء المعرفي' : 'Cognitive Development Radar',
                              isAr
                                  ? 'تحليلات ذكية لقياس الذاكرة، المنطق، وسرعة البديهة في لوحة الوالدين'
                                  : 'Smart analytics tracking memory, logic & speed in parent dashboard',
                            ),
                            const Divider(color: Colors.white12, height: 20),
                            _buildFeatureRow(
                              Icons.card_membership_rounded,
                              isAr ? 'شهادات إنجاز شهرية قابلة للطباعة' : 'Printable Achievement Certificates',
                              isAr
                                  ? 'تصدير شهادات PDF رسمية باسم الطفل لتعليقها وتشجيعه'
                                  : 'Export official PDF certificates with your child\'s name',
                            ),
                            const Divider(color: Colors.white12, height: 20),
                            _buildFeatureRow(
                              Icons.shield_rounded,
                              isAr ? '100% آمن وخالٍ تماماً من الإعلانات' : '100% Ad-Free & Child-Safe',
                              isAr
                                  ? 'بيئة تعليمية نظيفة ومطابقة لأعلى معايير حماية الأطفال'
                                  : 'Compliant with Apple Kids Category & COPPA standards',
                            ),
                          ],
                        ),
                      ),
                      const SizedBox(height: 16),

                      // Legal terms & disclaimers
                      Text(
                        isAr
                            ? 'يتم تجديد الاشتراك تلقائياً ما لم يتم الإلغاء قبل 24 ساعة من نهاية الفترة الحالية. يمكنك إدارة أو إلغاء اشتراكك في أي وقت من إعدادات حساب متجر التطبيقات.'
                            : 'Subscription automatically renews unless cancelled at least 24 hours before the end of the current period. Manage your subscription in your App Store account settings.',
                        textAlign: TextAlign.center,
                        style: TextStyle(
                          color: Colors.white.withOpacity(0.5),
                          fontSize: 11,
                          height: 1.4,
                        ),
                      ),
                      const SizedBox(height: 8),

                      // Privacy Policy & Terms of Use links (Apple Guideline 3.1.2)
                      Row(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          TextButton(
                            onPressed: () {
                              Navigator.pushNamed(context, AppRoutes.privacyPolicy);
                            },
                            child: Text(
                              isAr ? 'سياسة الخصوصية' : 'Privacy Policy',
                              style: TextStyle(
                                color: Colors.white.withOpacity(0.7),
                                fontSize: 12,
                                decoration: TextDecoration.underline,
                              ),
                            ),
                          ),
                          const Text(' • ', style: TextStyle(color: Colors.white38)),
                          TextButton(
                            onPressed: () async {
                              final Uri eulaUri = Uri.parse(
                                'https://www.apple.com/legal/internet-services/itunes/dev/stdeula/',
                              );
                              try {
                                await launchUrl(eulaUri, mode: LaunchMode.externalApplication);
                              } catch (_) {}
                            },
                            child: Text(
                              isAr ? 'شروط الاستخدام (EULA)' : 'Terms of Use (EULA)',
                              style: TextStyle(
                                color: Colors.white.withOpacity(0.7),
                                fontSize: 12,
                                decoration: TextDecoration.underline,
                              ),
                            ),
                          ),
                        ],
                      ),
                      const SizedBox(height: 12),
                    ],
                  ),
                ),
              ),

              // Purchase CTA Bottom Button
              Padding(
                padding: const EdgeInsets.symmetric(horizontal: 20.0, vertical: 12.0),
                child: SizedBox(
                  width: double.infinity,
                  child: ElevatedButton(
                    onPressed: _isLoading ? null : _handlePurchase,
                    style: ElevatedButton.styleFrom(
                      backgroundColor: const Color(0xFFFFB300),
                      foregroundColor: const Color(0xFF2E1500),
                      padding: const EdgeInsets.symmetric(vertical: 18),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(18),
                      ),
                      elevation: 6,
                    ),
                    child: _isLoading
                        ? const SizedBox(
                            width: 24,
                            height: 24,
                            child: CircularProgressIndicator(
                              strokeWidth: 2.5,
                              valueColor: AlwaysStoppedAnimation<Color>(Color(0xFF2E1500)),
                            ),
                          )
                        : Text(
                            _selectedPlanIndex == 0
                                ? (isAr ? 'ابدأ التجربة المجانية (7 أيام) 🚀' : 'Start 7-Day Free Trial 🚀')
                                : (isAr ? 'الترقية إلى Brainquests Pro 👑' : 'Upgrade to Brainquests Pro 👑'),
                            style: const TextStyle(
                              fontSize: 18,
                              fontWeight: FontWeight.w900,
                            ),
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

  Widget _buildPlanCard({
    required int index,
    required String title,
    required String price,
    required String subtext,
    String? badge,
    required bool isSelected,
  }) {
    return GestureDetector(
      onTap: () {
        setState(() {
          _selectedPlanIndex = index;
        });
      },
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 200),
        padding: const EdgeInsets.all(16),
        decoration: BoxDecoration(
          color: isSelected ? const Color(0xFFFFB300).withOpacity(0.15) : Colors.white.withOpacity(0.05),
          borderRadius: BorderRadius.circular(18),
          border: Border.all(
            color: isSelected ? const Color(0xFFFFB300) : Colors.white.withOpacity(0.15),
            width: isSelected ? 2.5 : 1,
          ),
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            if (badge != null) ...[
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 3),
                margin: const EdgeInsets.only(bottom: 8),
                decoration: BoxDecoration(
                  gradient: const LinearGradient(
                    colors: [Color(0xFFFFD54F), Color(0xFFFF8F00)],
                  ),
                  borderRadius: BorderRadius.circular(8),
                ),
                child: Text(
                  badge,
                  style: const TextStyle(
                    color: Color(0xFF2E1500),
                    fontSize: 11,
                    fontWeight: FontWeight.w900,
                  ),
                ),
              ),
            ],
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        title,
                        style: TextStyle(
                          color: isSelected ? Colors.white : Colors.white70,
                          fontSize: 17,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                      const SizedBox(height: 4),
                      Text(
                        subtext,
                        style: TextStyle(
                          color: isSelected ? Colors.white.withOpacity(0.85) : Colors.white54,
                          fontSize: 13,
                        ),
                      ),
                    ],
                  ),
                ),
                const SizedBox(width: 8),
                Text(
                  price,
                  style: TextStyle(
                    color: isSelected ? const Color(0xFFFFD54F) : Colors.white,
                    fontSize: 20,
                    fontWeight: FontWeight.w900,
                  ),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildFeatureRow(IconData icon, String title, String subtitle) {
    return Row(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Container(
          padding: const EdgeInsets.all(8),
          decoration: BoxDecoration(
            color: const Color(0xFFFFB300).withOpacity(0.15),
            shape: BoxShape.circle,
          ),
          child: Icon(icon, color: const Color(0xFFFFD54F), size: 20),
        ),
        const SizedBox(width: 12),
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                title,
                style: const TextStyle(
                  color: Colors.white,
                  fontSize: 15,
                  fontWeight: FontWeight.bold,
                ),
              ),
              const SizedBox(height: 2),
              Text(
                subtitle,
                style: TextStyle(
                  color: Colors.white.withOpacity(0.7),
                  fontSize: 12.5,
                  height: 1.3,
                ),
              ),
            ],
          ),
        ),
      ],
    );
  }
}
