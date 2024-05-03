import 'package:easycook/bloc/login/login_cubit.dart';
import 'package:easycook/screens/home.dart';
import 'package:easycook/utils/login_data_manager.dart';
import 'package:email_validator/email_validator.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

class LoginPage extends StatefulWidget {
  const LoginPage({super.key});

  @override
  State<LoginPage> createState() => _LoginPageState();
}

class _LoginPageState extends State<LoginPage> {
  // TextEditingController _nameController = TextEditingController();
  TextEditingController _emailController = TextEditingController();
  TextEditingController _passwordController = TextEditingController();
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
        MaterialPageRoute(builder: (context) => HomePage()),
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
              MaterialPageRoute(builder: (context) => HomePage()),
              (route) => false,
            );
          }
        },
        child: Center(
          child: SingleChildScrollView(
            padding: const EdgeInsets.all(20.0),
            child: Column(
              children: [
                // TextFormField(
                //   controller: _nameController,
                //   decoration: const InputDecoration(
                //       labelText: 'Masukan nama', border: OutlineInputBorder()),
                // ),
                // const SizedBox(
                //   height: 24,
                // ),
                Image.asset(
                  "assets/splash.png",
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
                  controller: _emailController,
                  decoration: const InputDecoration(
                    labelText: 'Masukan email',
                    border: OutlineInputBorder(),
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
                      border: const OutlineInputBorder(),
                      labelText: 'Masukan Password'),
                  obscureText: !passInvisible,
                ),
                const SizedBox(
                  height: 24,
                ),
                ElevatedButton(
                  onPressed: () {
                    context.read<LoginCubit>().login(
                          email: _emailController.text,
                          password: _passwordController.text,
                        );
                  },
                  style: ButtonStyle(
                    backgroundColor: MaterialStateProperty.all<Color>(
                      Colors.yellow, // Ganti dengan warna yang Anda inginkan
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
                    GestureDetector(
                      onTap: () {
                        // signInWithGoogle();
                      },
                      child: const CircleAvatar(
                        radius: 20,
                        backgroundColor: Color.fromARGB(255, 236, 236, 236),
                        backgroundImage: NetworkImage(
                            'https://cdn1.iconfinder.com/data/icons/google-s-logo/150/Google_Icons-09-512.png'),
                      ),
                    ),
                    const SizedBox(
                      width: 20,
                    ),
                    GestureDetector(
                      onTap: () {
                        // Navigator.push(
                        //     context,
                        //     MaterialPageRoute(
                        //         builder: (context) => PhoneAuthScreen()));
                      },
                      child: const CircleAvatar(
                        radius: 20,
                        backgroundImage: NetworkImage(
                            'https://i.pinimg.com/564x/87/b1/2a/87b12a1e8a11f6c1264a237c5f08c195.jpg'),
                      ),
                    ),
                  ],
                ),

                Row(
                  mainAxisAlignment:
                      MainAxisAlignment.center, //Menengahkan elemen horizontal
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
