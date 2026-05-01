import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:demo_project/common/widgets/custom_app_bar.dart';
import 'package:demo_project/common/widgets/custom_button.dart';
import 'package:demo_project/common/widgets/custom_text_field.dart';
import '../../auth/controller/auth_controller.dart';
import '../controller/dashboard_controller.dart';
import '../model/note_model.dart';

class DashboardScreen extends GetView<DashboardController> {
  const DashboardScreen({super.key});

  String _userInitials(String name) {
    final List<String> parts =
        name.trim().split(RegExp(r'\s+')).where((part) => part.isNotEmpty).toList();

    if (parts.isEmpty) {
      return 'U';
    }

    return parts.map((part) => part[0].toUpperCase()).join();
  }

  Future<void> _showAddNoteBottomSheet(BuildContext context) async {
    controller.resetNoteForm();

    await showModalBottomSheet<void>(
      context: context,
      isScrollControlled: true,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(24)),
      ),
      builder: (context) {
        return GetBuilder<DashboardController>(
          builder: (controller) => Padding(
            padding: EdgeInsets.only(
              left: 24,
              right: 24,
              top: 24,
              bottom: MediaQuery.of(context).viewInsets.bottom + 24,
            ),
            child: SafeArea(
              top: false,
              child: SingleChildScrollView(
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      'Add Note',
                      style: Theme.of(context).textTheme.titleLarge?.copyWith(
                            fontWeight: FontWeight.w700,
                          ),
                    ),
                    const SizedBox(height: 8),
                    Text(
                      'Create a note for ${controller.userName}',
                      style: Theme.of(context).textTheme.bodySmall,
                    ),
                    const SizedBox(height: 24),
                    CustomTextField(
                      controller: controller.titleController,
                      hintText: 'Note Title',
                      prefixIcon: const Icon(Icons.title, size: 20),
                      textInputAction: TextInputAction.next,
                    ),
                    const SizedBox(height: 16),
                    CustomTextField(
                      controller: controller.descriptionController,
                      hintText: 'Note Description',
                      prefixIcon: const Padding(
                        padding: EdgeInsets.only(bottom: 64),
                        child: Icon(Icons.notes_outlined, size: 20),
                      ),
                      maxLines: 5,
                      textInputAction: TextInputAction.done,
                    ),
                    const SizedBox(height: 24),
                    CustomButton(
                      buttonText: 'Save Note',
                      isLoading: controller.isSavingNote,
                      onPressed: () async {
                        final bool isSaved = await controller.saveNote();
                        if (isSaved && context.mounted) {
                          Navigator.of(context).pop();
                        }
                      },
                    ),
                  ],
                ),
              ),
            ),
          ),
        );
      },
    );
  }

  Future<void> _showLogoutConfirmation(BuildContext context) async {
    final bool? shouldLogout = await showDialog<bool>(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Logout'),
        content: const Text('Are you sure you want to logout?'),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(context).pop(false),
            child: const Text('Cancel'),
          ),
          ElevatedButton(
            onPressed: () => Navigator.of(context).pop(true),
            child: const Text('Logout'),
          ),
        ],
      ),
    );

    if (shouldLogout == true) {
      await Get.find<AuthController>().signOut();
    }
  }

  Widget _buildNotesList(BuildContext context, DashboardController controller) {
    if (controller.isNotesLoading) {
      return const Center(
        child: CircularProgressIndicator(),
      );
    }

    if (controller.userEmail.isEmpty) {
      return const Center(
        child: Text('Unable to load notes'),
      );
    }

    if (controller.notes.isEmpty) {
      return Center(
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 32),
          child: Text(
            'No notes yet. Tap the add button to create your first note.',
            textAlign: TextAlign.center,
            style: Theme.of(context).textTheme.bodyMedium,
          ),
        ),
      );
    }

    final entries = controller.groupedNotes.entries.toList();

    return ListView.builder(
      padding: const EdgeInsets.fromLTRB(16, 20, 16, 96),
      itemCount: entries.length,
      itemBuilder: (context, index) {
        final entry = entries[index];

        return Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Padding(
              padding: const EdgeInsets.only(bottom: 12),
              child: Text(
                entry.key,
                style: Theme.of(context).textTheme.titleMedium?.copyWith(
                      fontWeight: FontWeight.w700,
                    ),
              ),
            ),
            ...entry.value.map(
              (NoteModel note) => Container(
                width: double.infinity,
                margin: const EdgeInsets.only(bottom: 12),
                padding: const EdgeInsets.all(16),
                decoration: BoxDecoration(
                  color: Theme.of(context).cardColor,
                  borderRadius: BorderRadius.circular(18),
                  border: Border.all(
                    color: Theme.of(context).dividerColor.withValues(alpha: 0.12),
                  ),
                ),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Row(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Expanded(
                          child: Text(
                            note.title,
                            style: Theme.of(context).textTheme.titleMedium?.copyWith(
                                  fontWeight: FontWeight.w700,
                                ),
                          ),
                        ),
                        const SizedBox(width: 12),
                        Text(
                          controller.formatTime(note.createdAt),
                          style: Theme.of(context).textTheme.bodySmall,
                        ),
                      ],
                    ),
                    const SizedBox(height: 8),
                    Text(
                      note.description,
                      style: Theme.of(context).textTheme.bodyMedium,
                    ),
                  ],
                ),
              ),
            ),
          ],
        );
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    return GetBuilder<DashboardController>(
      builder: (controller) => Scaffold(
        appBar: CustomAppBar(
          leading: Padding(
            padding: const EdgeInsets.only(left: 20),
            child: Center(
              child: CircleAvatar(
                radius: 20,
                backgroundColor: Theme.of(context).colorScheme.primary.withValues(alpha: 0.14),
                child: Text(
                  _userInitials(controller.userName),
                  style: Theme.of(context).textTheme.titleSmall?.copyWith(
                        color: Theme.of(context).colorScheme.primary,
                        fontWeight: FontWeight.w700,
                      ),
                ),
              ),
            ),
          ),
          title: controller.userName,
          subtitle: controller.userEmail,
          actions: [
            PopupMenuButton<String>(
              onSelected: (value) async {
                if (value == 'logout') {
                  await _showLogoutConfirmation(context);
                }
              },
              itemBuilder: (context) => const [
                PopupMenuItem<String>(
                  value: 'logout',
                  child: Text('Logout'),
                ),
              ],
            ),
          ],
          automaticallyImplyLeading: false,
        ),
        body: _buildNotesList(context, controller),
        floatingActionButton: FloatingActionButton(
          onPressed: () => _showAddNoteBottomSheet(context),
          child: const Icon(Icons.add),
        ),
      ),
    );
  }
}
