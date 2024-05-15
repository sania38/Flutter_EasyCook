import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:easycook/services/user_auth.dart';
import 'package:flutter/material.dart';
import 'package:easycook/models/resep_model.dart';
import 'package:easycook/services/firebase_service.dart';
import 'package:flutter/widgets.dart';

class Resep extends StatefulWidget {
  final String resepId;

  const Resep({Key? key, required this.resepId}) : super(key: key);

  @override
  State<Resep> createState() => _ResepState();
}

class _ResepState extends State<Resep> {
  late Future<Recipe?> _resepFuture;

  @override
  void initState() {
    super.initState();
    _resepFuture = FirebaseService().ambilResepId(widget.resepId);
  }

  final UserRepository _userRepository =
      UserRepository(FirebaseFirestore.instance);

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: FutureBuilder<Recipe?>(
        future: _resepFuture,
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) {
            return const Center(child: CircularProgressIndicator());
          } else if (snapshot.hasError) {
            return Center(child: Text('Error: ${snapshot.error}'));
          } else if (snapshot.hasData && snapshot.data != null) {
            final Recipe resep = snapshot.data!;

            return SingleChildScrollView(
              child: Column(
                children: [
                  Container(
                    decoration: const BoxDecoration(
                      borderRadius: BorderRadius.all(
                        Radius.circular(30.0),
                      ),
                    ),
                    child: ClipRRect(
                      borderRadius: const BorderRadius.only(
                        bottomLeft: Radius.circular(30),
                        bottomRight: Radius.circular(30),
                      ),
                      child: Image.network(
                        resep.imageURL,
                        width: double.infinity,
                        height: 300.0,
                        fit: BoxFit.fill,
                      ),
                    ),
                  ),
                  const SizedBox(
                    height: 16,
                  ),
                  SingleChildScrollView(
                    child: Padding(
                      padding: const EdgeInsets.symmetric(horizontal: 24.0),
                      child: Column(
                        children: [
                          Row(
                            mainAxisAlignment: MainAxisAlignment.spaceBetween,
                            children: [
                              Text(
                                resep.name,
                                style: const TextStyle(
                                    fontWeight: FontWeight.w600, fontSize: 30),
                              ),
                            ],
                          ),
                          const SizedBox(height: 16),
                          RichText(
                            textAlign: TextAlign.justify,
                            text: TextSpan(
                              style: const TextStyle(
                                  fontSize: 15,
                                  color: Colors.black,
                                  height: 1.5,
                                  fontWeight: FontWeight.w400),
                              text: resep
                                  .description, // Menggunakan deskripsi dari resep
                            ),
                          ),
                          const SizedBox(height: 16),
                          const Row(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text(
                                "Dipublikasikan Oleh : ",
                                style: TextStyle(
                                  fontWeight: FontWeight.w600,
                                  fontSize: 14,
                                ),
                                textAlign: TextAlign.left,
                              ),
                            ],
                          ),
                          Container(
                            child: Padding(
                              padding: const EdgeInsets.all(12.0),
                              child: Row(
                                children: [
                                  const CircleAvatar(
                                    backgroundImage: AssetImage(
                                      "assets/exProf.jpg",
                                    ),
                                    radius: 34,
                                  ),
                                  const SizedBox(width: 16),
                                  Column(
                                    crossAxisAlignment:
                                        CrossAxisAlignment.start,
                                    children: [
                                      FutureBuilder<Map<String, dynamic>?>(
                                        future: _userRepository
                                            .getUserData(resep.userId),
                                        builder: (context, userSnapshot) {
                                          return Text(
                                            userSnapshot.data!['username'],
                                            style: const TextStyle(
                                                fontSize: 16,
                                                fontWeight: FontWeight.w600),
                                          );
                                        },
                                      ),
                                      const SizedBox(
                                        height: 8,
                                      ),
                                      FutureBuilder<int>(
                                        future: FirebaseService()
                                            .countResepByUser(resep.userId),
                                        builder: (context, snapshot) {
                                          if (snapshot.connectionState ==
                                              ConnectionState.waiting) {
                                            return const CircularProgressIndicator();
                                          } else if (snapshot.hasError) {
                                            return Text(
                                                'Error: ${snapshot.error}');
                                          } else {
                                            int totalResep = snapshot.data!;
                                            return Text(
                                              "Total Resep $totalResep",
                                              style: const TextStyle(
                                                fontSize: 14,
                                                fontWeight: FontWeight.w500,
                                              ),
                                            );
                                          }
                                        },
                                      ),
                                    ],
                                  ),
                                  const Spacer(),
                                ],
                              ),
                            ),
                          ),
                          const SizedBox(height: 14),
                          Padding(
                            padding: const EdgeInsets.symmetric(horizontal: 14),
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                const Text(
                                  "Bahan-Bahan",
                                  style: TextStyle(
                                      fontSize: 24,
                                      fontWeight: FontWeight.w500),
                                ),
                                const SizedBox(
                                  height: 12,
                                ),
                                Container(
                                  decoration: BoxDecoration(
                                    color: Colors.white,
                                    borderRadius: BorderRadius.circular(8),
                                    boxShadow: [
                                      BoxShadow(
                                        color: Colors.grey.withOpacity(0.5),
                                        spreadRadius: 2,
                                        blurRadius: 5,
                                        offset: const Offset(0, 3),
                                      ),
                                    ],
                                  ),
                                  padding: const EdgeInsets.only(
                                      left: 14, right: 14, bottom: 20),
                                  child: ListView.builder(
                                    shrinkWrap: true,
                                    physics:
                                        const NeverScrollableScrollPhysics(),
                                    itemCount: resep.ingredients.length,
                                    itemBuilder: (context, index) {
                                      final ingredient =
                                          resep.ingredients[index];
                                      return Text(
                                        ingredient,
                                        style: const TextStyle(
                                          fontSize: 16,
                                          fontWeight: FontWeight.w500,
                                          height: 2,
                                        ),
                                      );
                                    },
                                  ),
                                ),
                                const SizedBox(height: 24),
                                const Text(
                                  "Cara memasak",
                                  style: TextStyle(
                                      fontSize: 24,
                                      fontWeight: FontWeight.w500),
                                ),
                                const SizedBox(
                                  height: 12,
                                ),
                                Container(
                                  decoration: BoxDecoration(
                                    color: Colors.white,
                                    borderRadius: BorderRadius.circular(8),
                                    boxShadow: [
                                      BoxShadow(
                                        color: Colors.grey.withOpacity(0.5),
                                        spreadRadius: 2,
                                        blurRadius: 5,
                                        offset: const Offset(0, 3),
                                      ),
                                    ],
                                  ),
                                  padding: const EdgeInsets.only(
                                      left: 14, right: 14, bottom: 20),
                                  child: ListView.builder(
                                    shrinkWrap: true,
                                    physics:
                                        const NeverScrollableScrollPhysics(),
                                    itemCount: resep.cookingSteps.length,
                                    itemBuilder: (context, index) {
                                      final step = resep.cookingSteps[index];
                                      if (step != null) {
                                        return Row(
                                          crossAxisAlignment:
                                              CrossAxisAlignment.start,
                                          children: [
                                            const Text(
                                              '\u2022',
                                              style: TextStyle(fontSize: 24),
                                            ),
                                            const SizedBox(width: 8.0),
                                            Expanded(
                                              child: ListBody(
                                                children: [
                                                  Text(
                                                    step,
                                                    style: const TextStyle(
                                                      fontSize: 16,
                                                      color: Colors.black,
                                                      fontWeight:
                                                          FontWeight.w400,
                                                      height: 2,
                                                    ),
                                                  ),
                                                  const SizedBox(
                                                    height: 12,
                                                  )
                                                ],
                                              ),
                                            ),
                                          ],
                                        );
                                      } else {
                                        return Container();
                                      }
                                    },
                                  ),
                                ),
                                const SizedBox(
                                  height: 14,
                                )
                              ],
                            ),
                          ),
                        ],
                      ),
                    ),
                  ),
                ],
              ),
            );
          } else {
            return const Center(child: Text('No Data'));
          }
        },
      ),
    );
  }
}
