import 'package:flutter/material.dart';

class QuickAddRow extends StatelessWidget {
  const QuickAddRow({super.key, required this.onAdd});

  final ValueChanged<int> onAdd;

  @override
  Widget build(BuildContext context) {
    return Wrap(
      spacing: 10,
      runSpacing: 10,
      children: const [
        100,
        200,
        300,
        500,
      ].map((amount) => _QuickAddChip(amount: amount, onAdd: onAdd)).toList(),
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
      avatar: const Icon(Icons.add, size: 16),
      label: Text('$amount ml'),
      backgroundColor: Colors.white,
      side: const BorderSide(color: Color(0xFFCED8F7)),
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
      labelStyle: const TextStyle(fontWeight: FontWeight.w600),
    );
  }
}
