import 'dart:convert';
import 'dart:io';
import 'dart:ui'; 

import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'package:lab10_bookapp/page/add_product.dart'; 
import 'package:lab10_bookapp/page/show_products.dart'; 
import 'package:shared_preferences/shared_preferences.dart';

class LoginPage extends StatefulWidget {
  const LoginPage({super.key});

  @override
  State<LoginPage> createState() => _LoginPageState();
}

class _LoginPageState extends State<LoginPage> {
  final _formKey = GlobalKey<FormState>();
  final _usernameController = TextEditingController();
  final _passwordController = TextEditingController();

  bool _isObscure = true;
  bool _isLoading = false;

  // StoryWeave Theme Colors
  final Color swPrimary = const Color(0xFF4FC3F7); // ฟ้าสว่าง
  final Color swDeepBlue = const Color(0xFF0288D1); // ฟ้าเข้มแบบลุ่มลึก
  final Color swBg = const Color(0xFFF0F9FF);      // ฟ้าจางเกือบขาว

  @override
  void dispose() {
    _usernameController.dispose();
    _passwordController.dispose();
    super.dispose();
  }

  Future<void> login() async {
    if (!(_formKey.currentState?.validate() ?? false)) return;
    setState(() => _isLoading = true);

    try {
      var bodyData = jsonEncode({
        "username": _usernameController.text.trim(),
        "password": _passwordController.text.trim(),
      });

      var url = Uri.parse("http://10.0.2.2:3000/api/auth/login");

      var response = await http.post(
        url,
        body: bodyData,
        headers: {HttpHeaders.contentTypeHeader: "application/json"},
      ).timeout(const Duration(seconds: 10));

      if (response.statusCode == 200) {
        var responseData = jsonDecode(response.body);
        var userJson = responseData['payload'];
        var tokenJson = responseData['accessToken'] ?? responseData['token'] ?? responseData['accesstoken'];

        SharedPreferences prefs = await SharedPreferences.getInstance();
        await prefs.setStringList('user', [
          userJson['username']?.toString() ?? "User",
          userJson['tel']?.toString() ?? ""
        ]);
        await prefs.setStringList('token', [tokenJson.toString()]);

        if (!mounted) return;
        Navigator.pushReplacement(
          context,
          MaterialPageRoute(builder: (context) => const ShowProducts()),
        );
      } else {
        if (!mounted) return;
        _showErrorSnackBar("ข้อมูลการเข้าสู่ระบบไม่ถูกต้อง");
      }
    } catch (e) {
      if (!mounted) return;
      _showErrorSnackBar("เชื่อมต่อ StoryWeave Server ไม่ได้");
    } finally {
      if (mounted) setState(() => _isLoading = false);
    }
  }

  void _showErrorSnackBar(String message) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(content: Text(message), backgroundColor: Colors.redAccent, behavior: SnackBarBehavior.floating),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Stack(
        children: [
          // พื้นหลังสีฟ้าอ่อน
          Container(color: swBg),
          
          // ลวดลายไอคอนพื้นหลัง (Background Art)
          Positioned(
            top: -40,
            left: -40,
            child: Opacity(
              opacity: 0.08,
              child: Icon(Icons.auto_stories, size: 280, color: swDeepBlue), // ไอคอนหนังสือเปิดสื่อถึง Story
            ),
          ),
          Positioned(
            bottom: -20,
            right: -20,
            child: Opacity(
              opacity: 0.08,
              child: Icon(Icons.grain, size: 250, color: swDeepBlue), // ไอคอนถักทอสื่อถึง Weave
            ),
          ),

          Center(
            child: SingleChildScrollView(
              padding: const EdgeInsets.symmetric(horizontal: 30),
              child: Column(
                children: [
                  // โลโก้แบรนด์ StoryWeave
                  Container(
                    padding: const EdgeInsets.all(20),
                    decoration: BoxDecoration(
                      color: Colors.white,
                      borderRadius: BorderRadius.circular(35),
                      boxShadow: [
                        BoxShadow(
                          color: swPrimary.withOpacity(0.2),
                          blurRadius: 25,
                          offset: const Offset(0, 10),
                        )
                      ],
                    ),
                    child: Icon(Icons.auto_stories_rounded, size: 65, color: swDeepBlue),
                  ),
                  const SizedBox(height: 20),
                  Text(
                    "StoryWeave",
                    style: TextStyle(
                      fontSize: 36, 
                      fontWeight: FontWeight.w900, 
                      color: swDeepBlue,
                      letterSpacing: 1.5,
                      fontFamily: 'Serif', // ถ้ามีฟอนต์ Serif จะดูคลาสสิกมาก
                    ),
                  ),
                  Text(
                    "Weave your knowledge together",
                    style: TextStyle(color: swDeepBlue.withOpacity(0.5), fontSize: 14),
                  ),
                  const SizedBox(height: 50),

                  // ฟอร์มล็อคอิน
                  Container(
                    padding: const EdgeInsets.all(25),
                    decoration: BoxDecoration(
                      color: Colors.white,
                      borderRadius: BorderRadius.circular(30),
                      border: Border.all(color: Colors.white),
                      boxShadow: [
                        BoxShadow(color: Colors.black.withOpacity(0.05), blurRadius: 20)
                      ],
                    ),
                    child: Form(
                      key: _formKey,
                      child: Column(
                        children: [
                          _buildInput(
                            controller: _usernameController,
                            label: "Username",
                            icon: Icons.alternate_email_rounded,
                          ),
                          const SizedBox(height: 20),
                          _buildInput(
                            controller: _passwordController,
                            label: "Password",
                            icon: Icons.fingerprint_rounded,
                            isPassword: true,
                          ),
                          const SizedBox(height: 40),
                          
                          // ปุ่ม Login
                          SizedBox(
                            width: double.infinity,
                            height: 60,
                            child: ElevatedButton(
                              onPressed: _isLoading ? null : login,
                              style: ElevatedButton.styleFrom(
                                backgroundColor: swDeepBlue,
                                foregroundColor: Colors.white,
                                elevation: 0,
                                shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
                              ),
                              child: _isLoading 
                                ? const SizedBox(width: 24, height: 24, child: CircularProgressIndicator(color: Colors.white, strokeWidth: 2))
                                : const Text("Sign In", style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold)),
                            ),
                          ),
                        ],
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildInput({
    required TextEditingController controller,
    required String label,
    required IconData icon,
    bool isPassword = false,
  }) {
    return TextFormField(
      controller: controller,
      obscureText: isPassword ? _isObscure : false,
      decoration: InputDecoration(
        labelText: label,
        prefixIcon: Icon(icon, color: swPrimary),
        suffixIcon: isPassword 
            ? IconButton(
                icon: Icon(_isObscure ? Icons.visibility_off : Icons.visibility, color: swPrimary),
                onPressed: () => setState(() => _isObscure = !_isObscure),
              )
            : null,
        filled: true,
        fillColor: swBg.withOpacity(0.5),
        border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(15),
          borderSide: BorderSide.none,
        ),
        focusedBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(15),
          borderSide: BorderSide(color: swPrimary, width: 1.5),
        ),
      ),
      validator: (v) => v!.isEmpty ? "Required field" : null,
    );
  }
}