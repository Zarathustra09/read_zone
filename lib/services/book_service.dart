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

    // Print statement to log the URL being fetched
    print('Fetching books from URL: $uri');

    final response = await http.get(uri, headers: headers);

    if (response.statusCode == 200) {
      final Map<String, dynamic> data = json.decode(response.body);
      final List<dynamic> works = data['works']; // Correctly access the 'works' key
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

  Future<List<Book>> fetchAuthorWorks(String authorKey) async {
    final String url = 'https://openlibrary.org/$authorKey/works.json';
    final headers = {
      'User-Agent': 'read_zone/1.0 (joshua.pardo30@gmail.com)',
    };
    final uri = Uri.parse(url);
    print('Fetching works for author from URL: $url');
    final response = await http.get(uri, headers: headers);

    print('Response status: ${response.statusCode}');
    print('Response body: ${response.body}');

    if (response.statusCode == 200) {
      final Map<String, dynamic> data = json.decode(response.body);
      final List<dynamic> entries = data['entries'];
      final List<Book> books = entries
          .where((entry) => entry['authors'].any((author) => author['author']['key'] == authorKey))
          .map((entry) => Book.fromJson(entry))
          .toList();
      return books;
    } else {
      throw Exception('Failed to load author works');
    }
  }

  Future<Author> fetchAuthorByKey(String authorKey) async {
    final String url = 'https://openlibrary.org/$authorKey.json';
    final headers = {
      'User-Agent': 'read_zone/1.0 (joshua.pardo30@gmail.com)',
    };
    final uri = Uri.parse(url);
    print('Fetching author from URL: $url');
    final response = await http.get(uri, headers: headers);

    print('Response status: ${response.statusCode}');
    print('Response body: ${response.body}');

    if (response.statusCode == 200) {
      final Map<String, dynamic> data = json.decode(response.body);
      return Author.fromJson(data);
    } else {
      throw Exception('Failed to load author');
    }
  }
}

class Author {
  final String key;
  final String name;

  Author({
    required this.key,
    required this.name,
  });

  factory Author.fromJson(Map<String, dynamic> json) {
    return Author(
      key: json['key'],
      name: json['name'],
    );
  }
}


class Book {
  final String key;
  final String title;
  final String author;
  final String authorKey;
  final String? coverUrl;
  final String? description;

  Book({
    required this.key,
    required this.title,
    required this.author,
    required this.authorKey,
    this.coverUrl,
    this.description,
  });

  factory Book.fromJson(Map<String, dynamic> json) {
    String? coverUrl;
    if (json['cover_id'] != null) {
      coverUrl = 'https://covers.openlibrary.org/b/id/${json['cover_id']}-S.jpg';
    } else if (json['covers'] != null && json['covers'].isNotEmpty) {
      coverUrl = 'https://covers.openlibrary.org/b/id/${json['covers'][0]}-S.jpg';
    }

    return Book(
      key: json['key'] ?? 'No Key',
      title: json['title'] ?? 'No Title',
      author: (json['authors'] != null && json['authors'].isNotEmpty) ? json['authors'][0]['name'] ?? 'Unknown Author' : 'Unknown Author',
      authorKey: (json['authors'] != null && json['authors'].isNotEmpty) ? json['authors'][0]['key'] ?? 'Unknown Author' : 'Unknown Author',
      coverUrl: coverUrl,
      description: json['description'] is Map ? json['description']['value'] : json['description'] ?? 'No description available',
    );
  }
}