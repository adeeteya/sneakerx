import 'package:firebase_auth/firebase_auth.dart';
import 'package:sneakerx/services/firestore_service.dart';

class AuthenticationService {
  final FirebaseAuth _auth = FirebaseAuth.instance;

  User? getUser() {
    return _auth.currentUser;
  }

  Future signInWithEmailAndPassword(
      {required String email, required String password}) async {
    try {
      UserCredential userCredential = await _auth.signInWithEmailAndPassword(
          email: email, password: password);
      User? user = userCredential.user;
      return user;
    } catch (e) {
      return e;
    }
  }

  Future createUserWithEmailAndPassword(
      {required String email, required String password}) async {
    try {
      UserCredential userCredential = await _auth
          .createUserWithEmailAndPassword(email: email, password: password);
      User? user = userCredential.user;
      FirestoreService().createUserDetails();
      return user;
    } catch (e) {
      return e;
    }
  }

  Future resetPassword({String? email}) async {
    try {
      return await _auth.sendPasswordResetEmail(email: email ?? "");
    } catch (e) {
      return e;
    }
  }

  Future signOut() async {
    await _auth.signOut();
  }

  Stream<User?> get onAuthStateChanged => _auth.userChanges();
}
