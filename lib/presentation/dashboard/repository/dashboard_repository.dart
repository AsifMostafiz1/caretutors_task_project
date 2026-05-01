import '../model/note_model.dart';

abstract class DashboardRepository {
  Future<void> addNote(NoteModel note);
  Stream<List<NoteModel>> getNotes(String userEmail);
}
