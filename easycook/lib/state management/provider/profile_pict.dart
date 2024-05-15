import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';

class ProfilePictureUrlProvider extends ChangeNotifier {
  String? _profilePictureUrl;

  String? get profilePictureUrl => _profilePictureUrl;

  Future<void> fetchProfilePictureUrl(String userId) async {
    try {
      // Retrieve the profile picture URL from Firestore
      DocumentSnapshot userProfileSnapshot = await FirebaseFirestore.instance
          .collection('users')
          .doc(userId)
          .get();

      // Get the profile picture URL from the document snapshot
      Map<String, dynamic>? data =
          userProfileSnapshot.data() as Map<String, dynamic>?;
      if (data != null) {
        String? profilePictureUrl = data['profile_picture'];
        _profilePictureUrl = profilePictureUrl;
        print("url profile: $profilePictureUrl");
      } else {
        print('User profile data is null');
      }
    } catch (e) {
      print('Error fetching profile picture URL: $e');
    }
    notifyListeners();
  }
}
