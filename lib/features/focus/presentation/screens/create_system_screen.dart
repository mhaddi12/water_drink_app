import 'package:firebase_core/firebase_core.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:water_drink_app/core/session/app_session.dart';
import 'package:water_drink_app/core/session/local_profile_store.dart';
import 'package:water_drink_app/data/models/focus_system.dart';
import 'package:water_drink_app/data/repositories/user_repository.dart';
import 'package:water_drink_app/features/focus/controllers/focus_nav_controller.dart';
import 'package:water_drink_app/features/focus/controllers/home_controller.dart';
import 'package:water_drink_app/features/focus/controllers/systems_controller.dart';
import 'package:water_drink_app/features/focus/presentation/widgets/focus_app_bar.dart';
import 'package:water_drink_app/features/focus/presentation/widgets/focus_input_decoration.dart';

/// Full-screen form to create a focus system and persist it to Firestore.
class CreateSystemScreen extends StatefulWidget {
  const CreateSystemScreen({super.key});

  @override
  State<CreateSystemScreen> createState() => _CreateSystemScreenState();
}

class _CreateSystemScreenState extends State<CreateSystemScreen> {
  final _formKey = GlobalKey<FormState>();
  final _nameCtrl = TextEditingController();
  final _focusLineCtrl = TextEditingController();
  final _minutesCtrl = TextEditingController();

  String _kind = 'deep_work';
  String _frequency = 'Daily';
  bool _saving = false;

  static const _kinds = [
    ('deep_work', 'Deep work'),
    ('routine', 'Routine'),
    ('habit', 'Habit / custom'),
  ];

  static const _frequencies = ['Daily', 'Weekdays', 'Weekly'];

  @override
  void dispose() {
    _nameCtrl.dispose();
    _focusLineCtrl.dispose();
    _minutesCtrl.dispose();
    super.dispose();
  }

