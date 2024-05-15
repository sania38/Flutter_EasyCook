// ignore_for_file: unused_field

import 'dart:io';
import 'package:easycook/state%20management/provider/simpan_resep.dart';
import 'package:easycook/state%20management/provider/update_recipe.dart';
import 'package:easycook/models/resep_model.dart';
import 'package:easycook/services/firebase_service.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';
import 'package:provider/provider.dart';

class TambahScreen extends StatefulWidget {
  final String? recipeId;
  const TambahScreen({Key? key, this.recipeId}) : super(key: key);

  @override
  State<TambahScreen> createState() => _TambahScreenState();
}

class _TambahScreenState extends State<TambahScreen> {
  TextEditingController foodcController = TextEditingController();
  TextEditingController descController = TextEditingController();
  TextEditingController ingredientController = TextEditingController();
  List<String> ingredients = [];
  TextEditingController howToController = TextEditingController();
  List<String> howTo = [];
  File? _image;

  final FirebaseService _firebaseService = FirebaseService();

  bool _isLoading = false;
  bool _isFailure = false;
  bool _isSuccess = false;

  @override
  void initState() {
    super.initState();
    if (widget.recipeId != null) {
      // Jika recipeId tidak null, artinya sedang mengedit resep yang sudah ada
      _ambilResepDariFirebase();
    }
  }

  Future<void> _ambilResepDariFirebase() async {
    try {
      Recipe? recipe = await _firebaseService.ambilResepId(widget.recipeId!);
      if (recipe != null) {
        // Jika resep ditemukan, isi nilai kontroler formulir dengan data resep yang ada
        setState(() {
          foodcController.text = recipe.name;
          descController.text = recipe.description;
          ingredients = List.from(recipe.ingredients);
          howTo = List.from(recipe.cookingSteps);
          _image = File(recipe.imageURL);
        });
      }
    } catch (e) {
      print('Error fetching recipe: $e');
    }
  }

