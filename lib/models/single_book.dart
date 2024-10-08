class SinglePageBook {
  final String key;
  final String title;
  final String author;
  final String authorKey;
  final String? coverUrl;
  final String? description;

  SinglePageBook({
    required this.key,
    required this.title,
    required this.author,
    required this.authorKey,
    this.coverUrl,
    this.description,
  });

  factory SinglePageBook.fromJson(Map<String, dynamic> json) {
    String? coverUrl;
    if (json['cover_id'] != null) {
      coverUrl = 'https://covers.openlibrary.org/b/id/${json['cover_id']}-L.jpg';
    } else if (json['covers'] != null && json['covers'].isNotEmpty) {
      coverUrl = 'https://covers.openlibrary.org/b/id/${json['covers'][0]}-L.jpg';
    }

    return SinglePageBook(
      key: json['key'] ?? 'No Key',
      title: json['title'] ?? 'No Title',
      author: (json['authors'] != null && json['authors'].isNotEmpty) ? json['authors'][0]['author']['key'] ?? 'Unknown Author' : 'Unknown Author',
      authorKey: (json['authors'] != null && json['authors'].isNotEmpty) ? json['authors'][0]['author']['key'] ?? 'Unknown Author' : 'Unknown Author',
      coverUrl: coverUrl,
      description: json['description'] is Map ? json['description']['value'] : json['description'] ?? 'No description available',
    );
  }
}