import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:easycook/screens/resep_screen.dart';
import 'package:easycook/services/user_auth.dart';
import 'package:flutter/material.dart';
import '../components/resep_card.dart';
import 'package:easycook/models/resep_model.dart';
import 'package:easycook/services/firebase_service.dart';

class TampilScreen extends StatefulWidget {
  const TampilScreen({Key? key}) : super(key: key);

  @override
  _TampilScreenState createState() => _TampilScreenState();
}

class _TampilScreenState extends State<TampilScreen> {
  // ignore: unused_field
  final AuthServices _auth = AuthServices();
  final UserRepository _userRepository =
      UserRepository(FirebaseFirestore.instance);

  late Future<List<Recipe>> _resepFuture;
  final TextEditingController _searchController = TextEditingController();
  String _searchKeyword = '';

  @override
  void initState() {
    super.initState();
    _resepFuture = FirebaseService().ambilResep();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        backgroundColor: const Color(0xFFFFFF99).withOpacity(0.8),
        centerTitle: true,
        title: const Text(
          "Resep Masakan",
          style: TextStyle(
            fontSize: 20,
            fontWeight: FontWeight.w800,
            color: Color(0xff000000),
          ),
        ),
        toolbarHeight: 70,
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(15.0),
        child: Column(
          children: [
            TextField(
              controller: _searchController,
              onChanged: (value) {
                setState(() {
                  _searchKeyword = value.trim().toLowerCase();
                });
              },
              decoration: const InputDecoration(
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.all(
                    Radius.circular(12.0),
                  ),
                ),
                hintText: 'Cari resep...',
                prefixIcon: Icon(Icons.search),
                contentPadding: EdgeInsets.symmetric(
                  vertical: 12.0,
                  horizontal: 5.0,
                ),
              ),
            ),
            const SizedBox(height: 16),
            FutureBuilder<List<Recipe>>(
              future: _resepFuture,
              builder: (context, snapshot) {
                if (snapshot.connectionState == ConnectionState.waiting) {
                  return const CircularProgressIndicator(); // Tampilkan loading indicator
                } else if (snapshot.hasError) {
                  return Text('Error: ${snapshot.error}');
                } else {
                  // Filter resep berdasarkan kata kunci pencarian
                  List<Recipe> filteredResep = snapshot.data!.where((resep) {
                    return resep.name.toLowerCase().contains(_searchKeyword);
                  }).toList();

                  // Tampilkan data resep menggunakan GridView.builder
                  return GridView.builder(
                    physics: const NeverScrollableScrollPhysics(),
                    gridDelegate:
                        const SliverGridDelegateWithFixedCrossAxisCount(
                      crossAxisCount: 2,
                      childAspectRatio: (.6 / 1),
                      crossAxisSpacing: 15.0,
                      mainAxisSpacing: 20.0,
                    ),
                    shrinkWrap: true,
                    itemCount: filteredResep.length,
                    itemBuilder: (context, index) {
                      Recipe resep = filteredResep[index];
                      return FutureBuilder<Map<String, dynamic>?>(
                        future: _userRepository.getUserData(resep.userId),
                        builder: (context, userSnapshot) {
                          if (userSnapshot.connectionState ==
                              ConnectionState.waiting) {
                            return CircularProgressIndicator();
                          } else if (userSnapshot.hasError) {
                            return Text('Error: ${userSnapshot.error}');
                          } else {
                            // Tampilkan data resep menggunakan RecipeCard
                            return GestureDetector(
                              onTap: () {
                                Navigator.push(
                                  context,
                                  MaterialPageRoute(
                                    builder: (context) =>
                                        Resep(resepId: resep.id),
                                  ),
                                );
                              },
                              child: RecipeCard(
                                recipe: resep,
                                profilePictureUrl: '',
                              ),
                            );
                          }
                        },
                      );
                    },
                  );
                }
              },
            ),
          ],
        ),
      ),
    );
  }
}