  Future<void> _pilihGambar() async {
    final picker = ImagePicker();
    try {
      final pickedFile = await picker.pickImage(source: ImageSource.gallery);
      if (pickedFile != null) {
        setState(() {
          _image = File(pickedFile.path);
        });
      }
    } catch (e) {
      print("Error picking image: $e");
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        backgroundColor: const Color(0xFFFFFF99),
        centerTitle: true,
        title: const Text(
          "Tambah Resep",
          style: TextStyle(
              fontSize: 20,
              fontWeight: FontWeight.w800,
              color: Color(0xff000000)),
        ),
        actions: const [],
        toolbarHeight: 70,
      ),
      body: SingleChildScrollView(
        child: Column(
          children: [
            if (_isLoading)
              const Center(
                child: CircularProgressIndicator(),
              ),
            Center(
              child: Padding(
                padding: const EdgeInsets.all(24.0),
                child: InkWell(
                  onTap: _pilihGambar,
                  child: Container(
                    decoration: BoxDecoration(
                      border:
                          Border.all(color: const Color(0xFF58A975), width: 5),
                      borderRadius: const BorderRadius.all(
                        Radius.circular(12.0),
                      ),
                    ),
                    width: 400,
                    height: 180,
                    child: _image == null
                        ? Column(
                            children: [
                              const SizedBox(
                                height: 18,
                              ),
                              Image.asset(
                                'assets/add_image.png',
                                width: 70,
                                height: 70,
                              ),
                              const SizedBox(
                                height: 14,
                              ),
                              const Text(
                                "Tambah Cover Foto",
                                style: TextStyle(
                                    fontSize: 18,
                                    fontWeight: FontWeight.w800,
                                    color: Color(0xFF58A975)),
                              ),
                              const SizedBox(
                                height: 8,
                              ),
                              const Text(
                                "(up to 12 Mb)",
                                style: TextStyle(
                                    fontSize: 14, color: Color(0xFF58A975)),
                              )
                            ],
                          )
                        : _image!.path.contains(
                                'https://firebasestorage.googleapis.com')
                            ? Image.network(
                                _image!.path,
                                fit: BoxFit.cover,
                                loadingBuilder: (BuildContext context,
                                    Widget child,
                                    ImageChunkEvent? loadingProgress) {
                                  if (loadingProgress == null) {
                                    return child;
                                  } else {
                                    return Center(
                                      child: CircularProgressIndicator(
                                        value: loadingProgress
                                                    .expectedTotalBytes !=
                                                null
                                            ? loadingProgress
                                                    .cumulativeBytesLoaded /
                                                loadingProgress
                                                    .expectedTotalBytes!
                                            : null,
                                      ),
                                    );
                                  }
                                },
                                errorBuilder: (BuildContext context,
                                    Object error, StackTrace? stackTrace) {
                                  return Text('Error loading image: $error');
                                },
                              )
                            : Image.file(_image!,
                                fit: BoxFit
                                    .cover), // Menampilkan gambar yang dipilih
                  ),
                ),
              ),
            ),
            const SizedBox(
              height: 6,
            ),
            Padding(
              padding: const EdgeInsets.all(24.0),
              child: Column(
                children: [
                  const Row(
                    mainAxisAlignment: MainAxisAlignment.start,
                    children: [
                      Text(
                        "Nama Masakan",
                        style: TextStyle(
                            fontSize: 18,
                            fontWeight: FontWeight.w800,
                            color: Color(0xFF58A975)),
                      ),
                    ],
                  ),
                  const SizedBox(
                    height: 12,
                  ),
                  TextFormField(
                    controller: foodcController,
                    decoration: const InputDecoration(
                      border: OutlineInputBorder(
                        borderRadius: BorderRadius.all(
                          Radius.circular(12.0),
                        ),
                      ),
                      labelText: "Masukan nama masakan",
                      labelStyle: TextStyle(color: Color(0xFF000000)),
                    ),
                    validator: (value) {
                      if (value == null || value.isEmpty) {
                        return 'This field cannot be empty';
                      }
                      return null;
                    },
                  ),
                  const SizedBox(
                    height: 30,
                  ),
                  const Row(
                    mainAxisAlignment: MainAxisAlignment.start,
                    children: [
                      Text(
                        "Deskripsi Masakan",
                        style: TextStyle(
                            fontSize: 18,
                            fontWeight: FontWeight.w800,
                            color: Color(0xFF58A975)),
                      ),
                    ],
                  ),
                  const SizedBox(
                    height: 12,
                  ),
                  TextFormField(
                    key: const Key('desc'),
                    controller: descController,
                    decoration: const InputDecoration(
                        border: OutlineInputBorder(
                          borderRadius: BorderRadius.all(
                            Radius.circular(12.0),
                          ),
                        ),
                        alignLabelWithHint: true,
                        labelText: "Deskripsikan sedikit tentang maskanmu",
                        labelStyle: TextStyle(color: Color(0xFF000000))),
                    maxLines: 4,
                    validator: (value) {
                      if (value == null || value.isEmpty) {
                        return 'This field cannot be empty';
                      }
                      return null;
                    },
                  ),
                ],
              ),
            ),
            const SizedBox(
              height: 15,
            ),
            const Divider(
              color: Color(0xFFFFFF99),
              thickness: 20,
            ),
            Column(
              children: [
                Padding(
                  padding: const EdgeInsets.all(24.0),
                  child: Column(
                    children: [
                      const Align(
                        alignment: Alignment.centerLeft,
                        child: Text(
                          "Bahan-Bahan",
                          style: TextStyle(
                            fontSize: 18,
                            fontWeight: FontWeight.w800,
                            color: Color(0xFF58A975),
                          ),
                        ),
                      ),

                      const SizedBox(
                        height: 12,
                      ),
                      // Daftar bahan
                      ListView.builder(
                        shrinkWrap: true,
                        itemCount: ingredients.length,
                        itemBuilder: (context, index) {
                          return Row(
                            children: [
                              Expanded(
                                child: Container(
                                  margin:
                                      const EdgeInsets.symmetric(vertical: 4),
                                  padding: const EdgeInsets.all(8),
                                  decoration: BoxDecoration(
                                    border: Border.all(
                                      color: const Color(0xFF58A975),
                                      width: 1,
                                    ),
                                    borderRadius: BorderRadius.circular(8),
                                  ),
                                  child: Row(
                                    children: [
                                      Expanded(
                                        child: Text(
                                          ingredients[index],
                                          style: const TextStyle(fontSize: 16),
                                        ),
                                      ),
                                      IconButton(
                                        icon: const Icon(
                                          Icons.edit,
                                          color: Color(0xFF58A975),
                                        ),
                                        onPressed: () {
                                          setState(() {
                                            ingredientController.text =
                                                ingredients[index];
                                            ingredients.removeAt(index);
                                          });
                                        },
                                      ),
                                      IconButton(
                                        icon: const Icon(
                                          Icons.delete,
                                          color: Color.fromARGB(
                                              255, 250, 116, 106),
                                        ),
                                        onPressed: () {
                                          setState(() {
                                            ingredients.removeAt(index);
                                          });
                                        },
                                      ),
                                    ],
                                  ),
                                ),
                              ),
                              Column(
                                children: [
                                  IconButton(
                                    icon: const Icon(
                                      Icons.arrow_upward,
                                      color: Color(0xFF58A975),
                                    ),
                                    onPressed: () {
                                      setState(() {
                                        if (index != 0) {
                                          final ingredient = ingredients[index];
                                          ingredients.removeAt(index);
                                          ingredients.insert(
                                              index - 1, ingredient);
                                        }
                                      });
                                    },
                                  ),
                                  IconButton(
                                    icon: const Icon(
                                      Icons.arrow_downward,
                                      color: Color.fromARGB(255, 250, 116, 106),
                                    ),
                                    onPressed: () {
                                      setState(() {
                                        if (index != ingredients.length - 1) {
                                          final ingredient = ingredients[index];
                                          ingredients.removeAt(index);
                                          ingredients.insert(
                                              index + 1, ingredient);
                                        }
                                      });
                                    },
                                  ),
                                ],
                              )
                            ],
                          );
                        },
                      ),

                      const SizedBox(
                        height: 12,
                      ),
                      Column(
                        children: [
                          TextFormField(
                            controller: ingredientController,
                            decoration: const InputDecoration(
                              border: OutlineInputBorder(
                                borderRadius: BorderRadius.all(
                                  Radius.circular(12.0),
                                ),
                              ),
                              labelText: "Masukan bahan",
                              labelStyle: TextStyle(color: Color(0xFF000000)),
                            ),
                            validator: (value) {
                              if (value == null || value.isEmpty) {
                                return 'This field cannot be empty';
                              }
                              return null;
                            },
                          ),
                          const SizedBox(
                            height: 20,
                          ),
                          Row(
                            mainAxisAlignment: MainAxisAlignment.center,
                            children: [
                              ElevatedButton(
                                onPressed: () {
                                  setState(() {
                                    // Tambahkan bahan ke dalam daftar
                                    ingredients.add(ingredientController.text);
                                    // Bersihkan input field
                                    ingredientController.clear();
                                  });
                                },
                                style: ElevatedButton.styleFrom(
                                  backgroundColor: const Color(0xFF58A975),
                                  padding: const EdgeInsets.symmetric(
                                      horizontal: 30, vertical: 6),
                                  shape: RoundedRectangleBorder(
                                    borderRadius: BorderRadius.circular(20),
                                  ),
                                ),
                                child: const Row(
                                  children: [
                                    Icon(
                                      Icons.add,
                                      color: Colors.white,
                                    ),
                                    SizedBox(
                                      width: 20,
                                    ),
                                    Text(
                                      'Tambah',
                                      style: TextStyle(
                                          fontSize: 18, color: Colors.white),
                                    ),
                                  ],
                                ),
                              ),
                            ],
                          ),
                        ],
                      ),
                    ],
                  ),
                )
              ],
            ),
            const SizedBox(
              height: 20,
            ),
            const Divider(
              color: Color(0xFFFFFF99),
              thickness: 20,
            ),
            const SizedBox(
              height: 30,
            ),
            Column(
              children: [
                Padding(
                  padding: const EdgeInsets.all(24.0),
                  child: Column(
                    children: [
                      const Align(
                        alignment: Alignment.centerLeft,
                        child: Text(
                          "Cara Memasak",
                          style: TextStyle(
                            fontSize: 18,
                            fontWeight: FontWeight.w800,
                            color: Color(0xFF58A975),
                          ),
                        ),
                      ),
                      const SizedBox(
                        height: 12,
                      ),
                      // Daftar cara memasak
                      ListView.builder(
                        shrinkWrap: true,
                        itemCount: howTo.length,
                        itemBuilder: (context, index) {
                          return Row(
                            children: [
                              Expanded(
                                child: Container(
                                  margin:
                                      const EdgeInsets.symmetric(vertical: 4),
                                  padding: const EdgeInsets.all(8),
                                  decoration: BoxDecoration(
                                    border: Border.all(
                                      color: const Color(0xFF58A975),
                                      width: 1,
                                    ),
                                    borderRadius: BorderRadius.circular(8),
                                  ),
                                  child: Row(
                                    children: [
                                      Expanded(
                                        child: Text(
                                          howTo[index],
                                          style: const TextStyle(fontSize: 16),
                                        ),
                                      ),
                                      IconButton(
                                        icon: const Icon(
                                          Icons.edit,
                                          color: Color(0xFF58A975),
                                        ),
                                        onPressed: () {
                                          setState(() {
                                            howToController.text = howTo[index];
                                            howTo.removeAt(index);
                                          });
                                        },
                                      ),
                                      IconButton(
                                        icon: const Icon(
                                          Icons.delete,
                                          color: Color.fromARGB(
                                              255, 250, 116, 106),
                                        ),
                                        onPressed: () {
                                          setState(() {
                                            howTo.removeAt(index);
                                          });
                                        },
                                      ),
                                    ],
                                  ),
                                ),
                              ),
                              Column(
                                children: [
                                  IconButton(
                                    icon: const Icon(
                                      Icons.arrow_upward,
                                      color: Color(0xFF58A975),
                                    ),
                                    onPressed: () {
                                      setState(() {
                                        if (index != 0) {
                                          final howto = howTo[index];
                                          howTo.removeAt(index);
                                          howTo.insert(index - 1, howto);
                                        }
                                      });
                                    },
                                  ),
                                  IconButton(
                                    icon: const Icon(
                                      Icons.arrow_downward,
                                      color: Color.fromARGB(255, 250, 116, 106),
                                    ),
                                    onPressed: () {
                                      setState(() {
                                        if (index != howTo.length - 1) {
                                          final howto = howTo[index];
                                          howTo.removeAt(index);
                                          howTo.insert(index + 1, howto);
                                        }
                                      });
                                    },
                                  ),
                                ],
                              )
                            ],
                          );
                        },
                      ),

                      const SizedBox(
                        height: 12,
                      ),
                      Column(
                        children: [
                          TextFormField(
                            controller: howToController,
                            decoration: const InputDecoration(
                              border: OutlineInputBorder(
                                borderRadius: BorderRadius.all(
                                  Radius.circular(12.0),
                                ),
                              ),
                              labelText: "Masukan cara memasak",
                              labelStyle: TextStyle(color: Color(0xFF000000)),
                            ),
                            validator: (value) {
                              if (value == null || value.isEmpty) {
                                return 'This field cannot be empty';
                              }
                              return null;
                            },
                          ),
                          const SizedBox(
                            height: 20,
                          ),
                          Row(
                            mainAxisAlignment: MainAxisAlignment.center,
                            children: [
                              ElevatedButton(
                                onPressed: () {
                                  setState(() {
                                    // Tambahkan bahan ke dalam daftar
                                    howTo.add(howToController.text);
                                    // Bersihkan input field
                                    howToController.clear();
                                  });
                                },
                                style: ElevatedButton.styleFrom(
                                  backgroundColor: const Color(0xFF58A975),
                                  padding: const EdgeInsets.symmetric(
                                      horizontal: 30, vertical: 6),
                                  shape: RoundedRectangleBorder(
                                    borderRadius: BorderRadius.circular(20),
                                  ),
                                ),
                                child: const Row(
                                  children: [
                                    Icon(
                                      Icons.add,
                                      color: Colors.white,
                                    ),
                                    SizedBox(
                                      width: 20,
                                    ),
                                    Text(
                                      'Tambah',
                                      style: TextStyle(
                                          fontSize: 18, color: Colors.white),
                                    ),
                                  ],
                                ),
                              ),
                            ],
                          ),
                        ],
                      ),
                    ],
                  ),
                )
              ],
            ),
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceAround,
              children: [
                ElevatedButton(
                  onPressed: () {},
                  style: ElevatedButton.styleFrom(
                    backgroundColor: const Color(0xffC0C0C0),
                    padding:
                        const EdgeInsets.symmetric(horizontal: 60, vertical: 8),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(20),
                    ),
                  ),
                  child: const Text(
                    'Kembali',
                    style: TextStyle(fontSize: 18, color: Colors.white),
                  ),
                ),
                ElevatedButton(
                  onPressed: () {
                    // Periksa apakah nilai controller tidak kosong
                    if (foodcController.text.isNotEmpty &&
                        descController.text.isNotEmpty &&
                        ingredients.isNotEmpty &&
                        howTo.isNotEmpty &&
                        _image != null) {
                      if (widget.recipeId != null) {
                        User? user = FirebaseAuth.instance.currentUser;
                        if (user != null) {
                          // Jika user sedang login, perbarui resep dengan userId yang ditemukan
                          Provider.of<UpdateRecipeProvider>(context,
                                  listen: false)
                              .updateResep(
                            userId: user.uid,
                            recipeId: widget.recipeId!,
                            foodcController: foodcController,
                            descController: descController,
                            ingredients: ingredients,
                            howTo: howTo,
                            image: _image,
                            context: context,
                          );
                        } else {
                          print("User belum login.");
                        }
                      } else {
                        Provider.of<SaveRecipeProvider>(context, listen: false)
                            .simpanResep(
                          context: context,
                          foodcController: foodcController,
                          descController: descController,
                          ingredients: List<String>.from(
                              ingredients), // Mengirimkan salinan list
                          howTo: List<String>.from(
                              howTo), // Mengirimkan salinan list
                          image: _image,
                          ingredientController: ingredientController,
                          howToController: howToController,
                        );
                      }
                    } else {
                      // Tampilkan pesan kesalahan jika ada input yang kosong
                      ScaffoldMessenger.of(context).showSnackBar(
                        const SnackBar(
                          content: Text('Form tidak boleh kosong'),
                          backgroundColor: Colors.red,
                        ),
                      );
                    }
                  },
                  style: ElevatedButton.styleFrom(
                    backgroundColor: const Color(0xFF58A975),
                    padding:
                        const EdgeInsets.symmetric(horizontal: 60, vertical: 8),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(20),
                    ),
                  ),
                  child: const Text(
                    'Simpan',
                    style: TextStyle(fontSize: 18, color: Colors.white),
                  ),
                ),
              ],
            ),
            const SizedBox(
              height: 20,
            )
          ],
        ),
      ),
    );
  }
}
