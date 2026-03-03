//     final bookModel = bookModelFromJson(jsonString);     
// ignore_for_file: file_names

import 'dart:convert';

BookModel bookModelFromJson(String str) => BookModel.fromJson(json.decode(str));

String bookModelToJson(BookModel data) => json.encode(data.toJson());

class BookModel {
    int id;
    String title;
    String author;
    int publishedYear;

    BookModel({
        required this.id,
        required this.title,
        required this.author,
        required this.publishedYear,
    });

    factory BookModel.fromJson(Map<String, dynamic> json) => BookModel(
        id: json["id"],
        title: json["title"],
        author: json["author"],
        publishedYear: json["published_year"],
    );

    Map<String, dynamic> toJson() => {
        "id": id,
        "title": title,
        "author": author,
        "published_year": publishedYear,
    };
}