import 'dart:convert';
import 'package:http/http.dart' as http;

import '../models/author.dart';
import '../models/book.dart';
import '../models/edition.dart';

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
    print('Fetching book key: ${url}');

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
    print('Response body: ${url}');

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
    print('Response body: ${url}');

    if (response.statusCode == 200) {
      final Map<String, dynamic> data = json.decode(response.body);
      return Author.fromJson(data);
    } else {
      throw Exception('Failed to load author');
    }
  }
}

Future<List<Edition>> fetchEditionsByKey(String key) async {
  final String url = 'https://openlibrary.org/$key/editions.json';
  final headers = {
    'User-Agent': 'read_zone/1.0 (joshua.pardo30@gmail.com)',
  };
  final uri = Uri.parse(url);
  print('Fetching editions from URL: $url');
  final response = await http.get(uri, headers: headers);

  print('Response status: ${response.statusCode}');
  print('Response body: ${response.body}');

  if (response.statusCode == 200) {
    final Map<String, dynamic> data = json.decode(response.body);
    final List<dynamic> entries = data['entries'];
    return entries.map((entry) => Edition.fromJson(entry)).toList();
  } else {
    throw Exception('Failed to load editions');
  }



}

Future<List<Book>> fetchSearchResults(String query, {int limit = 5, int offset = 0}) async {
  final String url = 'https://openlibrary.org/search.json?q=${Uri.encodeComponent(query)}&limit=$limit&offset=$offset';
  final response = await http.get(Uri.parse(url));

  if (response.statusCode == 200) {
    final Map<String, dynamic> data = json.decode(response.body);
    final List<dynamic> docs = data['docs'];
    List<Book> books = [];

    for (var doc in docs) {
      String authorKey = doc['author_key'][0];
      String authorName = doc['author_name'][0];
      String coverUrl = doc['cover_i'] != null
          ? 'https://covers.openlibrary.org/b/id/${doc['cover_i']}-L.jpg'
          : '';

      books.add(Book(
        key: doc['key'],
        title: doc['title'],
        author: authorName,
        authorKey: authorKey,
        coverUrl: coverUrl,
      ));
    }

    return books;
  } else {
    throw Exception('Failed to load search results');
  }
}