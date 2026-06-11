import 'dart:math';
import 'package:flutter/material.dart';
import 'package:minigenius/generated/l10n/app_localizations.dart';

/// Apple Kids Category Parental Gate
/// Shows a simple math question that children cannot easily solve.
/// Required before accessing any external links (e.g. Contact Developer).
Future<bool> showParentalGateDialog(BuildContext context) async {
  final result = await showDialog<bool>(
    context: context,
    barrierDismissible: false,
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
    // Use numbers 7-12 for multiplication — hard for young children but easy for parents
    _num1 = rng.nextInt(6) + 7; // 7 to 12
    _num2 = rng.nextInt(6) + 7; // 7 to 12
    _correctAnswer = _num1 * _num2;

    // Generate 3 wrong options that are close but distinct
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
      // Wrong answer — regenerate question
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
    final l10n = AppLocalizations.of(context)!;
    final theme = Theme.of(context);
    final isRtl = Directionality.of(context) == TextDirection.rtl;

    return AlertDialog(
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
      title: Row(
        children: [
          Icon(Icons.family_restroom, color: theme.colorScheme.primary, size: 28),
          const SizedBox(width: 10),
          Expanded(
            child: Text(
              l10n.parentalGateTitle,
              style: theme.textTheme.titleLarge?.copyWith(
                fontWeight: FontWeight.bold,
              ),
            ),
          ),
        ],
      ),
      content: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          Text(
            l10n.parentalGateDescription,
            style: theme.textTheme.bodyMedium?.copyWith(height: 1.5),
            textAlign: TextAlign.center,
          ),
          const SizedBox(height: 24),

          // Math question
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 16),
            decoration: BoxDecoration(
              color: theme.colorScheme.primaryContainer,
              borderRadius: BorderRadius.circular(16),
            ),
            child: Text(
              '$_num1 × $_num2 = ?',
              style: theme.textTheme.headlineMedium?.copyWith(
                fontWeight: FontWeight.bold,
                color: theme.colorScheme.onPrimaryContainer,
                letterSpacing: 2,
              ),
              textAlign: TextAlign.center,
              textDirection: TextDirection.ltr,
            ),
          ),

          const SizedBox(height: 20),

          // Answer options grid
          GridView.count(
            crossAxisCount: 2,
            shrinkWrap: true,
            crossAxisSpacing: 10,
            mainAxisSpacing: 10,
            childAspectRatio: 2.5,
            physics: const NeverScrollableScrollPhysics(),
            children: _options.map((option) {
              final isSelected = _selectedAnswer == option;
              final isWrong = _showError && isSelected;

              return GestureDetector(
                onTap: () => _onOptionSelected(option),
                child: AnimatedContainer(
                  duration: const Duration(milliseconds: 200),
                  decoration: BoxDecoration(
                    color: isWrong
                        ? Colors.red.shade100
                        : isSelected
                            ? theme.colorScheme.primary
                            : theme.colorScheme.surfaceContainerHighest,
                    borderRadius: BorderRadius.circular(12),
                    border: Border.all(
                      color: isWrong
                          ? Colors.red
                          : isSelected
                              ? theme.colorScheme.primary
                              : Colors.transparent,
                      width: 2,
                    ),
                  ),
                  child: Center(
                    child: Text(
                      '$option',
                      style: theme.textTheme.titleMedium?.copyWith(
                        fontWeight: FontWeight.bold,
                        color: isWrong
                            ? Colors.red
                            : isSelected
                                ? theme.colorScheme.onPrimary
                                : theme.colorScheme.onSurface,
                      ),
                      textDirection: TextDirection.ltr,
                    ),
                  ),
                ),
              );
            }).toList(),
          ),

          // Error message
          if (_showError) ...[
            const SizedBox(height: 12),
            Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                const Icon(Icons.close_rounded, color: Colors.red, size: 18),
                const SizedBox(width: 6),
                Text(
                  l10n.parentalGateWrongAnswer,
                  style: const TextStyle(color: Colors.red, fontWeight: FontWeight.w600),
                ),
              ],
            ),
          ],
        ],
      ),
      actions: [
        TextButton(
          onPressed: () => Navigator.of(context).pop(false),
          child: Text(l10n.cancel),
        ),
        ElevatedButton(
          onPressed: _selectedAnswer != null && !_showError ? _onConfirm : null,
          style: ElevatedButton.styleFrom(
            shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
          ),
          child: Text(l10n.parentalGateContinue),
        ),
      ],
    );
  }
}
