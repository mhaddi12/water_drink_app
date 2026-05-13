import 'package:firebase_core/firebase_core.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:water_drink_app/core/session/app_session.dart';
import 'package:water_drink_app/core/session/local_profile_store.dart';
import 'package:water_drink_app/data/models/routine_task.dart';
import 'package:water_drink_app/data/repositories/user_repository.dart';
import 'package:water_drink_app/features/focus/controllers/systems_controller.dart';
import 'package:water_drink_app/features/focus/presentation/widgets/focus_app_bar.dart';
import 'package:water_drink_app/features/focus/presentation/widgets/focus_input_decoration.dart';

/// Create or edit a morning routine task; persists to Firestore when available.
class AddEditTaskScreen extends StatefulWidget {
  const AddEditTaskScreen({super.key, this.existing});

  final RoutineTask? existing;

  bool get isEditing => existing != null;

  @override
  State<AddEditTaskScreen> createState() => _AddEditTaskScreenState();
}

class _AddEditTaskScreenState extends State<AddEditTaskScreen> {
  final _formKey = GlobalKey<FormState>();
  late final TextEditingController _titleCtrl;
  late final TextEditingController _subtitleCtrl;
  bool _saving = false;
  bool _deleting = false;

  @override
  void initState() {
    super.initState();
    _titleCtrl = TextEditingController(text: widget.existing?.title ?? '');
    _subtitleCtrl = TextEditingController(
      text: widget.existing?.subtitle ?? '',
    );
  }

  @override
  void dispose() {
    _titleCtrl.dispose();
    _subtitleCtrl.dispose();
    super.dispose();
  }

  Future<void> _save() async {
    if (!_formKey.currentState!.validate()) return;

    final title = _titleCtrl.text.trim();
    final subtitle = _subtitleCtrl.text.trim();

    if (!AppSession.canSync) {
      final local = Get.find<LocalProfileStore>();
      final systems = Get.find<SystemsController>();
      if (widget.existing != null) {
        local.upsertTask(
          widget.existing!.copyWith(title: title, subtitle: subtitle),
        );
      } else {
        final order = systems.tasks.isEmpty
            ? 0
            : systems.tasks.map((e) => e.order).reduce((a, b) => a > b ? a : b) +
                  1;
        local.upsertTask(
          RoutineTask(
            id: 'local_${DateTime.now().millisecondsSinceEpoch}',
            title: title,
            subtitle: subtitle,
            done: false,
            order: order,
          ),
        );
      }
      systems.applyLocalDefaults();
      if (mounted) Get.back();
      Get.snackbar('Hydra', widget.isEditing ? 'Task updated' : 'Task added');
      return;
    }

    final uid = AppSession.uid;
    if (uid == null) {
      Get.snackbar('Hydra', 'Not signed in yet. Please try again.');
      return;
    }

    setState(() => _saving = true);
    try {
      final repo = Get.find<UserRepository>();
      if (widget.existing != null) {
        final t = widget.existing!.copyWith(title: title, subtitle: subtitle);
        await repo.updateTask(uid, t);
      } else {
        final c = Get.find<SystemsController>();
        final order = c.tasks.isEmpty
            ? 0
            : c.tasks.map((e) => e.order).reduce((a, b) => a > b ? a : b) + 1;
        final id = repo.nextTaskId(uid);
        await repo.addTask(
          uid,
          RoutineTask(
            id: id,
            title: title,
            subtitle: subtitle,
            done: false,
            order: order,
          ),
        );
      }
      if (mounted) Get.back();
      Get.snackbar('Hydra', widget.isEditing ? 'Task updated' : 'Task added');
    } on FirebaseException catch (e) {
      Get.snackbar('Hydra', e.message ?? 'Could not save task.');
    } catch (_) {
      Get.snackbar('Hydra', 'Something went wrong. Try again.');
    } finally {
      if (mounted) setState(() => _saving = false);
    }
  }

  Future<void> _confirmDelete() async {
    if (widget.existing == null) return;
    final ok = await showDialog<bool>(
      context: context,
      builder: (ctx) => AlertDialog(
        title: const Text('Delete task?'),
        content: const Text(
          'This removes the step from your routine for all devices.',
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(ctx, false),
            child: const Text('Cancel'),
          ),
          FilledButton(
            onPressed: () => Navigator.pop(ctx, true),
            style: FilledButton.styleFrom(
              backgroundColor: const Color(0xFFB00020),
            ),
            child: const Text('Delete'),
          ),
        ],
      ),
    );
    if (ok != true) return;

    if (!AppSession.canSync) {
      Get.find<LocalProfileStore>().removeTask(widget.existing!.id);
      Get.find<SystemsController>().applyLocalDefaults();
      if (mounted) Get.back();
      Get.snackbar('Hydra', 'Task removed');
      return;
    }

    final uid = AppSession.uid;
    if (uid == null) return;

    setState(() => _deleting = true);
    try {
      await Get.find<UserRepository>().deleteTask(uid, widget.existing!.id);
      if (mounted) Get.back();
      Get.snackbar('Hydra', 'Task removed');
    } on FirebaseException catch (e) {
      Get.snackbar('Hydra', e.message ?? 'Could not delete.');
    } finally {
      if (mounted) setState(() => _deleting = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    final busy = _saving || _deleting;
    return Scaffold(
      backgroundColor: const Color(0xFFF1F2F7),
      body: SafeArea(
        child: Column(
          children: [
            FocusAppBar(
              title: widget.isEditing ? 'Edit task' : 'New task',
              leading: Icons.arrow_back_ios_new_rounded,
              onLeadingTap: () {
                if (busy) return;
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
                        widget.isEditing
                            ? 'Update this step'
                            : 'Add a routine step',
                        style: Theme.of(context).textTheme.titleLarge?.copyWith(
                          fontWeight: FontWeight.w700,
                          color: const Color(0xFF143064),
                        ),
                      ),
                      const SizedBox(height: 6),
                      const Text(
                        'Tasks sync to your account when Hydra is online.',
                        style: TextStyle(
                          fontSize: 13,
                          color: Color(0xFF7A8299),
                        ),
                      ),
                      const SizedBox(height: 20),
                      TextFormField(
                        controller: _titleCtrl,
                        textCapitalization: TextCapitalization.sentences,
                        decoration: focusInputDecoration('Title *'),
                        validator: (v) {
                          final t = v?.trim() ?? '';
                          if (t.isEmpty) return 'Enter a title';
                          if (t.length > 100) return 'Shorten the title';
                          return null;
                        },
                      ),
                      const SizedBox(height: 14),
                      TextFormField(
                        controller: _subtitleCtrl,
                        textCapitalization: TextCapitalization.sentences,
                        decoration: focusInputDecoration(
                          'Detail',
                          hint: 'Time, amount, or note',
                        ),
                        maxLength: 150,
                      ),
                      const SizedBox(height: 28),
                      SizedBox(
                        width: double.infinity,
                        child: FilledButton(
                          onPressed: busy ? null : _save,
                          style: FilledButton.styleFrom(
                            backgroundColor: const Color(0xFF082F86),
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
                              : Text(
                                  widget.isEditing
                                      ? 'Save changes'
                                      : 'Add task',
                                ),
                        ),
                      ),
                      if (widget.isEditing) ...[
                        const SizedBox(height: 12),
                        Center(
                          child: TextButton(
                            onPressed: busy ? null : _confirmDelete,
                            style: TextButton.styleFrom(
                              foregroundColor: const Color(0xFFB00020),
                            ),
                            child: Text(
                              _deleting ? 'Deleting…' : 'Delete task',
                            ),
                          ),
                        ),
                      ],
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
