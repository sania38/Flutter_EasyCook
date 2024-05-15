import 'dart:io';
import 'package:easycook/screens/tambah_screen.dart';
import 'package:easycook/state%20management/provider/profile_pict.dart';
import 'package:easycook/state%20management/provider/upload_profile.dart';
import 'package:easycook/utils/login_data_manager.dart';
import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:easycook/models/resep_model.dart';
import 'package:easycook/screens/resep_screen.dart';
import 'package:easycook/services/firebase_service.dart';
import 'package:easycook/services/user_auth.dart';
import 'package:image_picker/image_picker.dart';
import 'package:provider/provider.dart';

class ProfileScreen extends StatefulWidget {
  const ProfileScreen({Key? key}) : super(key: key);

  @override
  _ProfileScreenState createState() => _ProfileScreenState();
}

class _ProfileScreenState extends State<ProfileScreen>
    with SingleTickerProviderStateMixin {
  User? _user;
  final UserRepository _userRepository =
      UserRepository(FirebaseFirestore.instance);

  late Future<List<Recipe>> _resepFuture;
  File? _image;

  @override
  void initState() {
    super.initState();

    FirebaseAuth.instance.authStateChanges().listen((User? user) {
      setState(() {
        _user = user;
        // Memperbarui daftar resep setiap kali pengguna masuk
        if (_user != null) {
          _resepFuture = FirebaseService().ambilResepUser();
          // Panggil _fetchProfilePictureUrl saat pengguna masuk
          Provider.of<ProfilePictureUrlProvider>(context, listen: false)
              .fetchProfilePictureUrl(_user!.uid);
        }
      });
    });
  }

  void _pilihProfile() async {
    final picker = ImagePicker();
    try {
      final pickedFile = await picker.pickImage(source: ImageSource.gallery);
      if (pickedFile != null) {
        setState(() {
          _image = File(pickedFile.path);
        });

        await Provider.of<ProfileProvider>(context, listen: false)
            .uploadProfilePicture(_image!, _user!.uid);
        ;
      }
    } catch (e) {
      print("Error picking image: $e");
    }
  }

  void _logout(BuildContext context) async {
    showDialog(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          title: Text('Konfirmasi Logout'),
          content: Text('Apakah Anda yakin ingin keluar?'),
          actions: <Widget>[
            TextButton(
              onPressed: () {
                Navigator.of(context).pop();
              },
              child: Text(
                'Batal',
                style: TextStyle(
                  color: Color(0xFF58A975),
                ),
              ),
            ),
            TextButton(
              onPressed: () async {
                Navigator.of(context).pop(); // Tutup dialog
                await LoginDataManager.clearLoginData(); // Lakukan logout
                Navigator.pushNamedAndRemoveUntil(
                    context,
                    '/login',
                    (route) =>
                        false); // Navigasi ke halaman login dan hapus history navigasi
              },
              child: Text(
                'Keluar',
                style: TextStyle(
                  color: Color(0xFF58A975),
                ),
              ),
            ),
          ],
        );
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        backgroundColor: const Color(0xFFFFFF99),
        centerTitle: true,
        title: const Text(
          "Profile",
          style: TextStyle(
              fontSize: 20,
              fontWeight: FontWeight.w800,
              color: Color(0xff000000)),
        ),
        actions: [
          IconButton(
            onPressed: () {
              _logout(context);
            },
            icon: const Icon(
              Icons.logout,
              size: 26.0,
            ),
          ),
        ],
        toolbarHeight: 70,
      ),
      body: Container(
        padding: const EdgeInsets.only(top: 20.0, left: 20.0, right: 20.0),
        child: Column(
          children: [
            const SizedBox(height: 20),
            Stack(
              children: [
                GestureDetector(
                  onTap: () {
                    _pilihProfile();
                  },
                  child: CircleAvatar(
                    backgroundImage: Provider.of<ProfilePictureUrlProvider>(
                                    context)
                                .profilePictureUrl !=
                            null
                        ? NetworkImage(
                            Provider.of<ProfilePictureUrlProvider>(context)
                                .profilePictureUrl!) as ImageProvider<Object>
                        : const AssetImage('assets/exProf.jpg'),
                    radius: 100,
                  ),
                ),
                Positioned(
                  bottom: 0,
                  right: 4,
                  child: CircleAvatar(
                    backgroundColor: Colors.white,
                    radius: 25,
                    child: IconButton(
                      icon: const Icon(
                        Icons.edit,
                        size: 20,
                        color: Colors.black,
                      ),
                      onPressed: () {
                        _pilihProfile();
                      },
                    ),
                  ),
                ),
              ],
            ),
            const SizedBox(height: 20),
            _user != null
                ? FutureBuilder<Map<String, dynamic>?>(
                    future: _userRepository.getUserData(_user!.uid),
                    builder: (context, snapshot) {
                      if (snapshot.connectionState == ConnectionState.waiting) {
                        return const CircularProgressIndicator();
                      } else if (snapshot.hasError) {
                        return Text('Error: ${snapshot.error}');
                      } else if (snapshot.hasData && snapshot.data != null) {
                        return Column(
                          children: [
                            Text(
                              snapshot.data!['username'] ??
                                  "Nama Pengguna tidak ditemukan",
                              style: const TextStyle(
                                  fontSize: 22, fontWeight: FontWeight.w600),
                            ),
                            const SizedBox(height: 10),
                            Text(
                              snapshot.data!['email'] ??
                                  "Email Tidak Ditemukan",
                              style: const TextStyle(fontSize: 16),
                            ),
                          ],
                        );
                      } else {
                        return const Text('Data tidak tersedia');
                      }
                    },
                  )
                : const SizedBox(),
            const SizedBox(height: 20),
            const Text(
              "Resep Masakan Saya",
              style: TextStyle(fontSize: 24, fontWeight: FontWeight.w600),
            ),
            Container(
              height: 322,
              child: Center(
                child: Container(
                  height: double.infinity,
                  width: double.infinity,
                  padding: const EdgeInsets.symmetric(vertical: 4),
                  child: FutureBuilder<List<Recipe>>(
                    future: _resepFuture,
                    builder: (context, snapshot) {
                      if (snapshot.connectionState == ConnectionState.waiting) {
                        return const CircularProgressIndicator();
                      } else if (snapshot.hasError) {
                        return Text('Error: ${snapshot.error}');
                      } else if (!snapshot.hasData || snapshot.data!.isEmpty) {
                        // Display a placeholder when the list is empty
                        return Column(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: [
                            Image.asset(
                              'assets/kosong.png',
                              width: 250,
                              height: 250,
                            ),
                            const Text(
                              'Kamu belum mempunyai resep',
                              style:
                                  TextStyle(fontSize: 18, color: Colors.black),
                            ),
                          ],
                        );
                      } else {
                        return ListView.builder(
                          shrinkWrap: true,
                          itemCount: snapshot.data!.length,
                          itemBuilder: (context, index) {
                            Recipe resep = snapshot.data![index];
                            return Container(
                              decoration: BoxDecoration(
                                borderRadius: const BorderRadius.all(
                                  Radius.circular(12.0),
                                ),
                                color: Colors.white,
                                boxShadow: [
                                  BoxShadow(
                                    color: Colors.grey.withOpacity(0.5),
                                    spreadRadius: 1,
                                    blurRadius: 5,
                                    offset: const Offset(3, 3),
                                  ),
                                ],
                              ),
                              margin: const EdgeInsets.symmetric(vertical: 8),
                              child: FutureBuilder<Map<String, dynamic>?>(
                                future:
                                    _userRepository.getUserData(resep.userId),
                                builder: (context, userSnapshot) {
                                  if (userSnapshot.connectionState ==
                                      ConnectionState.waiting) {
                                    return const CircularProgressIndicator();
                                  } else if (userSnapshot.hasError) {
                                    return Text('Error: ${userSnapshot.error}');
                                  } else {
                                    return GestureDetector(
                                      onTap: () {
                                        Navigator.push(
                                          context,
                                          MaterialPageRoute(
                                            builder: (context) => Resep(
                                              resepId: resep.id,
                                            ),
                                          ),
                                        );
                                      },
                                      child: Container(
                                        padding: const EdgeInsets.all(8),
                                        child: Row(
                                          crossAxisAlignment:
                                              CrossAxisAlignment.start,
                                          children: [
                                            Container(
                                              width: 80,
                                              height: 80,
                                              decoration: BoxDecoration(
                                                borderRadius:
                                                    const BorderRadius.all(
                                                  Radius.circular(12.0),
                                                ),
                                                image: DecorationImage(
                                                  fit: BoxFit.cover,
                                                  image: NetworkImage(
                                                    resep.imageURL,
                                                  ),
                                                ),
                                              ),
                                            ),
                                            const SizedBox(width: 16),
                                            Expanded(
                                              child: Column(
                                                crossAxisAlignment:
                                                    CrossAxisAlignment.start,
                                                children: [
                                                  Text(
                                                    resep.name,
                                                    style: const TextStyle(
                                                      fontWeight:
                                                          FontWeight.bold,
                                                      fontSize: 16,
                                                    ),
                                                  ),
                                                  const SizedBox(height: 4),
                                                  Text(
                                                    resep.description,
                                                    maxLines: 2,
                                                  ),
                                                ],
                                              ),
                                            ),
                                            const SizedBox(width: 16),
                                            Column(
                                              crossAxisAlignment:
                                                  CrossAxisAlignment.end,
                                              children: [
                                                IconButton(
                                                  onPressed: () {
                                                    Navigator.push(
                                                      context,
                                                      MaterialPageRoute(
                                                        builder: (context) =>
                                                            TambahScreen(
                                                          recipeId: resep.id,
                                                        ),
                                                      ),
                                                    );
                                                  },
                                                  icon: const Icon(
                                                    Icons.edit,
                                                  ),
                                                  color:
                                                      const Color(0xFF58A975),
                                                ),
                                                IconButton(
                                                  onPressed: () async {
                                                    _hapusResep(
                                                        context, resep.id);
                                                  },
                                                  icon:
                                                      const Icon(Icons.delete),
                                                  color: const Color.fromARGB(
                                                      255, 250, 116, 106),
                                                ),
                                              ],
                                            ),
                                          ],
                                        ),
                                      ),
                                    );
                                  }
                                },
                              ),
                            );
                          },
                        );
                      }
                    },
                  ),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  _hapusResep(BuildContext context, String resepId) async {
    showDialog(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          title: const Text('Hapus Resep'),
          content: const Text('Apakah Anda yakin ingin menghapus resep ini?'),
          actions: <Widget>[
            TextButton(
              onPressed: () {
                Navigator.of(context).pop();
              },
              child: const Text('Batal'),
            ),
            TextButton(
              onPressed: () async {
                try {
                  await FirebaseService().hapusResep(resepId);
                  ScaffoldMessenger.of(context).showSnackBar(
                    const SnackBar(
                      content: Text('Resep berhasil dihapus'),
                      backgroundColor: Color(0xFF58A975),
                    ),
                  );
                  Navigator.pop(context);

                  setState(() {
                    _resepFuture = FirebaseService().ambilResepUser();
                  });
                } catch (e) {
                  print('Error deleting recipe: $e');
                  ScaffoldMessenger.of(context).showSnackBar(
                    SnackBar(
                      content: Text('Gagal menghapus resep: $e'),
                      backgroundColor: const Color.fromARGB(255, 250, 116, 106),
                    ),
                  );
                }
              },
              child: const Text('Hapus'),
            ),
          ],
        );
      },
    );
  }
}
