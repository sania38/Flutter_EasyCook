import 'package:cloud_firestore/cloud_firestore.dart';

class Recipe {
  final String id;
  final String name;
  final String description;
  final List<String> ingredients;
  final List<String> cookingSteps;
  final String imageURL;
  final String userId;
  String profileName;
  final DateTime createdAt;
  int likeCount;

  Recipe({
    required this.id,
    required this.name,
    required this.description,
    required this.ingredients,
    required this.cookingSteps,
    required this.imageURL,
    required this.userId,
    required this.profileName,
    required this.createdAt,
    this.likeCount = 0,
  });

  factory Recipe.fromSnapshot(DocumentSnapshot doc) {
    Map<String, dynamic> data = doc.data() as Map<String, dynamic>;
    return Recipe(
      id: doc.id,
      name: data['nama_masakan'] ?? '',
      description: data['deskripsi'] ?? '',
      ingredients: List<String>.from(data['bahan'] ?? []),
      cookingSteps: List<String>.from(data['cara_memasak'] ?? []),
      imageURL: data['foto_url'] ?? '',
      userId: data['user_id'] ?? '',
      createdAt: (data['created_at'] as Timestamp).toDate(),
      profileName: '',
      likeCount: data['likeCount'] ?? 0,
    );
  }
}
