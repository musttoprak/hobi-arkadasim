import 'package:firebase_auth/firebase_auth.dart';
import 'package:cloud_firestore/cloud_firestore.dart';

class AuthService {
  final FirebaseAuth _auth = FirebaseAuth.instance;
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;

  Future<bool> checkUserExists(String email) async {
    try {
      QuerySnapshot<Map<String, dynamic>> querySnapshot = await _firestore
          .collection('users')
          .where('email', isEqualTo: email)
          .get();

      return querySnapshot.docs.isNotEmpty;
    } catch (e) {
      print('Kullanıcı varlığı kontrolünde hata: $e');
      return false;
    }
  }
  Future<bool> signincheckUser(String email,String password) async {
    try {
      QuerySnapshot<Map<String, dynamic>> querySnapshot = await _firestore
          .collection('users')
          .where('email', isEqualTo: email).
      where('password',isEqualTo: password)
          .get();

      return querySnapshot.docs.isNotEmpty;
    } catch (e) {
      print('Kullanıcı varlığı kontrolünde hata: $e');
      return false;
    }
  }
  Future<bool> registerWithEmailAndPassword(String email, String password) async {
    try {
      if (await checkUserExists(email)) {
        print('Bu e-posta adresi zaten kayıtlı.');
        return false;
      }

      UserCredential userCredential = await _auth.createUserWithEmailAndPassword(
        email: email,
        password: password,
      );

      String uid = userCredential.user!.uid;

      await _firestore.collection('users').doc(uid).set({
        'email': email,
        'password':password
      });

      return true;
    } catch (e) {
      print('Kayıt hatası: $e');
      return false;
    }
  }
  Future<String?> signInWithEmailAndPassword(String email, String password) async {
    try {
      if (!(await signincheckUser(email,password))) {
        print('e posta veya şifre veya böyle bir hesap yok');
        return null;
      }

      UserCredential userCredential = await _auth.signInWithEmailAndPassword(
        email: email,
        password: password,
      );

      String uid = userCredential.user!.uid;

      return uid;
    } catch (e) {
      print('Giriş hatası: $e');
      return null;
    }
  }
}