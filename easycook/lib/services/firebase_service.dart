import 'dart:io';
import 'package:easycook/models/resep_model.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:uuid/uuid.dart';
import 'package:firebase_storage/firebase_storage.dart';
import 'package:cloud_firestore/cloud_firestore.dart';

class FirebaseService {
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;
  final FirebaseStorage _storage = FirebaseStorage.instance;
  final FirebaseAuth _auth = FirebaseAuth.instance;

  Future<void> simpanResep({
    required String namaMasakan,
    required String deskripsi,
    required List<String> bahan,
    required List<String> caraMemasak,
    File? foto,
    required String userId,
  }) async {
    try {
      CollectionReference resep = _firestore.collection('resep');
      await resep.add({
        'nama_masakan': namaMasakan,
        'deskripsi': deskripsi,
        'bahan': bahan,
        'cara_memasak': caraMemasak,
        'foto_url': foto != null ? await uploadFoto(foto) : null,
        'user_id': userId,
        'created_at': FieldValue.serverTimestamp(),
      });
    } catch (e) {
      print("Gagal menyimpan resep: $e");
      throw Exception("Gagal menyimpan resep");
    }
  }

  Future<String> uploadFoto(File foto) async {
    try {
      String fileName = Uuid().v4();

      // Upload file ke Firebase Storage
      TaskSnapshot snapshot =
          await _storage.ref().child('images/$fileName').putFile(foto);

      // Get download URL from snapshot
      String downloadUrl = await snapshot.ref.getDownloadURL();

      // Return download URL
      return downloadUrl;
    } catch (e) {
      print("Gagal mengunggah foto: $e");
      throw Exception("Gagal mengunggah foto");
    }
  }

// Method to get a stream of recipe data
  Stream<List<Recipe>> streamResep() {
    return _firestore.collection('resep').snapshots().map(
          (snapshot) =>
              snapshot.docs.map((doc) => Recipe.fromSnapshot(doc)).toList(),
        );
  }

  Future<List<Recipe>> ambilResep() async {
    try {
      QuerySnapshot querySnapshot = await _firestore.collection('resep').get();

      List<Recipe> resepList = querySnapshot.docs.map((doc) {
        return Recipe(
          id: doc.id,
          name: doc['nama_masakan'],
          description: doc['deskripsi'],
          ingredients: List<String>.from(doc['bahan']),
          cookingSteps: List<String>.from(doc['cara_memasak']),
          imageURL: doc['foto_url'],
          userId: doc['user_id'],
          createdAt: (doc['created_at'] as Timestamp).toDate(),
          profileName: '',
        );
      }).toList();

      return resepList;
    } catch (e) {
      print("Gagal mengambil resep: $e");
      throw Exception("Gagal mengambil resep");
    }
  }

  Future<List<Recipe>> ambilResepUser() async {
    try {
      // Dapatkan ID pengguna yang sedang login
      String userId = FirebaseAuth.instance.currentUser!.uid;

      // Query resep berdasarkan user_id
      QuerySnapshot querySnapshot = await _firestore
          .collection('resep')
          .where('user_id', isEqualTo: userId)
          .get();

      // Mapping data resep dari dokumen snapshot
      List<Recipe> resepList = querySnapshot.docs.map((doc) {
        return Recipe(
          id: doc.id,
          name: doc['nama_masakan'],
          description: doc['deskripsi'],
          ingredients: List<String>.from(doc['bahan']),
          cookingSteps: List<String>.from(doc['cara_memasak']),
          imageURL: doc['foto_url'],
          userId: doc['user_id'],
          createdAt: doc['created_at'].toDate(),
          profileName: '',
        );
      }).toList();

      return resepList;
    } catch (e) {
      print("Gagal mengambil resep: $e");
      throw Exception("Gagal mengambil resep");
    }
  }

  Future<Recipe?> ambilResepId(String resepId) async {
    try {
      // Query resep berdasarkan ID
      DocumentSnapshot docSnapshot =
          await _firestore.collection('resep').doc(resepId).get();

      // Periksa apakah dokumen ada
      if (docSnapshot.exists) {
        // Mapping data resep dari dokumen snapshot
        Recipe resep = Recipe(
          id: docSnapshot.id,
          name: docSnapshot['nama_masakan'],
          description: docSnapshot['deskripsi'],
          ingredients: List<String>.from(docSnapshot['bahan']),
          cookingSteps: List<String>.from(docSnapshot['cara_memasak']),
          imageURL: docSnapshot['foto_url'],
          userId: docSnapshot['user_id'],
          createdAt: docSnapshot['created_at'].toDate(),
          profileName: '',
        );

        // Ambil data pengguna yang mempublikasikan resep
        DocumentSnapshot userSnapshot =
            await _firestore.collection('users').doc(resep.userId).get();

        // Periksa apakah dokumen pengguna ada
        if (userSnapshot.exists) {
          //  nama pengguna dari dokumen pengguna
          resep.profileName = userSnapshot['username'];
        }

        return resep;
      } else {
        return null;
      }
    } catch (e) {
      print("Gagal mengambil resep: $e");
      throw Exception("Gagal mengambil resep");
    }
  }

