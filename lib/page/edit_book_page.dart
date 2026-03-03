import 'dart:convert';
import 'dart:io';
import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'package:lab10_bookapp/models/BookModel.dart';
import 'package:shared_preferences/shared_preferences.dart';

class EditBookPage extends StatefulWidget {
  final BookModel book; // รับข้อมูลหนังสือทั้งก้อนมาจากหน้า ShowProducts
  const EditBookPage({super.key, required this.book});

  @override
  State<EditBookPage> createState() => _EditBookPageState();
}

class _EditBookPageState extends State<EditBookPage> {
  final _formKey = GlobalKey<FormState>();
  
  // Controller สำหรับช่องกรอกข้อมูล
  late TextEditingController _titleController;
  late TextEditingController _authorController;
  late TextEditingController _yearController;
  
  bool _isLoading = false;

  // 🌊 ธีมสี StoryWeave
  final Color swDeepBlue = const Color(0xFF0288D1);
  final Color swPrimary = const Color(0xFF4FC3F7);

  @override
  void initState() {
    super.initState();
    // นำค่าจาก widget.book ที่ส่งมา มาใส่ใน Controller ทันที
    _titleController = TextEditingController(text: widget.book.title);
    _authorController = TextEditingController(text: widget.book.author);
    _yearController = TextEditingController(text: widget.book.publishedYear.toString());
  }

  @override
  void dispose() {
    _titleController.dispose();
    _authorController.dispose();
    _yearController.dispose();
    super.dispose();
  }

  // ฟังก์ชันส่งข้อมูลการแก้ไข (Update)
  Future<void> _updateBook() async {
    if (!_formKey.currentState!.validate()) return;

    setState(() => _isLoading = true);

    try {
      // 1. ดึง Token ให้ถูกวิธี (ดึงจาก List)
      final SharedPreferences prefs = await SharedPreferences.getInstance();
      List<String>? tokenList = prefs.getStringList("token");
      String token = (tokenList != null && tokenList.isNotEmpty) ? tokenList[0] : "";

      // 2. เตรียมข้อมูล (ตรวจสอบปีให้เป็นตัวเลข)
      var data = jsonEncode({
        "title": _titleController.text.trim(),
        "author": _authorController.text.trim(),
        "published_year": int.parse(_yearController.text.trim()),
      });

      // 3. ยิง API โดยใช้ ID จาก widget.book
      var url = Uri.parse("http://10.0.2.2:3000/api/books/${widget.book.id}");
      var response = await http.put(
        url,
        body: data,
        headers: {
          HttpHeaders.contentTypeHeader: 'application/json',
          HttpHeaders.authorizationHeader: 'Bearer $token',
        },
      ).timeout(const Duration(seconds: 10));

      if (response.statusCode == 200) {
        if (!mounted) return;
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text("แก้ไขข้อมูลสำเร็จ!"), backgroundColor: Colors.green),
        );
        Navigator.pop(context, true); // ส่งค่า true กลับไปหน้า ShowProducts เพื่อสั่ง Refresh
      } else {
        _showError("แก้ไขไม่สำเร็จ: ${response.statusCode}");
      }
    } catch (e) {
      _showError("เกิดข้อผิดพลาด: $e\n(กรุณาตรวจสอบว่ากรอกปีเป็นตัวเลขเท่านั้น)");
    } finally {
      if (mounted) setState(() => _isLoading = false);
    }
  }

  void _showError(String message) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(content: Text(message), backgroundColor: Colors.red),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFF0F9FF), // พื้นหลังฟ้าจาง
      appBar: AppBar(
        title: const Text("EDIT STORY", style: TextStyle(fontWeight: FontWeight.w900, letterSpacing: 1.2)),
        backgroundColor: swPrimary,
        foregroundColor: Colors.white,
        centerTitle: true,
        elevation: 0,
        shape: const RoundedRectangleBorder(
          borderRadius: BorderRadius.vertical(bottom: Radius.circular(20)),
        ),
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(24.0),
        child: Form(
          key: _formKey,
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                children: [
                  Icon(Icons.edit_note_rounded, color: swDeepBlue, size: 30),
                  const SizedBox(width: 10),
                  Text("Update Book Information", 
                    style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold, color: swDeepBlue)),
                ],
              ),
              const SizedBox(height: 25),
              
              _buildTextField(
                controller: _titleController,
                label: "Book Title",
                icon: Icons.book_rounded,
              ),
              const SizedBox(height: 16),
              _buildTextField(
                controller: _authorController,
                label: "Author Name",
                icon: Icons.person_rounded,
              ),
              const SizedBox(height: 16),
              _buildTextField(
                controller: _yearController,
                label: "Published Year",
                icon: Icons.calendar_today_rounded,
                isNumber: true,
              ),
              
              const SizedBox(height: 40),
              _buildSubmitButton(),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildTextField({
    required TextEditingController controller,
    required String label,
    required IconData icon,
    bool isNumber = false,
  }) {
    return TextFormField(
      controller: controller,
      keyboardType: isNumber ? TextInputType.number : TextInputType.text,
      decoration: InputDecoration(
        labelText: label,
        prefixIcon: Icon(icon, color: swPrimary),
        filled: true,
        fillColor: Colors.white,
        border: OutlineInputBorder(borderRadius: BorderRadius.circular(15), borderSide: BorderSide.none),
        focusedBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(15),
          borderSide: BorderSide(color: swPrimary, width: 2),
        ),
      ),
      validator: (value) => value!.isEmpty ? "กรุณากรอกข้อมูล" : null,
    );
  }

  Widget _buildSubmitButton() {
    return SizedBox(
      width: double.infinity,
      height: 55,
      child: ElevatedButton(
        style: ElevatedButton.styleFrom(
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(15)),
          backgroundColor: swDeepBlue,
          foregroundColor: Colors.white,
          elevation: 2,
        ),
        onPressed: _isLoading ? null : _updateBook,
        child: _isLoading 
          ? const SizedBox(width: 25, height: 25, child: CircularProgressIndicator(color: Colors.white, strokeWidth: 2))
          : const Text("บันทึกการแก้ไข", style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold)),
      ),
    );
  }
}