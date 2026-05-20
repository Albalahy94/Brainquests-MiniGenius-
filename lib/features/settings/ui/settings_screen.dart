import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
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
