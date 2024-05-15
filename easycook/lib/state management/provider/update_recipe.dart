import 'dart:io';

import 'package:easycook/screens/main_screen.dart';
import 'package:easycook/services/firebase_service.dart';
import 'package:flutter/material.dart';

class UpdateRecipeProvider extends ChangeNotifier {
  FirebaseService _firebaseService = FirebaseService();
  File? image;

  Future<void> updateResep({
    required String userId,
    required String recipeId,
    required TextEditingController foodcController,
    required TextEditingController descController,
    required List<String> ingredients,
    required List<String> howTo,
    required dynamic image,
    required BuildContext context,
  }) async {
    try {
      if (image != null) {
        // Upload the new image to Firebase Storage
        final imageUrl = await _firebaseService.uploadFoto(image!);

        // Update the recipe data in Firestore with the new image URL
        await _firebaseService.updateResep(
          recipeId: recipeId,
          namaMasakan: foodcController.text,
          deskripsi: descController.text,
          bahan: ingredients,
          caraMemasak: howTo,
          foto: image,
          userId: userId,
          imageURL: imageUrl,
        );
      } else {
        // If no new image is selected, update the recipe data without changing the image
        await _firebaseService.updateResep(
          recipeId: recipeId,
          namaMasakan: foodcController.text,
          deskripsi: descController.text,
          bahan: ingredients,
          caraMemasak: howTo,
          foto: image,
          userId: userId,
        );
      }

      _showSnackBar(context, 'Resep berhasil diperbarui!');
      Navigator.pushReplacement(
        context,
        MaterialPageRoute(
          builder: (context) => MainScreen(),
        ),
      );
    } catch (e) {
      _showSnackBar(context, 'Error saat memperbarui resep: $e');
    }
  }

  void _showSnackBar(BuildContext context, String message) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(message),
      ),
    );
  }
}
