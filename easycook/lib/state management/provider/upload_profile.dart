import 'package:flutter/material.dart';
import 'package:firebase_storage/firebase_storage.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'dart:io';

class ProfileProvider with ChangeNotifier {
  String? _profilePictureUrl;
  String? get profilePictureUrl => _profilePictureUrl;

  Future<void> uploadProfilePicture(File image, String userId) async {
    try {
      Reference ref = FirebaseStorage.instance
          .ref()
          .child('profile_pictures')
          .child('$userId.jpg');

      // Mengunggah foto ke Firebase Storage
      UploadTask uploadTask = ref.putFile(image);

      // Menunggu hingga proses pengunggahan selesai
      TaskSnapshot taskSnapshot = await uploadTask;

      // Mendapatkan URL dari foto yang diunggah
      String downloadURL = await taskSnapshot.ref.getDownloadURL();

      // Menyimpan URL foto ke koleksi pengguna di Firestore
      await FirebaseFirestore.instance
          .collection('users')
          .doc(userId)
          .update({'profile_picture': downloadURL});

      // Update the state with the new profile picture URL
      _profilePictureUrl = downloadURL;
      notifyListeners();
    } catch (e) {
      print('Error saat mengunggah gambar : $e');
      // Tangani kesalahan jika terjadi
    }
  }
}
