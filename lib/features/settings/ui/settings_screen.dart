import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:url_launcher/url_launcher.dart';
import 'package:minigenius/core/widgets/parental_gate_dialog.dart';
import 'package:minigenius/core/widgets/redeem_code_dialog.dart';
import '../../parent_dashboard/ui/parent_account_dialog.dart';
import 'package:minigenius/generated/l10n/app_localizations.dart';
import 'package:minigenius/core/theme/app_theme.dart';
import 'package:minigenius/core/providers/app_state_provider.dart';
import 'package:minigenius/core/routes/app_routes.dart';
import 'package:minigenius/core/services/storage_service.dart';

class SettingsScreen extends StatelessWidget {
  const SettingsScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context)!;
    final appState = context.watch<AppStateProvider>();
    final theme = Theme.of(context);

    return Scaffold(
      appBar: AppBar(
        title: Text(l10n.settings),
        centerTitle: true,
      ),
      body: ListView(
        children: [
          _buildSectionHeader(context, 'Brainquests Pro 👑'),
          ListTile(
            leading: const Icon(Icons.workspace_premium_rounded, color: Color(0xFFFFB300), size: 28),
            title: const Text('ترقية الحساب / إدارة الاشتراك', style: TextStyle(fontWeight: FontWeight.bold)),
            subtitle: const Text('فتح +100 مستوى ورادار الذكاء المعرفي وثيمات الألعاب'),
            trailing: const Icon(Icons.arrow_forward_ios, size: 16),
            onTap: () async {
              final isParent = await showParentalGateDialog(context);
              if (isParent && context.mounted) {
                Navigator.pushNamed(context, AppRoutes.premium);
              }
            },
          ),
          ListTile(
            leading: const Icon(Icons.vpn_key_rounded, color: AppTheme.primaryBlue, size: 26),
            title: const Text('تفعيل كود ترقية VIP', style: TextStyle(fontWeight: FontWeight.bold)),
            subtitle: const Text('إدخال كود الترخيص الصادر من بوابة البلحي أو الدعم الفني'),
            trailing: const Icon(Icons.arrow_forward_ios, size: 16),
            onTap: () async {
              final isParent = await showParentalGateDialog(context);
              if (isParent && context.mounted) {
                await showRedeemCodeDialog(context);
              }
            },
          ),
          ListTile(
            leading: const Icon(Icons.account_circle_outlined, color: Colors.teal, size: 26),
            title: const Text('حساب ولي الأمر (Parent Account)', style: TextStyle(fontWeight: FontWeight.bold)),
            subtitle: const Text('ربط الهاتف بالبورتال، حفظ الاشتراكات، ومزامنة VIP'),
            trailing: const Icon(Icons.arrow_forward_ios, size: 16),
            onTap: () async {
              final isParent = await showParentalGateDialog(context);
              if (isParent && context.mounted) {
                await ParentAccountDialog.show(context);
              }
            },
          ),
          const Divider(),
          _buildSectionHeader(context, l10n.appearance),
          
          // Dark Mode Switch
          ListTile(
            leading: Icon(
              appState.isDarkMode ? Icons.dark_mode : Icons.light_mode,
              color: theme.colorScheme.primary,
            ),
            title: Text(l10n.darkMode),
            trailing: Switch(
              value: appState.isDarkMode,
              onChanged: (bool? value) => appState.toggleDarkMode(value ?? false),
            ),
          ),

          // Language Selection
          ListTile(
            leading: Icon(Icons.language, color: theme.colorScheme.primary),
            title: Text(l10n.language),
            subtitle: Text(appState.locale.languageCode == 'ar' ? l10n.arabic : l10n.english),
            onTap: () => _showLanguageDialog(context, appState, l10n),
          ),

          const Divider(),
          _buildSectionHeader(context, l10n.legal),

          // Privacy Policy
          ListTile(
            leading: Icon(Icons.privacy_tip_outlined, color: theme.colorScheme.primary),
            title: Text(l10n.privacyPolicy),
            trailing: const Icon(Icons.arrow_forward_ios, size: 16),
            onTap: () {
              Navigator.pushNamed(context, AppRoutes.privacyPolicy);
            },
          ),

          // Delete Account
          ListTile(
            leading: const Icon(Icons.delete_forever_outlined, color: Colors.redAccent),
            title: Text(l10n.deleteAccount, style: const TextStyle(color: Colors.redAccent)),
            onTap: () => _showDeleteAccountDialog(context, l10n),
          ),

          // About
          ListTile(
            leading: Icon(Icons.info_outline, color: theme.colorScheme.primary),
            title: Text(l10n.about),
            subtitle: const Text('MiniGenius v2.0.0'),
            onTap: () {
              showAboutDialog(
                context: context,
                applicationName: 'Mini Genius',
                applicationVersion: '2.0.0',
                applicationIcon: Padding(
                  padding: const EdgeInsets.all(8.0),
                  child: Image.asset('assets/images/logo.png', width: 48, errorBuilder: (_, __, ___) => const Icon(Icons.auto_awesome, size: 48, color: AppTheme.primaryBlue)),
                ),
                applicationLegalese: '© 2026 Mini Genius Team',
              );
            },
          ),
          
          // Contact Developer
          ListTile(
            leading: Icon(Icons.email_outlined, color: theme.colorScheme.primary),
            title: Text(l10n.contactDeveloper),
            trailing: const Icon(Icons.open_in_new, size: 16),
            onTap: () async {
              final isParent = await showParentalGateDialog(context);
              if (isParent && context.mounted) {
                final Uri emailLaunchUri = Uri(
                  scheme: 'mailto',
                  path: 'mohamed@albalahy4u.com',
                  query: 'subject=Mini Genius App Support',
                );
                try {
                  if (!await launchUrl(emailLaunchUri)) {
                    // Ignore
                  }
                } catch (e) {
                  // Ignore
                }
              }
            },
          ),

          // WhatsApp Direct Support
          ListTile(
            leading: Container(
              padding: const EdgeInsets.all(6),
              decoration: BoxDecoration(
                color: const Color(0xFF25D366),
                borderRadius: BorderRadius.circular(8),
              ),
              child: const Icon(Icons.chat_rounded, color: Colors.white, size: 20),
            ),
            title: const Text(
              'الدعم الفني المباشر (WhatsApp)',
              style: TextStyle(fontWeight: FontWeight.bold),
            ),
            subtitle: const Text('+20 106 748 1561 - متاح للمساعدة الفورية وتفعيل الاشتراكات'),
            trailing: const Icon(Icons.open_in_new, size: 16, color: Color(0xFF25D366)),
            onTap: () async {
              final isParent = await showParentalGateDialog(context);
              if (isParent && context.mounted) {
                final Uri waUri = Uri.parse(
                  'https://wa.me/201067481561?text=${Uri.encodeComponent("مرحباً، أطلب الدعم الفني لتطبيق Brainquests v2")}',
                );
                try {
                  await launchUrl(waUri, mode: LaunchMode.externalApplication);
                } catch (e) {
                  ScaffoldMessenger.of(context).showSnackBar(
                    const SnackBar(
                      content: Text('تعذر فتح واتساب، يرجى التواصل على الرقم: 01067481561'),
                    ),
                  );
                }
              }
            },
          ),

          const SizedBox(height: 40),
        ],
      ),
    );
  }

  Widget _buildSectionHeader(BuildContext context, String title) {
    return Padding(
      padding: const EdgeInsets.fromLTRB(16, 24, 16, 8),
      child: Text(
        title.toUpperCase(),
        style: Theme.of(context).textTheme.labelMedium?.copyWith(
              color: Theme.of(context).colorScheme.primary,
              fontWeight: FontWeight.bold,
              letterSpacing: 1.2,
            ),
      ),
    );
  }

  void _showDeleteAccountDialog(BuildContext context, AppLocalizations l10n) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: Text(l10n.deleteAccountConfirmTitle, style: const TextStyle(color: Colors.redAccent)),
        content: Text(l10n.deleteAccountConfirmMessage),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: Text(l10n.cancel),
          ),
          ElevatedButton(
            style: ElevatedButton.styleFrom(backgroundColor: Colors.redAccent),
            onPressed: () async {
              Navigator.pop(context); // Close dialog
              await StorageService().clearAllData();
              if (context.mounted) {
                // Return to splash screen to restart app flow
                Navigator.pushNamedAndRemoveUntil(context, AppRoutes.splash, (route) => false);
              }
            },
            child: Text(l10n.deleteAccountConfirmButton, style: const TextStyle(color: Colors.white)),
          ),
        ],
      ),
    );
  }

  void _showLanguageDialog(BuildContext context, AppStateProvider appState, AppLocalizations l10n) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: Text(l10n.language),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            ListTile(
              title: Text(l10n.english),
              leading: Radio<String>(
                value: 'en',
                groupValue: appState.locale.languageCode,
                onChanged: (value) {
                  appState.setLanguage(value!);
                  Navigator.pop(context);
                },
              ),
              onTap: () {
                appState.setLanguage('en');
                Navigator.pop(context);
              },
            ),
            ListTile(
              title: Text(l10n.arabic),
              leading: Radio<String>(
                value: 'ar',
                groupValue: appState.locale.languageCode,
                onChanged: (value) {
                  appState.setLanguage(value!);
                  Navigator.pop(context);
                },
              ),
              onTap: () {
                appState.setLanguage('ar');
                Navigator.pop(context);
              },
            ),
          ],
        ),
      ),
    );
  }
}
