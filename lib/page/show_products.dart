import 'dart:io';

import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';

class ShowProducts extends StatelessWidget{
  const ShowProducts({super.key});

  @override
  Widget build(BuildContext context) {
    return const Placeholder();
  }
}

Future<void> getlist() async{
  books =[];
  final prefs = await SharedPreferences.gelInstance();
  final token = prefs.getString("token") ?? "";

  var url =Uri.parse("http://localhost:3000/api/books");
  var response = await http.get(url,headers:{
    HttpHeaders.contentTypeHeader : 'application/json',
    HttpHeaders.authorizationHeader: 'Bearer ${token}',
  });

  
}