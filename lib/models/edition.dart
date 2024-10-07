class Edition {
  final String key;
  final String title;
  final String? coverUrl;
  final List<String>? isbn10;
  final List<String>? isbn13; // Add this line

  Edition({
    required this.key,
    required this.title,
    this.coverUrl,
    this.isbn10,
    this.isbn13, // Add this line
  });

  factory Edition.fromJson(Map<String, dynamic> json) {
    String? coverUrl;
    if (json['cover_id'] != null) {
      coverUrl = 'https://covers.openlibrary.org/b/id/${json['cover_id']}-S.jpg';
    } else if (json['covers'] != null && json['covers'].isNotEmpty) {
      coverUrl = 'https://covers.openlibrary.org/b/id/${json['covers'][0]}-S.jpg';
    }

    return Edition(
      key: json['key'] ?? 'No Key',
      title: json['title'] ?? 'No Title',
      coverUrl: coverUrl,
      isbn10: json['isbn_10'] != null ? List<String>.from(json['isbn_10']) : null,
      isbn13: json['isbn_13'] != null ? List<String>.from(json['isbn_13']) : null, // Add this line
    );
  }
}