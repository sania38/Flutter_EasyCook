import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:easycook/models/resep_model.dart';
import 'package:easycook/services/user_auth.dart';

class RecipeCard extends StatelessWidget {
  final Recipe recipe;
  final String profilePictureUrl;

  final UserRepository _userRepository =
      UserRepository(FirebaseFirestore.instance);

  RecipeCard({
    Key? key,
    required this.recipe,
    required this.profilePictureUrl,
  }) : super(key: key);

  Future<String?> fetchProfilePictureUrl(String userId) async {
    try {
      DocumentSnapshot userProfileSnapshot = await FirebaseFirestore.instance
          .collection('users')
          .doc(userId)
          .get();

      Map<String, dynamic>? data =
          userProfileSnapshot.data() as Map<String, dynamic>?;
      if (data != null) {
        return data['profile_picture'];
      } else {
        return null;
      }
    } catch (e) {
      print('Error fetching profile picture URL: $e');
      return null;
    }
  }

  @override
  Widget build(BuildContext context) {
    return FutureBuilder<String?>(
        future: fetchProfilePictureUrl(recipe.userId),
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) {
            return const CircularProgressIndicator();
          } else if (snapshot.hasError) {
            return Text('Error: ${snapshot.error}');
          } else {
            String? profilePictureUrl = snapshot.data;
            return Container(
              padding: const EdgeInsets.all(2),
              decoration: BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.circular(10),
                boxShadow: [
                  BoxShadow(
                    color: Colors.grey.withOpacity(0.5),
                    spreadRadius: 2,
                    blurRadius: 5,
                    offset: const Offset(0, 3),
                  ),
                ],
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Padding(
                    padding: const EdgeInsets.all(8.0),
                    child: Row(
                      children: [
                        CircleAvatar(
                          backgroundImage: profilePictureUrl != null
                              ? NetworkImage(profilePictureUrl)
                                  as ImageProvider<Object>
                              : const AssetImage('assets/exProf.jpg'),
                          radius: 20,
                        ),
                        const SizedBox(width: 10),
                        FutureBuilder<String?>(
                          future: _userRepository.getUserName(recipe.userId),
                          builder: (context, snapshot) {
                            if (snapshot.connectionState ==
                                ConnectionState.waiting) {
                              return const CircularProgressIndicator();
                            } else if (snapshot.hasError) {
                              return Text('Error: ${snapshot.error}');
                            } else {
                              return Text(snapshot.data ?? 'Unknown');
                            }
                          },
                        ),
                      ],
                    ),
                  ),
                  const SizedBox(height: 6),
                  Container(
                    decoration: BoxDecoration(
                      borderRadius: const BorderRadius.only(
                        topLeft: const Radius.circular(25),
                        topRight: Radius.circular(20),
                        bottomLeft: Radius.circular(20),
                        bottomRight: Radius.circular(25),
                      ),
                      boxShadow: [
                        BoxShadow(
                          color: Colors.grey.withOpacity(0.5),
                          spreadRadius: 1,
                          blurRadius: 4,
                          offset: const Offset(-3, 3),
                        ),
                      ],
                    ),
                    child: ClipRRect(
                      borderRadius: const BorderRadius.only(
                        topLeft: Radius.circular(25),
                        topRight: Radius.circular(15),
                        bottomLeft: Radius.circular(15),
                        bottomRight: Radius.circular(25),
                      ),
                      child: Image.network(
                        recipe.imageURL,
                        fit: BoxFit.cover,
                        width: double.infinity,
                        height: 140,
                      ),
                    ),
                  ),
                  Padding(
                    padding: const EdgeInsets.symmetric(horizontal: 8.0),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        const SizedBox(height: 16),
                        Text(
                          recipe.name,
                          style: const TextStyle(
                            fontSize: 18,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                        const SizedBox(height: 4),
                        Text(
                          recipe.description,
                          maxLines: 2,
                          overflow: TextOverflow.ellipsis,
                        ),
                      ],
                    ),
                  ),
                ],
              ),
            );
          }
        });
  }
}
