import 'dart:math';
import 'package:flutter/material.dart';
import 'package:minigenius/generated/l10n/app_localizations.dart';

/// Apple Kids Category Parental Gate
/// Shows a simple math question that children cannot easily solve.
Future<bool> showParentalGateDialog(BuildContext context) async {
  final result = await showDialog<bool>(
    context: context,
    barrierDismissible: true,
    builder: (context) => const _ParentalGateDialog(),
  );
  return result ?? false;
}

class _ParentalGateDialog extends StatefulWidget {
  const _ParentalGateDialog();

  @override
  State<_ParentalGateDialog> createState() => _ParentalGateDialogState();
}

class _ParentalGateDialogState extends State<_ParentalGateDialog> {
  late int _num1;
  late int _num2;
  late int _correctAnswer;
  late List<int> _options;
  int? _selectedAnswer;
  bool _showError = false;

  @override
  void initState() {
    super.initState();
    _generateQuestion();
  }

  void _generateQuestion() {
    final rng = Random();
    // Use numbers 7-12 for multiplication
    _num1 = rng.nextInt(6) + 7; // 7 to 12
    _num2 = rng.nextInt(6) + 7; // 7 to 12
    _correctAnswer = _num1 * _num2;

    final wrongOptions = <int>{};
    while (wrongOptions.length < 3) {
      final offset = rng.nextInt(10) + 1;
      final wrong = rng.nextBool()
          ? _correctAnswer + offset
          : _correctAnswer - offset;
      if (wrong > 0 && wrong != _correctAnswer) {
        wrongOptions.add(wrong);
      }
    }

    _options = [_correctAnswer, ...wrongOptions]..shuffle();
    _selectedAnswer = null;
    _showError = false;
  }

  void _onOptionSelected(int value) {
    setState(() {
      _selectedAnswer = value;
      _showError = false;
    });
  }

  void _onConfirm() {
    if (_selectedAnswer == null) return;

    if (_selectedAnswer == _correctAnswer) {
      Navigator.of(context).pop(true);
    } else {
      setState(() {
        _showError = true;
      });
      Future.delayed(const Duration(milliseconds: 1200), () {
        if (mounted) {
          setState(() {
            _generateQuestion();
          });
        }
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context);
    final theme = Theme.of(context);
    final isAr = Localizations.localeOf(context).languageCode == 'ar';

    final title = l10n?.parentalGateTitle ?? (isAr ? 'التحقق من هوية الوالد' : 'Parent Verification');
    final desc = l10n?.parentalGateDescription ?? (isAr
        ? 'للأمان، يرجى حل العملية الحسابية البسيطة للمتابعة:'
        : 'For safety, please solve this math problem to continue:');
    final wrongText = l10n?.parentalGateWrongAnswer ?? (isAr ? 'إجابة خاطئة، يرجى المحاولة ثانية' : 'Incorrect answer, please try again');
    final cancelText = l10n?.cancel ?? (isAr ? 'إلغاء' : 'Cancel');
    final continueText = l10n?.parentalGateContinue ?? (isAr ? 'متابعة' : 'Continue');

    return AlertDialog(
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
      title: Row(
        children: [
          Icon(Icons.family_restroom, color: theme.colorScheme.primary, size: 28),
          const SizedBox(width: 10),
          Expanded(
            child: Text(
              title,
              style: theme.textTheme.titleLarge?.copyWith(
                fontWeight: FontWeight.bold,
              ),
            ),
          ),
        ],
      ),
      content: SingleChildScrollView(
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Text(
              desc,
              style: theme.textTheme.bodyMedium?.copyWith(height: 1.5),
              textAlign: TextAlign.center,
            ),
            const SizedBox(height: 20),

            // Math question box
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 14),
              decoration: BoxDecoration(
                color: theme.colorScheme.primary.withValues(alpha: 0.15),
                borderRadius: BorderRadius.circular(16),
              ),
              child: FittedBox(
                fit: BoxFit.scaleDown,
                child: Text(
                  '$_num1 × $_num2 = ?',
                  style: theme.textTheme.headlineMedium?.copyWith(
                    fontWeight: FontWeight.bold,
                    color: theme.colorScheme.primary,
                    letterSpacing: 2,
                  ),
                  textAlign: TextAlign.center,
                  textDirection: TextDirection.ltr,
                ),
              ),
            ),

            const SizedBox(height: 16),

            // Answer options in 2 rows
            Column(
              children: [
                Row(
                  children: [
                    Expanded(child: _buildOptionButton(_options[0], theme)),
                    const SizedBox(width: 10),
                    Expanded(child: _buildOptionButton(_options[1], theme)),
                  ],
                ),
                const SizedBox(height: 10),
                Row(
                  children: [
                    Expanded(child: _buildOptionButton(_options[2], theme)),
                    const SizedBox(width: 10),
                    Expanded(child: _buildOptionButton(_options[3], theme)),
                  ],
                ),
              ],
            ),

            if (_showError) ...[
              const SizedBox(height: 12),
              Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  const Icon(Icons.close_rounded, color: Colors.red, size: 18),
                  const SizedBox(width: 6),
                  Flexible(
                    child: Text(
                      wrongText,
                      style: const TextStyle(color: Colors.red, fontWeight: FontWeight.w600, fontSize: 13),
                      textAlign: TextAlign.center,
                    ),
                  ),
                ],
              ),
            ],
          ],
        ),
      ),
      actions: [
        TextButton(
          onPressed: () => Navigator.of(context).pop(false),
          child: Text(cancelText),
        ),
        ElevatedButton(
          onPressed: _selectedAnswer != null && !_showError ? _onConfirm : null,
          style: ElevatedButton.styleFrom(
            shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
          ),
          child: Text(continueText),
        ),
      ],
    );
  }

  Widget _buildOptionButton(int option, ThemeData theme) {
    final isSelected = _selectedAnswer == option;
    final isWrong = _showError && isSelected;

    return GestureDetector(
      onTap: () => _onOptionSelected(option),
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 200),
        padding: const EdgeInsets.symmetric(vertical: 12),
        decoration: BoxDecoration(
          color: isWrong
              ? Colors.red.shade100
              : isSelected
                  ? theme.colorScheme.primary
                  : Colors.grey.shade100,
          borderRadius: BorderRadius.circular(12),
          border: Border.all(
            color: isWrong
                ? Colors.red
                : isSelected
                    ? theme.colorScheme.primary
                    : Colors.grey.shade300,
            width: 2,
          ),
        ),
        child: Center(
          child: Text(
            '$option',
            style: TextStyle(
              fontSize: 18,
              fontWeight: FontWeight.bold,
              color: isWrong
                  ? Colors.red
                  : isSelected
                      ? Colors.white
                      : Colors.black87,
            ),
            textDirection: TextDirection.ltr,
          ),
        ),
      ),
    );
  }
}
