import '../model/user_model.dart';

abstract class AuthRepository {
  Future<bool> checkUserExists(String email);
  Future<void> signUp(UserModel user);
  Future<UserModel?> signIn(String email);
}
