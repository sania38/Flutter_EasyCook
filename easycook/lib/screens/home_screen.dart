import 'package:carousel_slider/carousel_slider.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:easycook/screens/main_screen.dart';
import 'package:easycook/state%20management/provider/profile_pict.dart';
import 'package:easycook/components/popular_card.dart';
import 'package:easycook/models/resep_model.dart';
import 'package:easycook/screens/ai_chat.dart';
import 'package:easycook/screens/resep_screen.dart';
import 'package:easycook/services/firebase_service.dart';
import 'package:easycook/services/user_auth.dart';
import 'package:firebase_auth/firebase_auth.dart' as firebase_auth;
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

class HomePage extends StatefulWidget {
  const HomePage({super.key});

  @override
  State<HomePage> createState() => _HomePageState();
}

class _HomePageState extends State<HomePage> {
  final FirebaseService _firebaseService = FirebaseService();
  firebase_auth.User? _user;
  late Future<List<Recipe>> _resepFuture;

  String _searchKeyword = '';
  final UserRepository _userRepository =
      UserRepository(FirebaseFirestore.instance);

  @override
  void initState() {
    super.initState();
    _resepFuture = FirebaseService().ambilResep();

    // Fetch the current user
    _user = FirebaseAuth.instance.currentUser;

    // Fetch the user's profile picture URL
    if (_user != null) {
      Provider.of<ProfilePictureUrlProvider>(context, listen: false)
          .fetchProfilePictureUrl(_user!.uid);
    }
  }

