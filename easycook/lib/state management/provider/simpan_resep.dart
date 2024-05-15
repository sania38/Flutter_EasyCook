import 'dart:io';
import 'package:easycook/screens/main_screen.dart';
import 'package:easycook/screens/resep_screen.dart';
import 'package:easycook/screens/tampil_screen.dart';
import 'package:easycook/services/firebase_service.dart';
import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';

class SaveRecipeProvider extends ChangeNotifier {
  File? image;
  bool _isLoading = false;
  bool _isFailure = false;
  bool _isSuccess = false;
  final FirebaseService _firebaseService = FirebaseService();

  bool get isLoading => _isLoading;
  bool get isFailure => _isFailure;
  bool get isSuccess => _isSuccess;

  void simpanResep({
    required BuildContext context,
    required TextEditingController foodcController,
    required TextEditingController descController,
    required List<String> ingredients,
    required List<String> howTo,
    required File? image, // Accepting nullable File
    required TextEditingController ingredientController,
    required TextEditingController howToController,
  }) async {
    _setLoading(true);

    try {
      User? user = FirebaseAuth.instance.currentUser;
      if (user != null) {
        if (image != null) {
          await _firebaseService.simpanResep(
            namaMasakan: foodcController.text,
            deskripsi: descController.text,
            bahan: ingredients,
            caraMemasak: howTo,
            foto: image,
            userId: user.uid,
          );

          _clearFields(
            foodcController,
            descController,
            ingredients,
            howTo,
            ingredientController,
            howToController,
          );

          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(
              content: Text('Resep Berhasil Disimpan'),
              backgroundColor: Colors.green,
            ),
          );
          Navigator.pushReplacement(
            context,
            MaterialPageRoute(
              builder: (context) =>
                  MainScreen(), // Ganti ResepPage dengan halaman yang ingin Anda navigasikan
            ),
          );
        }
      }
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Gagal menambahkan resep: ${e.toString()}')),
      );
    }
  }

  void _setLoading(bool value) {
    _isLoading = value;
    notifyListeners();
  }

  void _resetState({bool success = false, bool failure = false}) {
    _isLoading = false;
    _isFailure = failure;
    _isSuccess = success;
    notifyListeners();
  }

  void _clearFields(
    TextEditingController foodcController,
    TextEditingController descController,
    List<String> ingredients,
    List<String> howTo,
    TextEditingController ingredientController,
    TextEditingController howToController,
  ) {
    foodcController.clear();
    descController.clear();
    ingredients.clear();
    howTo.clear();
    ingredientController.clear();
    howToController.clear();
    image = null;
    notifyListeners();
  }
}
