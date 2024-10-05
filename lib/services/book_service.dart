import 'dart:convert';
import 'package:http/http.dart' as http;

class BookService {
  final String _baseUrl = 'https://openlibrary.org/subjects';

  Future<List<Book>> fetchBooks(String subject, {int limit = 10, int offset = 0}) async {
    final String url = '$_baseUrl/$subject.json';
    final headers = {
      'User-Agent': 'read_zone/1.0 (joshua.pardo30@gmail.com)',
    };
    final queryParameters = {
      'limit': limit.toString(),
      'offset': offset.toString(),
    };
    final uri = Uri.parse(url).replace(queryParameters: queryParameters);
    final response = await http.get(uri, headers: headers);

    if (response.statusCode == 200) {
      final Map<String, dynamic> data = json.decode(response.body);
      final List<dynamic> works = data['works'];
      return works.map((work) => Book.fromJson(work)).toList();
    } else {
      throw Exception('Failed to load books');
    }
  }
}

class Book {
  final String key;
  final String title;
  final String author;
  final String? coverUrl;

  Book({required this.key, required this.title, required this.author, this.coverUrl});

  factory Book.fromJson(Map<String, dynamic> json) {
    String? coverUrl;
    if (json['cover_id'] != null) {
      coverUrl = 'https://covers.openlibrary.org/b/id/${json['cover_id']}-S.jpg';
    }
    return Book(
      key: json['key'] ?? 'No Key',
      title: json['title'] ?? 'No Title',
      author: (json['authors'] != null && json['authors'].isNotEmpty) ? json['authors'][0]['name'] : 'Unknown Author',
      coverUrl: coverUrl,
    );
  }
}