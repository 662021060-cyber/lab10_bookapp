import 'dart:convert';
import 'dart:io';
import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'package:shared_preferences/shared_preferences.dart';

class AddProductPage extends StatefulWidget {
  const AddProductPage({super.key});

  @override
  State<AddProductPage> createState() => _AddProductState();
}

class _AddProductState extends State<AddProductPage> {
  final _formKey = GlobalKey<FormState>();
  final _titleController = TextEditingController();
  final _authorController = TextEditingController();
  final _publishedYearController = TextEditingController();

  // กำหนดสีหลักของหน้านี้เป็นสีฟ้า
  final Color primaryColor = const Color(0xFF4FC3F7); // สีฟ้าอ่อน (Light Blue 300)
  final Color accentColor = const Color(0xFF0277BD);  // สีฟ้าเข้มสำหรับเน้น (Light Blue 800)

  Future<void> addProduct() async {
    final prefs = await SharedPreferences.getInstance();
    List<String>? tokenList = prefs.getStringList("token");
    final String token = (tokenList != null && tokenList.isNotEmpty) ? tokenList[0] : "";

    int? year = int.tryParse(_publishedYearController.text);
    if (year == null) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: const Text("กรุณากรอกปีพิมพ์เป็นตัวเลขเท่านั้น"),
          backgroundColor: Colors.redAccent, // แสดงสีแดงเมื่อเกิดข้อผิดพลาด
        ),
      );
      return;
    }

    var data = jsonEncode({
      "title": _titleController.text,
      "author": _authorController.text,
      "published_year": year,
    });

    var url = Uri.parse("http://10.0.2.2:3000/api/books");

    try {
      var response = await http.post(
        url,
        body: data,
        headers: {
          HttpHeaders.contentTypeHeader: "application/json",
          HttpHeaders.authorizationHeader: "Bearer $token",
        },
      );

      if (response.statusCode == 201 || response.statusCode == 200) {
        if (!mounted) return;
        Navigator.pop(context, true); 
      } else {
        if (!mounted) return;
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text("เพิ่มไม่สำเร็จ: ${response.statusCode}"),
            backgroundColor: Colors.redAccent,
          ),
        );
      }
    } catch (e) {
      debugPrint("Error: $e");
    }
  }

  // ปรับปรุงสไตล์ Input ให้เป็นโทนสีฟ้า
  InputDecoration inputStyle(String label, IconData icon) {
    return InputDecoration(
      labelText: label,
      labelStyle: TextStyle(color: accentColor), // สีของ Label เมื่อเลือก
      prefixIcon: Icon(icon, color: primaryColor), // สีไอคอนปกติ
      filled: true,
      fillColor: Colors.white.withOpacity(0.9), // พื้นหลังสีขาวโปร่งแสงเล็กน้อย
      contentPadding: const EdgeInsets.symmetric(vertical: 16, horizontal: 20),
      border: OutlineInputBorder(
        borderRadius: BorderRadius.circular(30), // ทำขอบมน
        borderSide: BorderSide.none, // ไม่มีเส้นขอบปกติ
      ),
      enabledBorder: OutlineInputBorder(
        borderRadius: BorderRadius.circular(30),
        borderSide: BorderSide(color: primaryColor.withOpacity(0.3), width: 1), // เส้นขอบอ่อนๆ
      ),
      focusedBorder: OutlineInputBorder(
        borderRadius: BorderRadius.circular(30),
        borderSide: BorderSide(color: primaryColor, width: 2), // เส้นขอบเข้มเมื่อเลือก
      ),
      errorBorder: OutlineInputBorder(
        borderRadius: BorderRadius.circular(30),
        borderSide: const BorderSide(color: Colors.redAccent, width: 1),
      ),
      focusedErrorBorder: OutlineInputBorder(
        borderRadius: BorderRadius.circular(30),
        borderSide: const BorderSide(color: Colors.redAccent, width: 2),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text("เพิ่มหนังสือใหม่", style: TextStyle(fontWeight: FontWeight.bold)),
        backgroundColor: primaryColor, //AppBar สีฟ้าอ่อน
        foregroundColor: Colors.white,
        centerTitle: true,
        elevation: 0, // เอาเงาออกเพื่อให้ดูแบนราบเข้ากับพื้นหลัง
      ),
      // ใช้ Stack เพื่อวางพื้นหลังไอคอนไว้ด้านล่างสุด
      body: Stack(
        children: [
          // 1. ส่วนพื้นหลังสีฟ้าอ่อนและไอคอนลวดลาย
          Container(
            color: const Color(0xFFE1F5FE), // สีพื้นหลังฟ้าอ่อนมาก (Light Blue 50)
            width: double.infinity,
            height: double.infinity,
          ),
          // ไอคอนลวดลายพื้นหลัง (Opacity ต่ำเพื่อให้ดูจางๆ)
          Positioned(
            top: 50,
            left: -30,
            child: Opacity(
              opacity: 0.05, // ความโปร่งแสงต่ำมาก
              child: Icon(Icons.import_contacts, size: 200, color: accentColor), // ไอคอนสมุด
            ),
          ),
          Positioned(
            bottom: -50,
            right: -30,
            child: Opacity(
              opacity: 0.05,
              child: Icon(Icons.library_books, size: 250, color: accentColor), // ไอคอนชั้นหนังสือ
            ),
          ),
          Positioned(
            top: 300,
            right: 50,
            child: Opacity(
              opacity: 0.03,
              child: Icon(Icons.book, size: 100, color: accentColor), // ไอคอนหนังสือ
            ),
          ),

          // 2. ส่วนเนื้อหาหลัก
          SingleChildScrollView(
            padding: const EdgeInsets.all(20),
            child: Form(
              key: _formKey,
              child: Column(
                children: [
                  const SizedBox(height: 10),
                  // ไอคอนแอปพลิเคชันส่วนหัวแบบเด่น
                  Container(
                    padding: const EdgeInsets.all(20),
                    decoration: BoxDecoration(
                      color: Colors.white,
                      shape: BoxShape.circle,
                      boxShadow: [
                        BoxShadow(
                          color: Colors.black.withOpacity(0.1),
                          spreadRadius: 2,
                          blurRadius: 10,
                          offset: const Offset(0, 5),
                        ),
                      ],
                    ),
                    child: Icon(Icons.add_business_rounded, size: 60, color: primaryColor), // ไอคอนเพิ่มสินค้า
                  ),
                  const SizedBox(height: 30),

                  // ส่วนกรอกข้อมูล
                  TextFormField(
                    controller: _titleController,
                    decoration: inputStyle("ชื่อหนังสือ", Icons.menu_book_rounded), // ไอคอนสมุดเปิด
                    style: TextStyle(color: accentColor),
                    validator: (v) => v!.isEmpty ? "กรุณากรอกชื่อหนังสือ" : null,
                  ),
                  const SizedBox(height: 18),
                  TextFormField(
                    controller: _authorController,
                    decoration: inputStyle("ชื่อผู้แต่ง", Icons.person_outline_rounded), // ไอคอนคน
                    style: TextStyle(color: accentColor),
                    validator: (v) => v!.isEmpty ? "กรุณากรอกชื่อผู้แต่ง" : null,
                  ),
                  const SizedBox(height: 18),
                  TextFormField(
                    controller: _publishedYearController,
                    keyboardType: TextInputType.number,
                    decoration: inputStyle("ปีที่พิมพ์ (พ.ศ.)", Icons.calendar_today_rounded), // ไอคอนปฏิทิน
                    style: TextStyle(color: accentColor),
                    validator: (v) {
                      if (v == null || v.isEmpty) return "กรุณากรอกปีที่พิมพ์";
                      if (int.tryParse(v) == null) return "กรุณากรอกเฉพาะตัวเลขปี พ.ศ.";
                      return null;
                    },
                  ),
                  const SizedBox(height: 40),

                  // ปุ่มเพิ่มหนังสือสไตล์มนโทนสีฟ้า
                  SizedBox(
                    width: double.infinity,
                    height: 55,
                    child: ElevatedButton.icon(
                      icon: const Icon(Icons.cloud_upload_outlined, size: 26), // ไอคอนอัปโหลด
                      label: const Text(
                        "บันทึกข้อมูลหนังสือ", 
                        style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold, letterSpacing: 1)
                      ),
                      style: ElevatedButton.styleFrom(
                        backgroundColor: accentColor, // ปุ่มสีฟ้าเข้มเพื่อให้เด่น
                        foregroundColor: Colors.white,
                        elevation: 5, // เพิ่มเงาให้ปุ่มดูมีมิติ
                        shadowColor: accentColor.withOpacity(0.5),
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(30), // ปุ่มขอบมน
                        ),
                      ),
                      onPressed: () {
                        if (_formKey.currentState!.validate()) {
                          addProduct();
                        }
                      },
                    ),
                  ),
                  const SizedBox(height: 20),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }
}