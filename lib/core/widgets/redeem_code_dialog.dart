import 'package:flutter/material.dart';
import '../services/licensing_api_service.dart';
import '../theme/app_theme.dart';

Future<bool?> showRedeemCodeDialog(BuildContext context) {
  final isAr = Directionality.of(context) == TextDirection.rtl;
  final codeController = TextEditingController();
  bool isLoading = false;
  String? errorMessage;

  return showDialog<bool>(
    context: context,
    builder: (dialogCtx) {
      return StatefulBuilder(
        builder: (context, setDialogState) {
          return AlertDialog(
            shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(24)),
            title: Row(
              children: [
                Container(
                  padding: const EdgeInsets.all(8),
                  decoration: BoxDecoration(
                    color: Colors.amber.withValues(alpha: 0.2),
                    shape: BoxShape.circle,
                  ),
                  child: const Icon(
                    Icons.vpn_key_rounded,
                    color: Colors.amber,
                    size: 26,
                  ),
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: Text(
                    isAr ? 'تفعيل كود ترقية VIP' : 'Redeem VIP License',
                    style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 18),
                  ),
                ),
              ],
            ),
            content: Column(
              mainAxisSize: MainAxisSize.min,
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  isAr
                      ? 'إذا حصلت على كود تفعيل من الدعم الفني أو البوابة، أدخله هنا لتفعيل اشتراكك فوراً:'
                      : 'Enter your official license or VIP key to activate Brainquests Pro instantly:',
                  style: const TextStyle(fontSize: 13, color: Colors.black87, height: 1.4),
                ),
                const SizedBox(height: 16),
                TextField(
                  controller: codeController,
                  textCapitalization: TextCapitalization.characters,
                  autocorrect: false,
                  decoration: InputDecoration(
                    hintText: 'BRAIN-VIP-XXXX',
                    prefixIcon: const Icon(Icons.password_rounded, color: AppTheme.primaryBlue),
                    border: OutlineInputBorder(borderRadius: BorderRadius.circular(14)),
                    filled: true,
                    fillColor: Colors.grey.shade50,
                    errorText: errorMessage,
                  ),
                ),
              ],
            ),
            actions: [
              TextButton(
                onPressed: isLoading ? null : () => Navigator.pop(dialogCtx, false),
                child: Text(isAr ? 'إلغاء' : 'Cancel'),
              ),
              ElevatedButton(
                onPressed: isLoading
                    ? null
                    : () async {
                        final code = codeController.text.trim();
                        if (code.isEmpty) {
                          setDialogState(() {
                            errorMessage = isAr ? 'يرجى إدخال الكود' : 'Please enter code';
                          });
                          return;
                        }

                        setDialogState(() {
                          isLoading = true;
                          errorMessage = null;
                        });

                        final result = await LicensingApiService().redeemCode(code);

                        if (result['status'] == 'success') {
                          if (context.mounted) {
                            Navigator.pop(dialogCtx, true);
                            ScaffoldMessenger.of(context).showSnackBar(
                              SnackBar(
                                content: Text(
                                  isAr
                                      ? '🎉 تم تفعيل باقة Brainquests Pro بنجاح!'
                                      : '🎉 Brainquests Pro activated successfully!',
                                  style: const TextStyle(fontWeight: FontWeight.bold),
                                ),
                                backgroundColor: AppTheme.mintGreen,
                              ),
                            );
                          }
                        } else {
                          setDialogState(() {
                            isLoading = false;
                            errorMessage = result['message'] ?? (isAr ? 'كود غير صحيح' : 'Invalid code');
                          });
                        }
                      },
                style: ElevatedButton.styleFrom(
                  backgroundColor: AppTheme.primaryBlue,
                  foregroundColor: Colors.white,
                  shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                  padding: const EdgeInsets.symmetric(horizontal: 18, vertical: 10),
                ),
                child: isLoading
                    ? const SizedBox(
                        width: 18,
                        height: 18,
                        child: CircularProgressIndicator(strokeWidth: 2, color: Colors.white),
                      )
                    : Text(
                        isAr ? 'تفعيل الآن' : 'Redeem Now',
                        style: const TextStyle(fontWeight: FontWeight.bold),
                      ),
              ),
            ],
          );
        },
      );
    },
  );
}

