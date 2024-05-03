import 'package:shared_preferences/shared_preferences.dart';

class LoginDataManager {
  static const String _emailKey = 'email';
  static const String _passwordKey = 'password';

  // Fungsi untuk menyimpan data login ke SharedPreferences
  static Future<void> saveLoginData(String email, String password) async {
    SharedPreferences prefs = await SharedPreferences.getInstance();
    await prefs.setString(_emailKey, email);
    await prefs.setString(_passwordKey, password);
  }

  // Fungsi untuk membaca data login dari SharedPreferences
  static Future<Map<String, String>> readLoginData() async {
    SharedPreferences prefs = await SharedPreferences.getInstance();
    String email = prefs.getString(_emailKey) ?? '';
    String password = prefs.getString(_passwordKey) ?? '';
    return {'email': email, 'password': password};
  }

  // Fungsi untuk menghapus data login dari SharedPreferences
  static Future<void> clearLoginData() async {
    SharedPreferences prefs = await SharedPreferences.getInstance();
    await prefs.remove(_emailKey);
    await prefs.remove(_passwordKey);
  }
}
