import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';

class AuthServices {
  final _auth = FirebaseAuth.instance;

  Future<void> login({required String email, required String password}) async {
    try {
      await _auth.signInWithEmailAndPassword(email: email, password: password);
    } on FirebaseAuthException catch (e) {
      throw e.message ?? 'Something wrong!';
    } catch (e) {
      rethrow;
    }
  }

  Future<void> register(
      {required String email, required String password}) async {
    try {
      final userCredential = await _auth.createUserWithEmailAndPassword(
          email: email, password: password);

      // Ambil nama pengguna dari alamat email
      String username = email.split('@').first;

      // Tambahkan pengguna yang berhasil mendaftar ke Firestore
      await addUserToFirestore(userCredential.user!, username);
    } on FirebaseAuthException catch (e) {
      throw e.message ?? 'Something wrong!';
    } catch (e) {
      rethrow;
    }
  }

  Future<void> addUserToFirestore(User user, String username) async {
    try {
      // Dapatkan referensi ke koleksi pengguna di Firestore
      CollectionReference users =
          FirebaseFirestore.instance.collection('users');

      // Tambahkan data pengguna ke Firestore
      await users.doc(user.uid).set({
        'uid': user.uid,
        'email': user.email,
        'username': username,
      });
    } catch (e) {
      throw 'Failed to add user to Firestore: $e';
    }
  }
}

class UserRepository {
  final FirebaseFirestore _firestore;

  UserRepository(this._firestore);

  Future<Map<String, dynamic>?> getUserData(String userId) async {
    DocumentSnapshot userData =
        await _firestore.collection('users').doc(userId).get();
    return userData.data() as Map<String, dynamic>?;
  }

  Future<String?> getUserName(String userId) async {
    Map<String, dynamic>? userData = await getUserData(userId);
    return userData?['username'];
  }
}
