import 'package:easycook/state%20management/bloc/login/login_cubit.dart';
import 'package:easycook/screens/main_screen.dart';
import 'package:easycook/utils/login_data_manager.dart';
import 'package:email_validator/email_validator.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
// import '../services/user_auth.dart';

class LoginPage extends StatefulWidget {
  const LoginPage({super.key});

  @override
  State<LoginPage> createState() => _LoginPageState();
}

class _LoginPageState extends State<LoginPage> {
  // TextEditingController _nameController = TextEditingController();
  final TextEditingController _emailController = TextEditingController();
  final TextEditingController _passwordController = TextEditingController();
  bool passInvisible = false;

  @override
  void initState() {
    super.initState();
    _loadLoginData(); // Panggil fungsi untuk membaca data login saat halaman dimuat
  }

  // Fungsi untuk membaca data login dan mengatur nilai controller
  void _loadLoginData() async {
    Map<String, String> loginData = await LoginDataManager.readLoginData();
    if (loginData['email'] != null &&
        loginData['password'] != null &&
        loginData['email']!.isNotEmpty &&
        loginData['password']!.isNotEmpty) {
      // Jika ada data login yang tersimpan, arahkan pengguna ke halaman beranda
      Navigator.pushReplacement(
        context,
        MaterialPageRoute(builder: (context) => const MainScreen()),
      );
    } else {
      // Jika tidak ada data login yang tersimpan, tampilkan halaman login
      setState(() {
        _emailController.text = loginData['email'] ?? '';
        _passwordController.text = loginData['password'] ?? '';
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: BlocListener<LoginCubit, LoginState>(
        listener: (context, state) {
          if (state is LoginLoading) {
            ScaffoldMessenger.of(context)
              ..hideCurrentSnackBar()
              ..showSnackBar(const SnackBar(content: Text('Loading..')));
          }
          if (state is LoginFailure) {
            ScaffoldMessenger.of(context)
              ..hideCurrentSnackBar()
              ..showSnackBar(SnackBar(
                content: Text(state.msg),
                backgroundColor: Colors.red,
              ));
          }
          if (state is LoginSuccess) {
            ScaffoldMessenger.of(context)
              ..hideCurrentSnackBar()
              ..showSnackBar(SnackBar(
                content: Text(state.msg),
                backgroundColor: Colors.green,
              ));
            LoginDataManager.saveLoginData(
                _emailController.text, _passwordController.text);
            Navigator.pushAndRemoveUntil(
              context,
              MaterialPageRoute(builder: (context) => const MainScreen()),
              (route) => false,
            );
          }
        },
        child: Center(
          child: SingleChildScrollView(
            padding: const EdgeInsets.all(20.0),
            child: Column(
              children: [
                Image.asset(
                  "assets/loreg.png",
                  width: 170.0,
                  height: 170.0,
                  fit: BoxFit.fill,
                ),
                const SizedBox(
                  height: 24,
                ),
                const Text(
                  "Silahkan masuk",
                  style: TextStyle(fontSize: 18),
                ),
                const SizedBox(
                  height: 24,
                ),
                TextFormField(
                  key: Key("emailTextField"),
                  controller: _emailController,
                  decoration: const InputDecoration(
                    labelText: 'Masukan email',
                    border: OutlineInputBorder(
                        borderSide: BorderSide(color: Colors.black)),
                  ),
                  validator: (value) {
                    if (value == null || value.isEmpty) {
                      return 'Email tidak boleh kosong';
                    }
                    if (!EmailValidator.validate(value)) {
                      return 'Email Tidak Valid';
                    }
                    return null;
                  },
                ),
                const SizedBox(
                  height: 24,
                ),
                TextFormField(
                  key: Key("passwordTextField"),
                  controller: _passwordController,
                  decoration: InputDecoration(
                      suffixIcon: IconButton(
                        icon: Icon(passInvisible
                            ? Icons.visibility
                            : Icons.visibility_off),
                        onPressed: () {
                          setState(() {
                            passInvisible = !passInvisible;
                          });
                        },
                      ),
                      border: const OutlineInputBorder(
                          borderSide: BorderSide(color: Colors.black)),
                      labelText: 'Masukan Password'),
                  obscureText: !passInvisible,
                ),
                const SizedBox(
                  height: 24,
                ),
                ElevatedButton(
                  key: Key("masukButton"),
                  onPressed: () {
                    context.read<LoginCubit>().login(
                          email: _emailController.text,
                          password: _passwordController.text,
                        );
                  },
                  style: ButtonStyle(
                    backgroundColor: MaterialStateProperty.all<Color>(
                      const Color(
                          0xFFFFFF99), // Ganti dengan warna yang Anda inginkan
                    ),
                  ),
                  child: const Text(
                    "Masuk",
                    style: TextStyle(color: Colors.black),
                  ),
                ),
                const SizedBox(
                  height: 24,
                ),
                Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    const Text("Belum punya akun ?"),
                    TextButton(
                        onPressed: () {
                          Navigator.pushNamed(context, '/register');
                        },
                        child: const Text(
                          "Daftar",
                          style: TextStyle(
                              fontWeight: FontWeight.bold,
                              color: Color(0xff3D4DE0)),
                        ))
                  ],
                )
              ],
            ),
          ),
        ),
      ),
    );
  }
}
