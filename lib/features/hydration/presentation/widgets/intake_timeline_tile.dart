import 'package:flutter/material.dart';

class IntakeTimelineTile extends StatelessWidget {
  const IntakeTimelineTile({
    super.key,
    required this.time,
    required this.amountMl,
  });

  final String time;
  final int amountMl;

  @override
  Widget build(BuildContext context) {
    return Container(
      margin: const EdgeInsets.only(bottom: 10),
      padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 14),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: const Color(0xFFE3EBFF)),
      ),
      child: Row(
        children: [
          Container(
            width: 38,
            height: 38,
            decoration: const BoxDecoration(
              color: Color(0xFFE8F0FF),
              shape: BoxShape.circle,
            ),
            child: const Icon(
              Icons.water_drop_rounded,
              color: Color(0xFF4F74FF),
              size: 20,
            ),
          ),
          const SizedBox(width: 12),
          Expanded(
            child: Text(
              '$amountMl ml',
              style: const TextStyle(fontSize: 15, fontWeight: FontWeight.w700),
            ),
          ),
          Text(
            time,
            style: const TextStyle(
              fontSize: 13,
              color: Color(0xFF69788B),
              fontWeight: FontWeight.w500,
            ),
          ),
        ],
      ),
    );
  }
}
