import 'package:flutter/material.dart';
import 'package:water_drink_app/features/hydration/presentation/widgets/hydration_progress_card.dart';
import 'package:water_drink_app/features/hydration/presentation/widgets/intake_timeline_tile.dart';
import 'package:water_drink_app/features/hydration/presentation/widgets/quick_add_row.dart';

class HydrationHomeScreen extends StatefulWidget {
  const HydrationHomeScreen({super.key});

  @override
  State<HydrationHomeScreen> createState() => _HydrationHomeScreenState();
}

class _HydrationHomeScreenState extends State<HydrationHomeScreen> {
  static const int _goalMl = 3000;
  int _currentMl = 1650;

  void _addWater(int amount) {
    setState(() {
      _currentMl = (_currentMl + amount).clamp(0, _goalMl);
    });
  }

  @override
  Widget build(BuildContext context) {
    final textTheme = Theme.of(context).textTheme;
    return SafeArea(
      child: SingleChildScrollView(
        padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        'Good Afternoon',
                        style: textTheme.titleMedium?.copyWith(
                          color: const Color(0xFF667185),
                          fontWeight: FontWeight.w500,
                        ),
                      ),
                      const SizedBox(height: 4),
                      Text(
                        'Stay hydrated, Haddi',
                        style: textTheme.headlineSmall?.copyWith(
                          fontWeight: FontWeight.w700,
                        ),
                      ),
                    ],
                  ),
                ),
                const CircleAvatar(
                  radius: 22,
                  backgroundColor: Color(0xFFDCE7FF),
                  child: Icon(Icons.person_outline_rounded),
                ),
              ],
            ),
            const SizedBox(height: 22),
            HydrationProgressCard(
              currentMl: _currentMl,
              goalMl: _goalMl,
              reminderText: 'Next reminder 4:30 PM',
            ),
            const SizedBox(height: 20),
            Text(
              'Quick Add',
              style: textTheme.titleLarge?.copyWith(
                fontWeight: FontWeight.w700,
              ),
            ),
            const SizedBox(height: 10),
            QuickAddRow(onAdd: _addWater),
            const SizedBox(height: 18),
            Center(
              child: FilledButton.icon(
                onPressed: () => _addWater(250),
                icon: const Icon(Icons.local_drink_rounded),
                label: const Text('Add 250 ml'),
                style: FilledButton.styleFrom(
                  padding: const EdgeInsets.symmetric(
                    horizontal: 20,
                    vertical: 12,
                  ),
                  tapTargetSize: MaterialTapTargetSize.shrinkWrap,
                  visualDensity: VisualDensity.compact,
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(16),
                  ),
                  textStyle: const TextStyle(
                    fontSize: 16,
                    fontWeight: FontWeight.w700,
                  ),
                ),
              ),
            ),
            const SizedBox(height: 22),
            Text(
              'Today',
              style: textTheme.titleLarge?.copyWith(
                fontWeight: FontWeight.w700,
              ),
            ),
            const SizedBox(height: 10),
            const IntakeTimelineTile(time: '7:30 AM', amountMl: 300),
            const IntakeTimelineTile(time: '10:45 AM', amountMl: 200),
            const IntakeTimelineTile(time: '1:15 PM', amountMl: 400),
            const IntakeTimelineTile(time: '3:00 PM', amountMl: 250),
          ],
        ),
      ),
    );
  }
}