  Future<void> _submit() async {
    if (!_formKey.currentState!.validate()) return;

    int? minutes;
    final rawMin = _minutesCtrl.text.trim();
    if (rawMin.isNotEmpty) {
      minutes = int.tryParse(rawMin);
      if (minutes == null || minutes < 1 || minutes > 24 * 60) {
        Get.snackbar('Hydra', 'Enter a valid duration in minutes (1–1440).');
        return;
      }
    }

    final name = _nameCtrl.text.trim();
    final focusLine = _focusLineCtrl.text.trim();
    final tag = switch (_kind) {
      'deep_work' => 'DEEP WORK',
      'routine' => 'ROUTINE',
      _ => 'CUSTOM SYSTEM',
    };

    if (!AppSession.canSync) {
      final system = FocusSystem(
        id: 'local_${DateTime.now().millisecondsSinceEpoch}',
        name: name,
        kind: _kind,
        tag: tag,
        focusLine: focusLine.isEmpty ? 'Track consistently' : focusLine,
        frequency: _frequency,
        targetMinutes: minutes,
        createdAt: DateTime.now(),
      );
      Get.find<LocalProfileStore>().addSystem(system);
      Get.find<HomeController>().userSystems.insert(0, system);
      Get.find<SystemsController>().selectSystem(system.id);
      if (Get.isRegistered<FocusNavController>()) {
        Get.find<FocusNavController>().goSystems();
      }
      if (mounted) Get.back();
      Get.snackbar('Hydra', 'System saved on this device. Add tasks in Systems.');
      return;
    }

    setState(() => _saving = true);
    try {
      final systemId = await Get.find<UserRepository>().createFocusSystem(
        AppSession.uid!,
        name: name,
        kind: _kind,
        frequency: _frequency,
        focusLine: focusLine,
        targetMinutes: minutes,
      );
      if (systemId.isNotEmpty) {
        Get.find<SystemsController>().selectSystem(systemId);
        if (Get.isRegistered<FocusNavController>()) {
          Get.find<FocusNavController>().goSystems();
        }
      }
      if (mounted) Get.back();
      Get.snackbar('Hydra', 'System created. Add tasks in Systems.');
    } on FirebaseException catch (e) {
      Get.snackbar(
        'Hydra',
        e.message ?? 'Could not save. Check Firestore rules.',
      );
    } catch (_) {
      Get.snackbar('Hydra', 'Something went wrong. Try again.');
    } finally {
      if (mounted) setState(() => _saving = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Theme.of(context).scaffoldBackgroundColor,
      body: SafeArea(
        child: Column(
          children: [
            FocusAppBar(
              showDrawerMenu: false,
              title: 'New system',
              leading: Icons.arrow_back_ios_new_rounded,
              onLeadingTap: () {
                if (_saving) return;
                Get.back();
              },
            ),
            Expanded(
              child: SingleChildScrollView(
                padding: const EdgeInsets.fromLTRB(16, 16, 16, 28),
                child: Form(
                  key: _formKey,
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        'Define your system',
                        style: Theme.of(context).textTheme.titleLarge?.copyWith(
                          fontWeight: FontWeight.w700,
                          color: const Color(0xFF143064),
                        ),
                      ),
                      const SizedBox(height: 6),
                      const Text(
                        'Name it, choose a type, and sync it to your Hydra profile.',
                        style: TextStyle(
                          fontSize: 13,
                          color: Color(0xFF7A8299),
                        ),
                      ),
                      const SizedBox(height: 20),
                      TextFormField(
                        controller: _nameCtrl,
                        textCapitalization: TextCapitalization.sentences,
                        decoration: focusInputDecoration(context,'System name *'),
                        validator: (v) {
                          final t = v?.trim() ?? '';
                          if (t.isEmpty) return 'Enter a name';
                          if (t.length > 80) {
                            return 'Keep it under 80 characters';
                          }
                          return null;
                        },
                      ),
                      const SizedBox(height: 14),
                      Builder(
                        builder: (context) {
                          final menuWidth =
                              MediaQuery.sizeOf(context).width - 32;
                          return Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              const Padding(
                                padding: EdgeInsets.only(left: 4, bottom: 8),
                                child: Text(
                                  'Type',
                                  style: TextStyle(
                                    fontSize: 13,
                                    fontWeight: FontWeight.w500,
                                    color: Color(0xFF152238),
                                  ),
                                ),
                              ),
                              Container(
                                width: double.infinity,
                                padding: const EdgeInsets.symmetric(
                                  horizontal: 10,
                                  vertical: 4,
                                ),
                                decoration: BoxDecoration(
                                  color: Colors.white,
                                  borderRadius: BorderRadius.circular(10),
                                  border: Border.all(
                                    color: const Color(0xFFE8EAF2),
                                  ),
                                ),
                                child: DropdownMenu<String>(
                                  key: ValueKey('kind_$_kind'),
                                  initialSelection: _kind,
                                  enabled: !_saving,
                                  width: menuWidth,
                                  onSelected: (v) {
                                    if (v != null) {
                                      setState(() => _kind = v);
                                    }
                                  },
                                  dropdownMenuEntries: _kinds
                                      .map(
                                        (e) => DropdownMenuEntry<String>(
                                          value: e.$1,
                                          label: e.$2,
                                        ),
                                      )
                                      .toList(),
                                ),
                              ),
                              const SizedBox(height: 14),
                              const Padding(
                                padding: EdgeInsets.only(left: 4, bottom: 8),
                                child: Text(
                                  'Frequency',
                                  style: TextStyle(
                                    fontSize: 13,
                                    fontWeight: FontWeight.w500,
                                    color: Color(0xFF152238),
                                  ),
                                ),
                              ),
                              Container(
                                width: double.infinity,
                                padding: const EdgeInsets.symmetric(
                                  horizontal: 10,
                                  vertical: 4,
                                ),
                                decoration: BoxDecoration(
                                  color: Colors.white,
                                  borderRadius: BorderRadius.circular(10),
                                  border: Border.all(
                                    color: const Color(0xFFE8EAF2),
                                  ),
                                ),
                                child: DropdownMenu<String>(
                                  key: ValueKey('freq_$_frequency'),
                                  initialSelection: _frequency,
                                  enabled: !_saving,
                                  width: menuWidth,
                                  onSelected: (v) {
                                    if (v != null) {
                                      setState(() => _frequency = v);
                                    }
                                  },
                                  dropdownMenuEntries: _frequencies
                                      .map(
                                        (e) => DropdownMenuEntry<String>(
                                          value: e,
                                          label: e,
                                        ),
                                      )
                                      .toList(),
                                ),
                              ),
                            ],
                          );
                        },
                      ),
                      const SizedBox(height: 14),
                      TextFormField(
                        controller: _focusLineCtrl,
                        textCapitalization: TextCapitalization.sentences,
                        decoration: focusInputDecoration(context,
                          'Focus line (optional)',
                          hint: 'e.g. Morning clarity block',
                        ),
                        maxLength: 120,
                      ),
                      const SizedBox(height: 6),
                      TextFormField(
                        controller: _minutesCtrl,
                        keyboardType: TextInputType.number,
                        decoration: focusInputDecoration(context,
                          'Target minutes (optional)',
                          hint: 'e.g. 45',
                        ),
                      ),
                      const SizedBox(height: 28),
                      SizedBox(
                        width: double.infinity,
                        child: FilledButton(
                          onPressed: _saving ? null : _submit,
                          style: FilledButton.styleFrom(
                            backgroundColor: const Color(0xFF0A2C88),
                            foregroundColor: Colors.white,
                            padding: const EdgeInsets.symmetric(vertical: 14),
                            shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(12),
                            ),
                          ),
                          child: _saving
                              ? const SizedBox(
                                  height: 20,
                                  width: 20,
                                  child: CircularProgressIndicator(
                                    strokeWidth: 2,
                                    color: Colors.white,
                                  ),
                                )
                              : const Text('Save & sync'),
                        ),
                      ),
                    ],
                  ),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
