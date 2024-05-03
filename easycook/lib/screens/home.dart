import 'package:easycook/utils/login_data_manager.dart';
import 'package:flutter/material.dart';

class HomePage extends StatelessWidget {
  const HomePage({super.key});

  // Fungsi untuk logout pengguna
  void _logout(BuildContext context) async {
    // Hapus data login dari SharedPreferences
    await LoginDataManager.clearLoginData();
    // Navigasi kembali ke halaman login dan hapus semua rute sebelumnya
    Navigator.pushNamedAndRemoveUntil(context, '/login', (route) => false);
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text("Dashboard"),
        actions: [
          IconButton(
            onPressed: () {
              _logout(context);
            },
            icon: const Icon(
              Icons.logout,
              size: 24.0,
            ),
          ),
        ],
      ),
      body: SingleChildScrollView(
        child: Container(
          padding: const EdgeInsets.all(20.0),
          child: const Column(
            children: [
              Text("text"),
            ],
          ),
        ),
      ),
    );
  }
}
