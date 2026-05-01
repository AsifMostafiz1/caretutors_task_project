import 'package:cloud_firestore/cloud_firestore.dart';
import '../../../../utils/app_constant.dart';
import '../model/user_model.dart';
import 'auth_repository.dart';

class AuthRepositoryImpl implements AuthRepository {
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;

  @override
  Future<bool> checkUserExists(String email) async {
    DocumentSnapshot userDoc = await _firestore.collection(AppConstant.collectionUsers).doc(email).get();
    return userDoc.exists;
  }
   
  @override
  Future<void> signUp(UserModel user) async {
    await _firestore.collection(AppConstant.collectionUsers).doc(user.email).set({
      ...user.toMap(),
      'createdAt': FieldValue.serverTimestamp(),
    });
  }

  @override
  Future<UserModel?> signIn(String email) async {
    DocumentSnapshot doc = await _firestore.collection(AppConstant.collectionUsers).doc(email).get();
    if (doc.exists) {
      var data = doc.data() as Map<String, dynamic>;
      return UserModel.fromMap(data);
    }
    return null;
  }
}
