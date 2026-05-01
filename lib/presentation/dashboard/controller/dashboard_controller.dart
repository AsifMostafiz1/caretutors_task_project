import 'dart:async';

import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:demo_project/common/widgets/custom_snackbar.dart';
import 'package:demo_project/utils/app_constant.dart';
import 'package:demo_project/utils/app_enums.dart';
import '../model/note_model.dart';
import '../repository/dashboard_repository.dart';

class DashboardController extends GetxController implements GetxService {
  final DashboardRepository repository;

  DashboardController({required this.repository});

  final titleController = TextEditingController();
  final descriptionController = TextEditingController();

  final List<NoteModel> notes = [];

  StreamSubscription<List<NoteModel>>? _notesSubscription;

  String userName = 'User';
  String userEmail = '';
  bool isNotesLoading = true;
  bool isSavingNote = false;

  @override
  void onInit() {
    super.onInit();
    loadUserData();
  }

  @override
  void onClose() {
    _notesSubscription?.cancel();
    titleController.dispose();
    descriptionController.dispose();
    super.onClose();
  }

  Future<void> loadUserData() async {
    final SharedPreferences prefs = await SharedPreferences.getInstance();

    userName = prefs.getString(AppConstant.keyUserName) ?? 'User';
    userEmail = prefs.getString(AppConstant.keyUserEmail) ?? '';
    update();

    if (userEmail.isEmpty) {
      isNotesLoading = false;
      update();
      return;
    }

    _listenToNotes();
  }

  void _listenToNotes() {
    isNotesLoading = true;
    update();

    _notesSubscription?.cancel();
    _notesSubscription = repository.getNotes(userEmail).listen(
      (fetchedNotes) {
        final List<NoteModel> sortedNotes = List<NoteModel>.from(fetchedNotes)
          ..sort((a, b) => b.createdAt.compareTo(a.createdAt));

        notes
          ..clear()
          ..addAll(sortedNotes);
        isNotesLoading = false;
        update();
      },
      onError: (_) {
        isNotesLoading = false;
        update();
        CustomSnackbar.show(
          message: 'Failed to load notes',
          type: SnackbarType.error,
        );
      },
    );
  }

  void resetNoteForm() {
    titleController.clear();
    descriptionController.clear();
    isSavingNote = false;
    update();
  }

  Future<bool> saveNote() async {
    final String title = titleController.text.trim();
    final String description = descriptionController.text.trim();

    if (title.isEmpty || description.isEmpty) {
      CustomSnackbar.show(
        message: 'Please enter note title and description',
        type: SnackbarType.error,
      );
      return false;
    }

    if (userEmail.isEmpty) {
      CustomSnackbar.show(
        message: 'User information not found',
        type: SnackbarType.error,
      );
      return false;
    }

    try {
      isSavingNote = true;
      update();

      final NoteModel note = NoteModel(
        id: '',
        title: title,
        description: description,
        userEmail: userEmail,
        createdAt: DateTime.now(),
      );

      await repository.addNote(note);
      resetNoteForm();
      CustomSnackbar.show(
        message: 'Note saved successfully',
        type: SnackbarType.success,
      );
      return true;
    } catch (_) {
      isSavingNote = false;
      update();
      CustomSnackbar.show(
        message: 'Failed to save note',
        type: SnackbarType.error,
      );
      return false;
    }
  }

  Map<String, List<NoteModel>> get groupedNotes {
    final Map<String, List<NoteModel>> grouped = <String, List<NoteModel>>{};
    final List<NoteModel> sortedNotes = List<NoteModel>.from(notes)
      ..sort((a, b) => b.createdAt.compareTo(a.createdAt));

    for (final NoteModel note in sortedNotes) {
      final String key = formatGroupDate(note.createdAt);
      grouped.putIfAbsent(key, () => <NoteModel>[]);
      grouped[key]!.add(note);
    }

    for (final List<NoteModel> noteList in grouped.values) {
      noteList.sort((a, b) => b.createdAt.compareTo(a.createdAt));
    }

    return grouped;
  }

  String formatGroupDate(DateTime date) {
    final DateTime normalizedDate = DateTime(date.year, date.month, date.day);
    final DateTime now = DateTime.now();
    final DateTime today = DateTime(now.year, now.month, now.day);
    final DateTime yesterday = today.subtract(const Duration(days: 1));

    if (normalizedDate == today) {
      return 'Today';
    }

    if (normalizedDate == yesterday) {
      return 'Yesterday';
    }

    const List<String> months = [
      'Jan',
      'Feb',
      'Mar',
      'Apr',
      'May',
      'Jun',
      'Jul',
      'Aug',
      'Sep',
      'Oct',
      'Nov',
      'Dec',
    ];

    return '${date.day} ${months[date.month - 1]} ${date.year}';
  }

  String formatTime(DateTime date) {
    final int hour = date.hour % 12 == 0 ? 12 : date.hour % 12;
    final String minute = date.minute.toString().padLeft(2, '0');
    final String period = date.hour >= 12 ? 'PM' : 'AM';
    return '$hour:$minute $period';
  }
}
