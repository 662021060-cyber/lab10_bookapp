import 'dart:convert';
import 'dart:io';

import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'package:lab10_bookapp/page/show_products.dart';
import 'package:shared_preferences/shared_preferences.dart';

void main() {
  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      debugShowCheckedModeBanner: false,
      title: 'Blue Login Flutter',
      theme: ThemeData(
        primarySwatch: Colors.blue,
        useMaterial3: true,
        fontFamily: 'Sans-serif',
      ),
      home: const LoginPage(),
    );
  }
}

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

  @override
  void dispose() {
    _usernameController.dispose();
    _passwordController.dispose();
    super.dispose();
  }

  // ================= LOGIN FUNCTION =================
  Future<void> login() async {
    if (!(_formKey.currentState?.validate() ?? false)) return;

    setState(() => _isLoading = true);

    try {
      var json = jsonEncode({
        "username": _usernameController.text.trim(),
        "password": _passwordController.text.trim(),
      });

      // Android Emulator ใช้ 10.0.2.2
      var url = Uri.parse("http://10.0.2.2:3000/api/auth/login");

      var response = await http.post(
        url,
        body: json,
        headers: {
          HttpHeaders.contentTypeHeader: "application/json",
        },
      );

      debugPrint(response.body); // แสดงผลเพื่อเช็คแค่ครั้งเดียว

      var data = jsonDecode(response.body); // แปลง JSON แค่ครั้งเดียวแล้วใช้งานร่วมกัน

      if (response.statusCode == 200) {
        SharedPreferences prefs = await SharedPreferences.getInstance();
        
        // ดึงข้อมูลจาก JSON object
        var userJson = data['payload'];
        var tokenStr = data['accesstoken'];

        // บันทึกข้อมูลลง SharedPreferences
        await prefs.setStringList('user', [
          userJson['username'].toString(),
          userJson['tel'].toString()
        ]);
        
        // *หมายเหตุ: Token ปกติเป็น String ตัวเดียว แนะนำให้ใช้ setString แทน setStringList
        await prefs.setString('token', tokenStr.toString()); 
        
        if (!mounted) return;

        // แสดงแจ้งเตือนเมื่อสำเร็จ
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text("Login success: ${data['message'] ?? ''}")),
        );

        // ดึงหน้า product ทั้งหมด (แนะนำใช้ pushReplacement เพื่อไม่ให้กดย้อนกลับมาหน้า Login ได้)
        Navigator.pushReplacement(
          context,
          MaterialPageRoute(builder: (context) => const ShowProducts()),
        );
      } else {
        if (!mounted) return;
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text("Login failed: ${data['message'] ?? 'Unknown error'}")),
        );
      }
    } catch (e) {
      debugPrint(e.toString());
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text("Connection error")),
      );
    } finally {
      // ใช้ finally เพื่อให้มั่นใจว่าปุ่มจะกลับมาทำงานได้ปกติไม่ว่าจะล็อกอินสำเร็จหรือไม่
      if (mounted) {
        setState(() => _isLoading = false);
      }
    }
  }

  // ================= UI =================
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Container(
        width: double.infinity,
        height: double.infinity,
        decoration: const BoxDecoration(
          gradient: LinearGradient(
            begin: Alignment.topLeft,
            end: Alignment.bottomRight,
            colors: [
              Color(0xFF66A6FF),
              Color(0xFF89F7FE),
            ],
          ),
        ),
        child: Center(
          child: SingleChildScrollView(
            padding: const EdgeInsets.all(20),
            child: Card(
              elevation: 10,
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(20),
              ),
              color: Colors.white,
              child: Padding(
                padding: const EdgeInsets.all(30.0),
                child: Form(
                  key: _formKey,
                  child: Column(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      const Icon(
                        Icons.lock_person_rounded,
                        size: 80,
                        color: Color(0xFF3498DB),
                      ),
                      const SizedBox(height: 10),
                      const Text(
                        "เข้าสู่ระบบ",
                        style: TextStyle(
                          fontSize: 28,
                          fontWeight: FontWeight.bold,
                          color: Color(0xFF2C3E50),
                        ),
                      ),
                      const SizedBox(height: 30),

                      // ===== USERNAME =====
                      TextFormField(
                        controller: _usernameController,
                        validator: (value) {
                          if (value == null || value.isEmpty) {
                            return "กรุณากรอกชื่อผู้ใช้";
                          }
                          return null;
                        },
                        decoration: InputDecoration(
                          labelText: "ชื่อผู้ใช้งาน",
                          prefixIcon: const Icon(Icons.person_outline),
                          border: OutlineInputBorder(
                            borderRadius: BorderRadius.circular(12),
                          ),
                        ),
                      ),

                      const SizedBox(height: 20),

                      // ===== PASSWORD =====
                      TextFormField(
                        controller: _passwordController,
                        obscureText: _isObscure,
                        validator: (value) {
                          if (value == null || value.isEmpty) {
                            return "กรุณากรอกรหัสผ่าน";
                          }
                          return null;
                        },
                        decoration: InputDecoration(
                          labelText: "รหัสผ่าน",
                          prefixIcon: const Icon(Icons.lock_outline),
                          suffixIcon: IconButton(
                            icon: Icon(
                              _isObscure
                                  ? Icons.visibility_off
                                  : Icons.visibility,
                            ),
                            onPressed: () {
                              setState(() {
                                _isObscure = !_isObscure;
                              });
                            },
                          ),
                          border: OutlineInputBorder(
                            borderRadius: BorderRadius.circular(12),
                          ),
                        ),
                      ),

                      const SizedBox(height: 30),

                      // ===== LOGIN BUTTON =====
                      SizedBox(
                        width: double.infinity,
                        height: 50,
                        child: ElevatedButton(
                          onPressed: _isLoading ? null : login,
                          style: ElevatedButton.styleFrom(
                            backgroundColor: const Color(0xFF3498DB),
                            foregroundColor: Colors.white,
                            shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(12),
                            ),
                          ),
                          child: _isLoading
                              ? const CircularProgressIndicator(
                                  color: Colors.white,
                                )
                              : const Text(
                                  "เข้าสู่ระบบ",
                                  style: TextStyle(
                                    fontSize: 18,
                                    fontWeight: FontWeight.bold,
                                  ),
                                ),
                        ),
                      ),

                      const SizedBox(height: 20),

                      SizedBox(
                        width: double.infinity,
                        height: 50,
                        child: OutlinedButton(
                          onPressed: () {},
                          child: const Text("ลงทะเบียน / สมัครสมาชิก"),
                        ),
                      ),
                    ],
                  ),
                ),
              ),
            ),
          ),
        ),
      ),
    );
  }
}