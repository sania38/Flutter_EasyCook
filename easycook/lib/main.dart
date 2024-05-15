import 'package:easycook/screens/splash.dart';
import 'package:easycook/state%20management/bloc/login/login_cubit.dart';
import 'package:easycook/state%20management/provider/profile_pict.dart';
import 'package:easycook/state%20management/bloc/register/register_cubit.dart';
import 'package:easycook/state%20management/provider/simpan_resep.dart';
import 'package:easycook/state%20management/provider/update_recipe.dart';
import 'package:easycook/state%20management/provider/upload_profile.dart';
import 'package:easycook/firebase_options.dart';
import 'package:easycook/screens/login_screen.dart';
import 'package:easycook/screens/main_screen.dart';
import 'package:easycook/screens/profile_screen.dart';
import 'package:easycook/screens/register_screen.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:provider/provider.dart';

import 'state management/bloc/bottom_nav/bottom_nav_bloc.dart';

Future<void> main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await Firebase.initializeApp(
    options: DefaultFirebaseOptions.currentPlatform,
  );

  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  // This widget is the root of your application.
  @override
  Widget build(BuildContext context) {
    return MultiBlocProvider(
      providers: [
        ChangeNotifierProvider(create: (_) => ProfilePictureUrlProvider()),
        ChangeNotifierProvider(create: (_) => ProfileProvider()),
        ChangeNotifierProvider(create: (_) => SaveRecipeProvider()),
        ChangeNotifierProvider(create: (_) => UpdateRecipeProvider()),
        BlocProvider(
          create: (context) => LoginCubit(),
        ),
        BlocProvider(
          create: (context) => RegisterCubit(),
        ),
        BlocProvider(
          create: (context) => BottomNavBloc(),
        ),
      ],
      child: MaterialApp(
        title: 'Flutter Demo',
        debugShowCheckedModeBanner: false,
        theme: ThemeData(
          tabBarTheme: const TabBarTheme(
            labelColor: Colors.black,
            unselectedLabelColor: Colors.grey,
            indicatorColor: Color(0xFF58A975),
          ),
          bottomNavigationBarTheme: const BottomNavigationBarThemeData(
            backgroundColor: Color(0xFFFFFF99),
          ),
        ),
        home: SplashScreen(),
        routes: {
          '/login': (context) => const LoginPage(),
          '/register': (context) => const RegisterPage(),
          '/main': (context) => const MainScreen(),
          '/profile': (context) => const ProfileScreen(),
        },
      ),
    );
  }
}
