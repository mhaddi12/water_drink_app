import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:water_drink_app/features/focus/controllers/home_controller.dart';
import 'package:water_drink_app/features/focus/presentation/widgets/focus_app_bar.dart';
import 'package:water_drink_app/features/focus/presentation/widgets/focus_ui.dart';

class FocusSessionsScreen extends StatelessWidget {
  const FocusSessionsScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return SafeArea(
      bottom: false,
      child: Column(
        children: [
          const FocusAppBar(),
          Expanded(
            child: Padding(
              padding: const EdgeInsets.fromLTRB(16, 24, 16, 24),
              child: Column(
                children: [
                  const Spacer(),
                  FocusSurface(
                    padding: const EdgeInsets.fromLTRB(20, 28, 20, 24),
                    child: Column(
                      children: [
                        Container(
                          width: 64,
                          height: 64,
                          decoration: BoxDecoration(
                            color: const Color(0xFFE8F6EF),
                            borderRadius: BorderRadius.circular(20),
                          ),
                          child: const Icon(
                            Icons.water_drop_rounded,
                            color: FocusUi.accent,
                            size: 30,
                          ),
                        ),
                        const SizedBox(height: 18),
                        Text(
                          'Drink water',
                          style: Theme.of(context).textTheme.headlineSmall
                              ?.copyWith(
                                color: FocusUi.inkSoft,
                                fontWeight: FontWeight.w700,
                              ),
                        ),
                        const SizedBox(height: 8),
                        const Text(
                          'Gently re-centering your physical needs before the next focus block.',
                          textAlign: TextAlign.center,
                          style: TextStyle(
                            fontSize: 13,
                            color: FocusUi.muted,
                            height: 1.4,
                          ),
                        ),
                        const SizedBox(height: 22),
                        SizedBox(
                          width: double.infinity,
                          child: FilledButton(
                            onPressed: () => _onFocusPrompt(completed: true),
                            style: FilledButton.styleFrom(
                              backgroundColor: FocusUi.navy,
                              foregroundColor: Colors.white,
                              padding: const EdgeInsets.symmetric(vertical: 14),
                              shape: RoundedRectangleBorder(
                                borderRadius: BorderRadius.circular(12),
                              ),
                              textStyle: const TextStyle(
                                fontWeight: FontWeight.w600,
                              ),
                            ),
                            child: const Text('Done'),
                          ),
                        ),
                        const SizedBox(height: 10),
                        SizedBox(
                          width: double.infinity,
                          child: OutlinedButton(
                            onPressed: () => _onFocusPrompt(completed: false),
                            style: OutlinedButton.styleFrom(
                              foregroundColor: FocusUi.muted,
                              padding: const EdgeInsets.symmetric(vertical: 14),
                              side: const BorderSide(color: FocusUi.line),
                              shape: RoundedRectangleBorder(
                                borderRadius: BorderRadius.circular(12),
                              ),
                              textStyle: const TextStyle(
                                fontWeight: FontWeight.w600,
                              ),
                            ),
                            child: const Text('Skip for now'),
                          ),
                        ),
                      ],
                    ),
                  ),
                  const Spacer(flex: 2),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }
}

Future<void> _onFocusPrompt({required bool completed}) async {
  final home = Get.find<HomeController>();
  await home.applyFocusPrompt(completed: completed);
  Get.snackbar(
    'Hydra',
    completed ? 'Hydration break logged' : 'Skipped for now',
  );
}
