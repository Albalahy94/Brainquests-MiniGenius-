import 'package:flutter/material.dart';
import 'package:minigenius/generated/l10n/app_localizations.dart';

class PrivacyPolicyScreen extends StatelessWidget {
  const PrivacyPolicyScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context)!;
    final theme = Theme.of(context);

    return Scaffold(
      appBar: AppBar(
        title: Text(l10n.privacyPolicy),
        centerTitle: true,
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(24.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              'Privacy Policy for Mini Genius',
              style: theme.textTheme.headlineSmall?.copyWith(fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: 16),
            Text(
              'Last updated: March 21, 2026',
              style: theme.textTheme.bodySmall,
            ),
            const SizedBox(height: 24),
            _buildSection(
              context,
              '1. Introduction',
              'Mini Genius ("we", "our", or "us") is committed to protecting your privacy. This Privacy Policy explains how we handle information in our mobile application.',
            ),
            _buildSection(
              context,
              '2. Children\'s Privacy',
              'Our app is designed for children. We do not knowingly collect any personally identifiable information from children under the age of 13. All data processed is stored locally on the device or handled anonymously through third-party services like AdMob (child-directed).',
            ),
            _buildSection(
              context,
              '3. Information Collection',
              'We do not collect personal information such as names, addresses, or phone numbers. We may collect non-personal information such as game progress and settings, which are stored locally on your device.',
            ),
            _buildSection(
              context,
              '4. Data Deletion and Account Removal',
              'Because Mini Genius does not use a central server to store your personal accounts, there is no online account to delete. However, you can delete all your local data at any time by going to the Settings menu and selecting "Delete Account Data". This will permanently wipe all local progress, coins, and settings from your device.',
            ),
            _buildSection(
              context,
              '5. Advertisements',
              'We use Google AdMob to display advertisements. These ads are configured to be "child-directed" to ensure they are appropriate for our audience and comply with COPPA and GPDR-K regulations.',
            ),
            _buildSection(
              context,
              '6. Contact Us',
              'If you have any questions about this Privacy Policy, please contact us at: mohamed@albalahy4u.com',
            ),
            const SizedBox(height: 40),
          ],
        ),
      ),
    );
  }

  Widget _buildSection(BuildContext context, String title, String content) {
    final theme = Theme.of(context);
    return Padding(
      padding: const EdgeInsets.only(bottom: 24.0),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            title,
            style: theme.textTheme.titleMedium?.copyWith(
              fontWeight: FontWeight.bold,
              color: theme.colorScheme.primary,
            ),
          ),
          const SizedBox(height: 8),
          Text(
            content,
            style: theme.textTheme.bodyMedium?.copyWith(height: 1.5),
          ),
        ],
      ),
    );
  }
}
