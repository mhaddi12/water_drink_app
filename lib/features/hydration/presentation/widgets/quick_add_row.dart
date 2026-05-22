import 'package:flutter/material.dart';
import 'package:water_drink_app/app/theme/app_theme.dart';
import 'package:water_drink_app/app/widgets/hub_ui.dart';

class QuickAddRow extends StatelessWidget {
  const QuickAddRow({super.key, required this.onAdd});

  final ValueChanged<int> onAdd;

  @override
  Widget build(BuildContext context) {
    return Wrap(
      spacing: 10,
      runSpacing: 10,
      children: [
        for (final amount in [100, 200, 300, 500])
          _QuickAddChip(amount: amount, onAdd: onAdd),
      ],
    );
  }
}

class _QuickAddChip extends StatelessWidget {
  const _QuickAddChip({required this.amount, required this.onAdd});

  final int amount;
  final ValueChanged<int> onAdd;

  @override
  Widget build(BuildContext context) {
    return ActionChip(
      onPressed: () => onAdd(amount),
      avatar: const Icon(Icons.add, size: 16, color: AppTheme.primary),
      label: Text('$amount ml'),
      backgroundColor: HubUi.cardSurface(context),
      side: BorderSide(color: HubUi.border(context)),
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
      labelStyle: const TextStyle(fontWeight: FontWeight.w600),
    );
  }
}
