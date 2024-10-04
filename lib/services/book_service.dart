import 'package:open_library/models/ol_search_doc_model.dart';
import 'package:open_library/models/ol_search_model.dart';
import 'package:open_library/open_library.dart';

class BookService {
  final OpenLibrary _openLibrary = OpenLibrary();

  Future<List<Book>> fetchBooks(String query, {int limit = 10}) async {
    final OLSearchBase result = await _openLibrary.query(q: query, limit: limit);
    print('Fetching books for query: $query, limit: $limit');

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
  final String coverUrl;

  Book({required this.title, required this.author, required this.coverUrl});

  factory Book.fromDoc(OLSearchDoc doc) {
    return Book(
      title: doc.title ?? 'No Title',
      author: (doc.authors != null && doc.authors!.isNotEmpty) ? doc.authors![0].name : 'Unknown Author',
      coverUrl: doc.covers != null && doc.covers!.isNotEmpty ? 'https://covers.openlibrary.org/b/id/${doc.covers![0]}-L.jpg' : '',
    );
  }
}