import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'package:shared_preferences/shared_preferences.dart'; // 👈 เพิ่ม

class LoginPage extends StatefulWidget {
  const LoginPage({super.key});
  @override
  State<LoginPage> createState() => _LoginPageState();
}

class _LoginPageState extends State<LoginPage> {
  final TextEditingController _emailController = TextEditingController();
  final TextEditingController _passwordController = TextEditingController();

  Future<void> _loginUser() async {
  final url = Uri.parse('http://10.0.2.2:4000/api/login');

  final response = await http.post(
    url,
    headers: {'Content-Type': 'application/json'},
    body: jsonEncode({
      'email': _emailController.text,
      'password': _passwordController.text,
    }),
  );

  print('STATUS: ${response.statusCode}');
  print('BODY: ${response.body}');

  final resBody = jsonDecode(response.body);

  if (response.statusCode == 200) {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setString('token', resBody['token']);
    await prefs.setString('user', jsonEncode(resBody['user']));

    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(content: Text('ยินดีต้อนรับ ${resBody['user']['display_name']}')),
    );

    Navigator.pushReplacementNamed(context, '/main');
  } else {
    // ✅ ล้าง token ที่อาจจะค้างจากรอบก่อน
    final prefs = await SharedPreferences.getInstance();
    await prefs.remove('token');
    await prefs.remove('user');

    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(content: Text('เข้าสู่ระบบไม่สำเร็จ: ${resBody['message']}')),
    );
  }
}


  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('เข้าสู่ระบบ')),
      body: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          children: [
            TextField(
              controller: _emailController,
              decoration: const InputDecoration(labelText: 'อีเมล'),
            ),
            TextField(
              controller: _passwordController,
              obscureText: true,
              decoration: const InputDecoration(labelText: 'รหัสผ่าน'),
            ),
            const SizedBox(height: 24),
            ElevatedButton(
              onPressed: _loginUser,
              child: const Text('เข้าสู่ระบบ'),
            ),
          ],
        ),
      ),
    );
  }
}
