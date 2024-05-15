import 'package:easycook/state%20management/bloc/register/register_cubit.dart';
import 'package:easycook/screens/login_screen.dart';
import 'package:email_validator/email_validator.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

class RegisterPage extends StatefulWidget {
  const RegisterPage({super.key});

  @override
  State<RegisterPage> createState() => _RegisterPageState();
}

class _RegisterPageState extends State<RegisterPage> {
  // TextEditingController _nameController = TextEditingController();
  final TextEditingController _emailController = TextEditingController();
  final TextEditingController _passwordController = TextEditingController();
  bool passInvisible = false;
  String? _emailError;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: BlocListener<RegisterCubit, RegisterState>(
        listener: (context, state) {
          if (state is RegisterLoading) {
            ScaffoldMessenger.of(context)
              ..hideCurrentSnackBar()
              ..showSnackBar(const SnackBar(content: Text('Loading..')));
          }
          if (state is RegisterFailure) {
            ScaffoldMessenger.of(context)
              ..hideCurrentSnackBar()
              ..showSnackBar(SnackBar(
                content: Text(state.msg),
                backgroundColor: Colors.red,
              ));
          }
          if (state is RegisterSuccess) {
            ScaffoldMessenger.of(context)
              ..hideCurrentSnackBar()
              ..showSnackBar(SnackBar(
                content: Text(state.msg),
                backgroundColor: Colors.green,
              ));
            Navigator.pushAndRemoveUntil(
              context,
              MaterialPageRoute(builder: (context) => const LoginPage()),
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
                  "Buat Akun",
                  style: TextStyle(fontSize: 18),
                ),
                const SizedBox(
                  height: 24,
                ),
                TextFormField(
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
                  onChanged: (_) {
                    setState(() {
                      _emailError = null;
                    });
                  },
                ),
                if (_emailError != null)
                  Text(
                    _emailError!,
                    style: const TextStyle(color: Colors.red),
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
                      border: const OutlineInputBorder(
                          borderSide: BorderSide(color: Colors.black)),
                      labelText: 'Masukan Password'),
                  obscureText: !passInvisible,
                ),
                const SizedBox(
                  height: 24,
                ),
                ElevatedButton(
                  onPressed: () {
                    context.read<RegisterCubit>().register(
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
                    "Daftar",
                    style: TextStyle(color: Colors.black),
                  ),
                ),
                Row(
                  mainAxisAlignment:
                      MainAxisAlignment.center, //Menengahkan elemen horizontal
                  children: [
                    const Text("Sudah punya akun ?"),
                    TextButton(
                        onPressed: () {
                          Navigator.pushNamed(context, '/login');
                        },
                        child: const Text(
                          "Masuk",
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
