import 'package:open_library/models/ol_search_doc_model.dart';
import 'package:open_library/models/ol_search_model.dart';
import 'package:open_library/open_library.dart';
import 'dart:typed_data';

class BookService {
  final OpenLibrary _openLibrary = OpenLibrary();

  Future<List<Book>> fetchBooks(String query, {int limit = 10, int page = 1}) async {
    // Include pagination information in the query string
    final String paginatedQuery = '$query&page=$page';
    final OLSearchBase result = await _openLibrary.query(q: paginatedQuery, limit: limit);
    print('Fetching books for query: $query, limit: $limit, page: $page');

    if (result is OLSearch && result.docs != null) {
      return result.docs!.map((doc) => Book.fromDoc(doc)).toList();
    } else {
      throw Exception('Failed to load books');
    }
  }
}

class Book {
  final String title;
  final String author;
  final Uint8List? cover;

  Book({required this.title, required this.author, this.cover});

  factory Book.fromDoc(OLSearchDoc doc) {
    return Book(
      title: doc.title ?? 'No Title',
      author: (doc.authors != null && doc.authors!.isNotEmpty) ? doc.authors![0].name : 'Unknown Author',
      cover: doc.covers != null && doc.covers!.isNotEmpty ? doc.covers![0] : null,
    );
  }
}