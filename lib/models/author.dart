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
