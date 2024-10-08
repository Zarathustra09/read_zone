// lib/models/book.dart

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

  Map<String, dynamic> toJson() {
    return {
      'key': key,
      'title': title,
      'author': author,
      'authorKey': authorKey,
      'coverUrl': coverUrl,
      'description': description,
    };
  }
}