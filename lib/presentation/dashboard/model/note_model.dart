import 'package:cloud_firestore/cloud_firestore.dart';

class NoteModel {
  final String id;
  final String title;
  final String description;
  final String userEmail;
  final DateTime createdAt;

  NoteModel({
    required this.id,
    required this.title,
    required this.description,
    required this.userEmail,
    required this.createdAt,
  });

  factory NoteModel.fromDocument(QueryDocumentSnapshot<Map<String, dynamic>> doc) {
    final Map<String, dynamic> data = doc.data();
    final Timestamp? createdAt = data['createdAt'] as Timestamp?;

    return NoteModel(
      id: doc.id,
      title: data['title'] ?? '',
      description: data['description'] ?? '',
      userEmail: data['userEmail'] ?? '',
      createdAt: createdAt?.toDate() ?? DateTime.now(),
    );
  }

  Map<String, dynamic> toMap() {
    return {
      'title': title,
      'description': description,
      'userEmail': userEmail,
      'createdAt': Timestamp.fromDate(createdAt),
    };
  }
}
