import 'dart:io';

import 'package:easycook/services/firebase_service.dart';
import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';

class SaveRecipeProvider extends ChangeNotifier {
  File? image;
  bool _isLoading = false;
  bool _isFailure = false;
  bool _isSuccess = false;
  FirebaseService _firebaseService =
      FirebaseService(); // Sesuaikan dengan nama layanan Firebase Anda

  bool get isLoading => _isLoading;
  bool get isFailure => _isFailure;
  bool get isSuccess => _isSuccess;

  void simpanResep({
    required TextEditingController foodcController,
    required TextEditingController descController,
    required List<String> ingredients,
    required List<String> howTo,
    required dynamic image, // Sesuaikan tipe data gambar yang digunakan
    required TextEditingController ingredientController,
    required TextEditingController howToController,
  }) async {
    _isLoading = true;
    _isFailure = false;
    _isSuccess = false;
    notifyListeners();

    try {
      User? user = FirebaseAuth.instance.currentUser;
      if (user != null) {
        await _firebaseService.simpanResep(
          namaMasakan: foodcController.text,
          deskripsi: descController.text,
          bahan: ingredients,
          caraMemasak: howTo,
          foto: image,
          userId: user.uid,
        );

        _isLoading = false;
        _isFailure = false;
        _isSuccess = true;
        notifyListeners();

        // Membersihkan formulir setelah sukses menyimpan resep
        foodcController.clear();
        descController.clear();
        ingredientController.clear();
        howToController.clear();
      } else {
        _isLoading = false;
        _isFailure = true;
        _isSuccess = false;
        notifyListeners();
      }
    } catch (e) {
      _isLoading = false;
      _isFailure = true;
      _isSuccess = false;
      notifyListeners();
    }
  }
}