  @override
  Widget build(BuildContext context) {
    int maxItems = 2;
    TextEditingController searchController = TextEditingController();
    return Scaffold(
      body: Stack(
        children: [
          Positioned(
            top: 0,
            left: 0,
            right: 0,
            child: Container(
              height: MediaQuery.of(context).size.height *
                  0.2, // Set 1/4 bagian atas layar
              decoration: const BoxDecoration(
                color: Color(
                    0xFFFFFF99), // Ganti dengan warna latar belakang yang Anda inginkan
                borderRadius: BorderRadius.only(
                  bottomLeft: Radius.circular(30.0),
                  bottomRight: Radius.circular(30.0),
                ),
              ),
            ),
          ),
          SingleChildScrollView(
            child: Container(
              padding: const EdgeInsets.all(20.0),
              child: Container(
                child: Column(
                  children: [
                    SafeArea(
                      child: Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          CircleAvatar(
                            backgroundImage: Provider.of<
                                            ProfilePictureUrlProvider>(context)
                                        .profilePictureUrl !=
                                    null
                                ? NetworkImage(
                                        Provider.of<ProfilePictureUrlProvider>(
                                                context)
                                            .profilePictureUrl!)
                                    as ImageProvider<Object>
                                : const AssetImage(
                                    'assets/exProf.jpg'), // Use a placeholder if _profilePictureUrl is null
                            radius: 25,
                          ),
                          FutureBuilder<String>(
                            future: _firebaseService
                                .getUserName(), // Future to fetch user's name
                            builder: (context, snapshot) {
                              if (snapshot.connectionState ==
                                  ConnectionState.waiting) {
                                return const CircularProgressIndicator();
                              } else if (snapshot.hasError) {
                                return Text('Error: ${snapshot.error}');
                              } else {
                                final userName = snapshot.data;
                                return Text(
                                  'Hallo, $userName',
                                  style: const TextStyle(
                                      fontSize: 20,
                                      fontWeight: FontWeight.bold),
                                );
                              }
                            },
                          ),
                          IconButton(
                            onPressed: () {
                              Navigator.push(
                                context,
                                MaterialPageRoute(
                                    builder: (context) => const AiChat()),
                              );
                            },
                            icon: const Icon(
                              Icons.chat,
                              size: 24.0,
                            ),
                          ),
                        ],
                      ),
                    ),
                    const SizedBox(
                        height: 20), // Spasi antara avatar dan search bar
                    TextFormField(
                      controller: searchController,
                      decoration: const InputDecoration(
                        border: OutlineInputBorder(
                          borderRadius: BorderRadius.all(
                            Radius.circular(20.0),
                          ),
                        ),
                        labelText: "Cari Resep",
                        prefixIcon: Icon(
                          Icons.search,
                          size: 24.0,
                        ),
                        contentPadding: EdgeInsets.symmetric(
                          vertical: 12.0,
                          horizontal: 5.0,
                        ),
                      ),
                    ),
                    const SizedBox(
                        height: 20), // Adding space between search bar and card
                    SizedBox(
                      height: 200, // Set the height of the banner
                      child: SizedBox(
                        height: 200, // Set the height of the banner
                        child: CarouselSlider(
                          options: CarouselOptions(
                            autoPlay: true, // Set auto play to true
                            aspectRatio:
                                2.0, // Set the aspect ratio of the banner items
                            enlargeCenterPage: true, // Enlarge center item
                          ),
                          items: [
                            // Add your banner items here
                            Container(
                              width: 300, // Set the width of each banner item
                              margin: const EdgeInsets.only(
                                  right: 10), // Add margin between items
                              decoration: const BoxDecoration(
                                borderRadius: BorderRadius.all(
                                  Radius.circular(12.0),
                                ),
                              ),
                              child: ClipRRect(
                                borderRadius: BorderRadius.circular(12.0),
                                child: Image.asset(
                                  "assets/banner1.jpg",
                                  width: 120.0,
                                  height: 120.0,
                                  fit: BoxFit.fill,
                                ),
                              ),
                            ),
                            Container(
                              decoration: const BoxDecoration(
                                borderRadius: BorderRadius.all(
                                  Radius.circular(12.0),
                                ),
                              ),
                              width: 300, // Set the width of each banner item
                              margin: const EdgeInsets.only(
                                  right: 10), // Add margin between items
                              child: ClipRRect(
                                borderRadius: BorderRadius.circular(12.0),
                                child: Image.asset(
                                  "assets/banner2.jpg",
                                  width: 120.0,
                                  height: 120.0,
                                  fit: BoxFit.fill,
                                ),
                              ),
                            ),
                            Container(
                              decoration: const BoxDecoration(
                                borderRadius: BorderRadius.all(
                                  Radius.circular(12.0),
                                ),
                              ),
                              width: 300, // Set the width of each banner item
                              margin: const EdgeInsets.only(
                                  right: 10), // Add margin between items
                              child: ClipRRect(
                                borderRadius: BorderRadius.circular(12.0),
                                child: Image.asset(
                                  "assets/banner3.jpg",
                                  width: 120.0,
                                  height: 120.0,
                                  fit: BoxFit.fill,
                                ),
                              ),
                            ),
                          ],
                        ),
                      ),
                    ),
                    const SizedBox(
                      height: 20,
                    ),
                    Padding(
                      padding: const EdgeInsets.only(left: 5.0),
                      child: Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          const Text(
                            'Resep Terbaru',
                            style: TextStyle(
                                fontWeight: FontWeight.w600, fontSize: 20),
                          ),
                          IconButton(
                            onPressed: () {
                              Navigator.push(
                                context,
                                MaterialPageRoute(
                                    builder: (context) => const MainScreen()),
                              );
                            },
                            icon: const Icon(
                              Icons.arrow_right_alt_outlined,
                              size: 40.0,
                            ),
                          ),
                        ],
                      ),
                    ),
                    FutureBuilder<List<Recipe>>(
                      future: _resepFuture,
                      builder: (context, snapshot) {
                        if (snapshot.connectionState ==
                            ConnectionState.waiting) {
                          return const CircularProgressIndicator(); // Tampilkan loading indicator
                        } else if (snapshot.hasError) {
                          return Text('Error: ${snapshot.error}');
                        } else {
                          // Filter resep berdasarkan kata kunci pencarian
                          List<Recipe> filteredResep =
                              snapshot.data!.where((resep) {
                            return resep.name
                                .toLowerCase()
                                .contains(_searchKeyword);
                          }).toList();

                          // Tampilkan data resep menggunakan GridView.builder
                          filteredResep.sort(
                              (a, b) => b.createdAt.compareTo(a.createdAt));

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
                            itemCount: filteredResep.length < maxItems
                                ? filteredResep.length
                                : maxItems,
                            itemBuilder: (context, index) {
                              Recipe resep = filteredResep[index];
                              return FutureBuilder<Map<String, dynamic>?>(
                                future:
                                    _userRepository.getUserData(resep.userId),
                                builder: (context, userSnapshot) {
                                  if (userSnapshot.connectionState ==
                                      ConnectionState.waiting) {
                                    return const CircularProgressIndicator(); // Tampilkan loading indicator
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
                                      child: PopularCard(
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
            ),
          ),
        ],
      ),
    );
  }
}
