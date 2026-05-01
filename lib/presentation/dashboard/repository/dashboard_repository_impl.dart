import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:demo_project/utils/app_constant.dart';
import '../model/note_model.dart';
import 'dashboard_repository.dart';

class DashboardRepositoryImpl implements DashboardRepository {
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;

  @override
  Future<void> addNote(NoteModel note) async {
    await _firestore
        .collection(AppConstant.collectionUsers)
        .doc(note.userEmail)
        .collection(AppConstant.collectionNotes)
        .add({
      ...note.toMap(),
      'createdAt': FieldValue.serverTimestamp(),
    });
  }

  @override
  Stream<List<NoteModel>> getNotes(String userEmail) {
    return _firestore
        .collection(AppConstant.collectionUsers)
        .doc(userEmail)
        .collection(AppConstant.collectionNotes)
        .orderBy('createdAt', descending: true)
        .snapshots()
        .map(
          (snapshot) => snapshot.docs
              .map((doc) => NoteModel.fromDocument(doc))
              .toList(),
        );
  }
}
