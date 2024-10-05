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

  Future<Book> fetchBookByKey(String key) async {
    final String url = 'https://openlibrary.org/$key.json';
    final headers = {
      'User-Agent': 'read_zone/1.0 (joshua.pardo30@gmail.com)',
    };
    final uri = Uri.parse(url);
    print('Fetching book from URL: $url');
    final response = await http.get(uri, headers: headers);

    print('Response status: ${response.statusCode}');
    print('Response body: ${response.body}');

    if (response.statusCode == 200) {
      final Map<String, dynamic> data = json.decode(response.body);
      return Book.fromJson(data);
    } else {
      throw Exception('Failed to load book');
    }
  }
}

class Book {
  final String key;
  final String title;
  final String author;
  final String? coverUrl;
  final String? description;

  Book({
    required this.key,
    required this.title,
    required this.author,
    this.coverUrl,
    this.description,
  });

  factory Book.fromJson(Map<String, dynamic> json) {
    String? coverUrl;
    if (json['covers'] != null && json['covers'].isNotEmpty) {
      coverUrl = 'https://covers.openlibrary.org/b/id/${json['covers'][0]}-L.jpg';
    }
    return Book(
      key: json['key'] ?? 'No Key',
      title: json['title'] ?? 'No Title',
      author: (json['authors'] != null && json['authors'].isNotEmpty) ? json['authors'][0]['author']['key'] : 'Unknown Author',
      coverUrl: coverUrl,
      description: json['description'] ?? 'No description available',
    );
  }
}
