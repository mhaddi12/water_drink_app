import 'package:flutter/material.dart';

class FocusAppBar extends StatelessWidget {
  const FocusAppBar({
    super.key,
    this.title = 'Serene Focus',
    this.leading,
    this.onLeadingTap,
  });

  final String title;
  final IconData? leading;
  final VoidCallback? onLeadingTap;

  @override
  Widget build(BuildContext context) {
    return Container(
      height: 48,
      padding: const EdgeInsets.symmetric(horizontal: 8),
      decoration: BoxDecoration(
        color: Colors.white,
        border: Border(
          bottom: BorderSide(
            color: const Color(0xFFE8EAF2).withValues(alpha: 0.9),
          ),
        ),
      ),
      child: Row(
        children: [
          SizedBox(
            width: 40,
            height: 40,
            child: leading == null
                ? const Icon(
                    Icons.self_improvement,
                    size: 14,
                    color: Color(0xFF143D90),
                  )
                : IconButton(
                    onPressed: onLeadingTap ?? () {},
                    icon: Icon(leading, size: 18),
                    color: const Color(0xFF143D90),
                    splashRadius: 20,
                    tooltip: 'Back',
                  ),
          ),
          Expanded(
            child: Text(
              title,
              textAlign: TextAlign.center,
              style: const TextStyle(
                color: Color(0xFF143D90),
                fontWeight: FontWeight.w700,
                fontSize: 13,
              ),
            ),
          ),
          const CircleAvatar(
            radius: 10,
            backgroundColor: Color(0xFFB3B7C8),
            child: Icon(Icons.person, size: 11, color: Colors.white),
          ),
          const SizedBox(width: 8),
        ],
      ),
    );
  }
}
