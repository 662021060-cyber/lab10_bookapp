import 'dart:convert';
import 'dart:io';
import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'package:shared_preferences/shared_preferences.dart';

import 'package:lab10_bookapp/models/BookModel.dart';
import 'package:lab10_bookapp/page/login_page.dart';
import 'package:lab10_bookapp/page/add_product.dart';
import 'package:lab10_bookapp/page/edit_book_page.dart';

class ShowProducts extends StatefulWidget {
  const ShowProducts({super.key});

  @override
  State<ShowProducts> createState() => _ShowProductsState();
}

class _ShowProductsState extends State<ShowProducts> {
  List<BookModel>? books;
  bool isLoading = true;

  final Color primaryBlue = const Color(0xFF4FC3F7); 
  final Color darkBlue = const Color(0xFF0277BD);    
  final Color bgBlue = const Color(0xFFE1F5FE);      

  @override
  void initState() {
    super.initState();
    getList();
  }

  // ฟังก์ชันออกจากระบบ
  Future<void> _logout() async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.clear(); // ล้างข้อมูลทั้งหมด (Token, User)
    
    if (!mounted) return;
    // ย้ายกลับไปหน้า Login และล้าง Stack หน้าจอทั้งหมด
    Navigator.pushAndRemoveUntil(
      context,
      MaterialPageRoute(builder: (context) => const LoginPage()),
      (route) => false,
    );
  }

  // ยืนยันการออกจากระบบ
  void _showLogoutDialog() {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
        title: const Text("ออกจากระบบ"),
        content: const Text("คุณต้องการออกจากระบบ StoryWeave ใช่หรือไม่?"),
        actions: [
          TextButton(onPressed: () => Navigator.pop(context), child: const Text("ยกเลิก")),
          ElevatedButton(
            style: ElevatedButton.styleFrom(backgroundColor: darkBlue, foregroundColor: Colors.white),
            onPressed: _logout,
            child: const Text("ตกลง"),
          ),
        ],
      ),
    );
  }

  Future<String> _getToken() async {
    final prefs = await SharedPreferences.getInstance();
    List<String>? tokenList = prefs.getStringList("token");
    return (tokenList != null && tokenList.isNotEmpty) ? tokenList[0] : "";
  }

  Future<void> getList() async {
    if (!mounted) return;
    setState(() => isLoading = true);
    try {
      String token = await _getToken();
      var url = Uri.parse("http://10.0.2.2:3000/api/books");
      var response = await http.get(
        url,
        headers: {
          HttpHeaders.contentTypeHeader: 'application/json',
          HttpHeaders.authorizationHeader: 'Bearer $token',
        },
      );

      if (response.statusCode == 200) {
        var jsonStr = jsonDecode(response.body);
        setState(() {
          books = (jsonStr['message'] as List)
              .map((item) => BookModel.fromJson(item))
              .toList();
        });
      }
    } catch (e) {
      debugPrint("Error fetching: $e");
    } finally {
      if (mounted) setState(() => isLoading = false);
    }
  }

  Future<void> deleteBook(dynamic id) async {
    try {
      String token = await _getToken();
      var url = Uri.parse("http://10.0.2.2:3000/api/books/$id");
      var response = await http.delete(
        url,
        headers: {HttpHeaders.authorizationHeader: 'Bearer $token'},
      );

      if (response.statusCode == 200) {
        if (mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(content: Text("ลบข้อมูลเรียบร้อยแล้ว"), backgroundColor: Colors.blue),
          );
        }
        getList();
      }
    } catch (e) {
      debugPrint("Delete Error: $e");
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: bgBlue,
      appBar: AppBar(
        title: const Text("StoryWeave IT", style: TextStyle(fontWeight: FontWeight.bold, letterSpacing: 1.2)),
        backgroundColor: primaryBlue,
        foregroundColor: Colors.white,
        centerTitle: true,
        elevation: 0,
        shape: const RoundedRectangleBorder(
          borderRadius: BorderRadius.vertical(bottom: Radius.circular(20)),
        ),
        // เพิ่มปุ่มออกจากระบบที่มุมขวา
        actions: [
          IconButton(
            icon: const Icon(Icons.logout_rounded),
            tooltip: 'ออกจากระบบ',
            onPressed: _showLogoutDialog,
          ),
          const SizedBox(width: 8),
        ],
      ),
      body: Stack(
        children: [
          Positioned(
            bottom: -50,
            left: -50,
            child: Opacity(
              opacity: 0.05,
              child: Icon(Icons.cloud_queue, size: 300, color: darkBlue),
            ),
          ),
          Positioned(
            top: 50,
            right: -30,
            child: Opacity(
              opacity: 0.05,
              child: Icon(Icons.computer, size: 200, color: darkBlue),
            ),
          ),

          isLoading
              ? Center(child: CircularProgressIndicator(color: primaryBlue))
              : RefreshIndicator(
                  color: primaryBlue,
                  onRefresh: getList,
                  child: books == null || books!.isEmpty
                      ? _buildEmptyState()
                      : ListView.builder(
                          padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 25),
                          itemCount: books!.length,
                          itemBuilder: (context, index) => _buildBookCard(books![index]),
                        ),
                ),
        ],
      ),
      floatingActionButton: FloatingActionButton.extended(
        backgroundColor: darkBlue,
        onPressed: () {
          Navigator.push(
            context,
            MaterialPageRoute(builder: (context) => const AddProductPage()),
          ).then((value) {
            if (value == true) getList();
          });
        },
        label: const Text("เพิ่มหนังสือ", style: TextStyle(color: Colors.white)),
        icon: const Icon(Icons.add, color: Colors.white),
      ),
    );
  }

  Widget _buildBookCard(BookModel book) {
    return Container(
      margin: const EdgeInsets.only(bottom: 18),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(20),
        boxShadow: [
          BoxShadow(
            color: Colors.blue.withOpacity(0.1),
            blurRadius: 10,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: ListTile(
        contentPadding: const EdgeInsets.symmetric(horizontal: 20, vertical: 10),
        leading: CircleAvatar(
          backgroundColor: bgBlue,
          child: Icon(Icons.book, color: darkBlue),
        ),
        title: Text(
          book.title,
          style: TextStyle(fontWeight: FontWeight.bold, color: darkBlue, fontSize: 16),
        ),
        subtitle: Padding(
          padding: const EdgeInsets.only(top: 5),
          child: Text("ผู้แต่ง: ${book.author}\nปีที่พิมพ์: ${book.publishedYear}"),
        ),
        trailing: Container(
          decoration: BoxDecoration(
            color: Colors.red.shade50,
            shape: BoxShape.circle,
          ),
          child: IconButton(
            icon: const Icon(Icons.delete_outline, color: Colors.redAccent),
            onPressed: () => _showDeleteConfirmDialog(book),
          ),
        ),
        onTap: () {
           Navigator.push(
            context,
            MaterialPageRoute(builder: (context) => EditBookPage(book: book)),
          ).then((value) {
            if (value == true) getList();
          });
        },
      ),
    );
  }

  void _showDeleteConfirmDialog(BookModel book) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
        title: const Text("ยืนยันการลบ"),
        content: Text("คุณต้องการลบข้อมูล '${book.title}' ใช่หรือไม่?"),
        actions: [
          TextButton(onPressed: () => Navigator.pop(context), child: const Text("ยกเลิก")),
          ElevatedButton(
            style: ElevatedButton.styleFrom(backgroundColor: Colors.redAccent, foregroundColor: Colors.white),
            onPressed: () {
              Navigator.pop(context);
              deleteBook(book.id);
            },
            child: const Text("ลบข้อมูล"),
          ),
        ],
      ),
    );
  }

  Widget _buildEmptyState() {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(Icons.library_books_outlined, size: 80, color: primaryBlue.withOpacity(0.5)),
          const SizedBox(height: 15),
          const Text("ยังไม่มีข้อมูลหนังสือในระบบ", style: TextStyle(color: Colors.grey, fontSize: 16)),
        ],
      ),
    );
  }
}