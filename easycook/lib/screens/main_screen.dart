import 'package:easycook/screens/home_screen.dart';
import 'package:easycook/screens/tambah_screen.dart';
import 'package:easycook/screens/profile_screen.dart';
import 'package:easycook/screens/tampil_screen.dart';
import 'package:flutter/material.dart';

import 'package:flutter_bloc/flutter_bloc.dart';

import '../state management/bloc/bottom_nav/bottom_nav_bloc.dart';

List<Widget> _bodyItems = [
  const HomePage(),
  const TampilScreen(),
  const TambahScreen(),
  const ProfileScreen(),
];

List<BottomNavigationBarItem> _bottomNavigationBar = const [
  BottomNavigationBarItem(icon: Icon(Icons.home), label: "Home"),
  BottomNavigationBarItem(
      icon: Icon(Icons.receipt_long_outlined), label: "Resep"),
  BottomNavigationBarItem(icon: Icon(Icons.add), label: "Tambah"),
  BottomNavigationBarItem(icon: Icon(Icons.person), label: "Profile"),
];

class MainScreen extends StatelessWidget {
  const MainScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return BlocBuilder<BottomNavBloc, BottomNavState>(
      builder: (context, state) {
        return Scaffold(
          body: _bodyItems[state.tabIndex],
          bottomNavigationBar: BottomNavigationBar(
            type: BottomNavigationBarType.fixed,
            items: _bottomNavigationBar,
            currentIndex: state.tabIndex,
            selectedItemColor: const Color(0xFF58A975),
            unselectedItemColor: Colors.grey,
            onTap: (index) {
              BlocProvider.of<BottomNavBloc>(context)
                  .add(ChangeTabEvent(index));
            },
          ),
        );
      },
    );
  }
}