  Future<void> hapusResep(String resepId) async {
    try {
      // Hapus dokumen resep berdasarkan ID dari Firebase Firestore
      await _firestore.collection('resep').doc(resepId).delete();

      // Jika foto terkait resep ada, hapus juga dari Firebase Storage
      DocumentSnapshot snapshot =
          await _firestore.collection('resep').doc(resepId).get();
      if (snapshot.exists) {
        String? fotoUrl = snapshot['foto_url'];
        if (fotoUrl != null) {
          // Ekstrak nama file dari URL
          String fileName = fotoUrl.split('/').last;

          // Hapus file dari Firebase Storage
          await _storage.ref().child('images/$fileName').delete();
        }
      }
    } catch (e) {
      print('Error deleting recipe: $e');
      throw Exception('Failed to delete recipe');
    }
  }

  Future<void> updateResep({
    required String recipeId,
    required String namaMasakan,
    required String deskripsi,
    required List<String> bahan,
    required List<String> caraMemasak,
    required File? foto,
    required String userId,
    String? imageURL,
  }) async {
    try {
      String? uploadedImageUrl;
      if (foto != null) {
        final ref = _storage.ref().child('resep_images').child(recipeId);
        final uploadTask = ref.putFile(foto);
        await uploadTask.whenComplete(() async {
          uploadedImageUrl = await ref.getDownloadURL();
        });
      }

      final imageUrl = imageURL ?? uploadedImageUrl;

      // Update the recipe data in Firestore
      await _firestore.collection('resep').doc(recipeId).update({
        'nama_masakan': namaMasakan,
        'deskripsi': deskripsi,
        'bahan': bahan,
        'cara_memasak': caraMemasak,
        'foto_url': imageUrl, // Update the image URL
      });
    } catch (e) {
      throw Exception('Error updating recipe: $e');
    }
  }

  Future<String> getUserName() async {
    try {
      // Get the current user
      User? user = _auth.currentUser;

      if (user != null) {
        // Retrieve user data from Firestore
        DocumentSnapshot userData =
            await _firestore.collection('users').doc(user.uid).get();

        // Extract the user's name from the userData document
        String userName = userData['username'];

        return userName;
      } else {
        // No user signed in
        throw Exception("No user signed in");
      }
    } catch (e) {
      print("Error getting user name: $e");
      throw Exception("Failed to get user name");
    }
  }

  Future<int> countResepByUser(String userId) async {
    try {
      QuerySnapshot querySnapshot = await _firestore
          .collection('resep')
          .where('user_id', isEqualTo: userId)
          .get();

      return querySnapshot.size;
    } catch (e) {
      print("Error counting recipes by user: $e");
      throw Exception("Failed to count recipes by user");
    }
  }

  Future<void> updateUserProfile({
    required String userId,
    String? username,
    String? email,
    File? profileImage,
  }) async {
    try {
      // Prepare data to update
      Map<String, dynamic> userData = {};
      if (username != null) {
        userData['username'] = username;
      }
      if (email != null) {
        userData['email'] = email;
      }
      if (profileImage != null) {
        // Upload profile image if provided
        String profileImageUrl = await uploadProfileImage(profileImage, userId);
        userData['profile_image_url'] = profileImageUrl;
      }

      // Update user data in Firestore
      await _firestore.collection('users').doc(userId).update(userData);
    } catch (e) {
      print('Error updating user profile: $e');
      throw Exception('Failed to update user profile');
    }
  }

  Future<String> uploadProfileImage(File image, String userId) async {
    try {
      // Generate a unique filename using UUID
      String fileName = Uuid().v4();

      // Upload image to Firebase Storage
      TaskSnapshot snapshot = await _storage
          .ref()
          .child('profile_images')
          .child(userId)
          .child(fileName)
          .putFile(image);

      // Get download URL from snapshot
      String downloadUrl = await snapshot.ref.getDownloadURL();

      return downloadUrl;
    } catch (e) {
      print('Error uploading profile image: $e');
      throw Exception('Failed to upload profile image');
    }
  }
}
