import 'package:flutter/material.dart';
import '../../../core/theme/app_theme.dart';
import '../../../core/services/iap_service.dart';

class PremiumScreen extends StatefulWidget {
  const PremiumScreen({super.key});

  @override
  State<PremiumScreen> createState() => _PremiumScreenState();
}

class _PremiumScreenState extends State<PremiumScreen> {
  final IAPService _iapService = IAPService();
  bool _isLoading = false;

  @override
  void initState() {
    super.initState();
    _iapService.loadProducts();
  }

  Future<void> _purchasePremium() async {
    setState(() {
      _isLoading = true;
    });

    try {
      final success = await _iapService.purchasePremium();
      if (success) {
        if (mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(
              content: Text('Premium activated!'),
              backgroundColor: AppTheme.mintGreen,
            ),
          );
          Navigator.pop(context);
        }
      } else {
        if (mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(
              content: Text('Purchase failed. Please try again.'),
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
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('Purchases restored!'),
            backgroundColor: AppTheme.mintGreen,
          ),
        );
        Navigator.pop(context);
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
    final product = _iapService.getPremiumProduct();
    final price = product?.price ?? '\$1.99';

    return Scaffold(
      appBar: AppBar(
        title: const Text('Go Premium'),
      ),
      body: Container(
        decoration: const BoxDecoration(
          gradient: AppTheme.blueGradient,
        ),
        child: SafeArea(
          child: Column(
            children: [
              Expanded(
                child: SingleChildScrollView(
                  padding: const EdgeInsets.all(24.0),
                  child: Column(
                    children: [
                      // Premium icon
                      Container(
                        width: 120,
                        height: 120,
                        decoration: BoxDecoration(
                          color: AppTheme.yellowAccent,
                          shape: BoxShape.circle,
                        ),
                        child: const Icon(
                          Icons.star,
                          size: 60,
                          color: AppTheme.darkText,
                        ),
                      ),
                      const SizedBox(height: 32),
                      // Title
                      Text(
                        'Unlock Premium',
                        style: Theme.of(context).textTheme.displayMedium?.copyWith(
                              color: AppTheme.white,
                              fontWeight: FontWeight.bold,
                            ),
                      ),
                      const SizedBox(height: 16),
                      // Features
                      _buildFeature('Remove all ads'),
                      _buildFeature('Unlock all games'),
                      _buildFeature('Full sticker album'),
                      _buildFeature('Exclusive content'),
                      const SizedBox(height: 32),
                      // Price
                      Text(
                        price,
                        style: Theme.of(context).textTheme.displayLarge?.copyWith(
                              color: AppTheme.yellowAccent,
                              fontWeight: FontWeight.bold,
                            ),
                      ),
                      const SizedBox(height: 8),
                      Text(
                        'One-time purchase',
                        style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                              color: AppTheme.white,
                            ),
                      ),
                    ],
                  ),
                ),
              ),
              // Purchase button
              Padding(
                padding: const EdgeInsets.all(24.0),
                child: Column(
                  children: [
                    SizedBox(
                      width: double.infinity,
                      child: ElevatedButton(
                        onPressed: _isLoading ? null : _purchasePremium,
                        style: ElevatedButton.styleFrom(
                          backgroundColor: AppTheme.yellowAccent,
                          foregroundColor: AppTheme.darkText,
                          padding: const EdgeInsets.symmetric(vertical: 16),
                        ),
                        child: _isLoading
                            ? const CircularProgressIndicator()
                            : Text(
                                'Purchase Premium',
                                style: Theme.of(context).textTheme.titleLarge,
                              ),
                      ),
                    ),
                    const SizedBox(height: 12),
                    TextButton(
                      onPressed: _isLoading ? null : _restorePurchases,
                      child: Text(
                        'Restore Purchases',
                        style: Theme.of(context).textTheme.bodyLarge?.copyWith(
                              color: AppTheme.white,
                            ),
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildFeature(String text) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 8.0),
      child: Row(
        children: [
          const Icon(Icons.check_circle, color: AppTheme.mintGreen),
          const SizedBox(width: 12),
          Expanded(
            child: Text(
              text,
              style: Theme.of(context).textTheme.titleMedium?.copyWith(
                    color: AppTheme.white,
                  ),
            ),
          ),
        ],
      ),
    );
  }
}

