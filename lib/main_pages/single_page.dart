// lib/main_pages/single_page.dart

import 'dart:convert';
import 'package:http/http.dart' as http;
import 'package:flutter/material.dart';
import 'package:read_zone/components/navbar.dart';
import 'package:read_zone/main_pages/read_page.dart';
import 'package:read_zone/theme.dart';
import '../services/book_service.dart';
import 'author_works.dart';

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

class SinglePage extends StatefulWidget {
  final String bookKey;

  const SinglePage({Key? key, required this.bookKey}) : super(key: key);

  @override
  _SinglePageState createState() => _SinglePageState();
}

class _SinglePageState extends State<SinglePage> {
  late Future<SinglePageBook> _bookFuture;
  Future<Author>? _authorFuture;

  @override
  void initState() {
    super.initState();
    print('Fetching book with key: ${widget.bookKey}');
    _bookFuture = _fetchBookByKey(widget.bookKey);
  }

  Future<SinglePageBook> _fetchBookByKey(String key) async {
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
      return SinglePageBook.fromJson(data);
    } else {
      throw Exception('Failed to load book');
    }
  }

  Future<void> _fetchEditionsAndPrint(String key) async {
    try {
      final editions = await fetchEditionsByKey(key);
      if (editions.isNotEmpty) {
        final lastEdition = editions.last;
        String? validIsbn;

        // Check for valid ISBN-10
        if (lastEdition.isbn10 != null) {
          for (var isbn in lastEdition.isbn10!.reversed) {
            if (isbn.isNotEmpty) {
              validIsbn = isbn;
              break;
            }
          }
        }

        // If no valid ISBN-10, check for valid ISBN-13
        if (validIsbn == null && lastEdition.isbn13 != null) {
          for (var isbn in lastEdition.isbn13!.reversed) {
            if (isbn.isNotEmpty) {
              validIsbn = isbn;
              break;
            }
          }
        }

        if (validIsbn != null) {
          final itemUrl = await fetchBookDetailsByISBN(validIsbn);
          if (itemUrl != null) {
            Navigator.push(
              context,
              MaterialPageRoute(
                builder: (context) => ReadPage(
                  title: lastEdition.title,
                  url: itemUrl,
                ),
              ),
            );
          }
        } else {
          print('No valid ISBN-10 or ISBN-13 found for the last edition');
        }
      } else {
        print('No editions found');
      }
    } catch (e) {
      print('Error fetching editions: $e');
    }
  }

  Future<String?> fetchBookDetailsByISBN(String isbn) async {
    final String url = 'http://openlibrary.org/api/volumes/brief/isbn/$isbn.json';
    final headers = {
      'User-Agent': 'read_zone/1.0 (joshua.pardo30@gmail.com)',
    };
    final uri = Uri.parse(url);
    print('Fetching book details from URL: $url');
    final response = await http.get(uri, headers: headers);

    print('Response status: ${response.statusCode}');
    print('Response body: ${response.body}');

    if (response.statusCode == 200) {
      final Map<String, dynamic> data = json.decode(response.body);
      if (data.containsKey('items') && data['items'].isNotEmpty) {
        final itemUrl = data['items'][0]['itemURL'];
        print('Item URL: $itemUrl');
        return itemUrl;
      } else {
        print('No items found in the response');
      }
    } else {
      print('Failed to load book details');
    }
    return null;
  }

  Future<bool> _onWillPop() async {
    return true; // Return true to allow the back navigation
  }

  @override
  Widget build(BuildContext context) {
    return WillPopScope(
      onWillPop: _onWillPop,
      child: Scaffold(
        appBar: AppBar(
          title: Text(
            'Read Zone Library',
            style: TextStyle(color: Colors.black),
          ),
          backgroundColor: AppTheme.primaryColor,
          elevation: 0,
        ),
        body: FutureBuilder<SinglePageBook>(
          future: _bookFuture,
          builder: (context, snapshot) {
            print('FutureBuilder state: ${snapshot.connectionState}');
            if (snapshot.connectionState == ConnectionState.waiting) {
              return Center(child: CircularProgressIndicator());
            } else if (snapshot.hasError) {
              print('Error: ${snapshot.error}');
              return Center(child: Text('Error: ${snapshot.error}'));
            } else if (!snapshot.hasData) {
              print('No data available');
              return Center(child: Text('No data available'));
            } else {
              final book = snapshot.data!;
              print('Book loaded: ${book.title}');
              print('Author Key: ${book.authorKey}'); // Print the author key
              if (book.authorKey != 'Unknown Author') {
                _authorFuture = BookService().fetchAuthorByKey(book.authorKey);
              }
              return Padding(
                padding: const EdgeInsets.all(16.0),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    // Book Cover
                    Center(
                      child: Container(
                        width: 150,
                        height: 230,
                        decoration: BoxDecoration(
                          borderRadius: BorderRadius.circular(12),
                          color: Colors.grey[300],
                        ),
                        child: book.coverUrl != null
                            ? Image.network(book.coverUrl!, fit: BoxFit.cover)
                            : Icon(Icons.book, size: 100, color: Colors.black26),
                      ),
                    ),
                    SizedBox(height: 20),

                    // Book Title
                    Text(
                      book.title,
                      style: TextStyle(
                        fontSize: 24,
                        fontWeight: FontWeight.bold,
                        color: Colors.black,
                      ),
                    ),
                    SizedBox(height: 10),

                    // Book Author
                    _authorFuture != null
                        ? FutureBuilder<Author>(
                      future: _authorFuture,
                      builder: (context, snapshot) {
                        if (snapshot.connectionState == ConnectionState.waiting) {
                          return Text(
                            'by Loading...',
                            style: TextStyle(
                              fontSize: 18,
                              color: Colors.black54,
                            ),
                          );
                        } else if (snapshot.hasError) {
                          return Text(
                            'by Unknown Author',
                            style: TextStyle(
                              fontSize: 18,
                              color: Colors.black54,
                            ),
                          );
                        } else if (!snapshot.hasData) {
                          return Text(
                            'by Unknown Author',
                            style: TextStyle(
                              fontSize: 18,
                              color: Colors.black54,
                            ),
                          );
                        } else {
                          final author = snapshot.data!;
                          return GestureDetector(
                            onTap: () {
                              Navigator.push(
                                context,
                                MaterialPageRoute(
                                  builder: (context) => AuthorWorksPage(authorKey: author.key),
                                ),
                              );
                            },
                            child: Text(
                              'by ${author.name}',
                              style: TextStyle(
                                fontSize: 18,
                                color: Colors.black54,
                                decoration: TextDecoration.underline,
                              ),
                            ),
                          );
                        }
                      },
                    )
                        : Text(
                      'by Unknown Author',
                      style: TextStyle(
                        fontSize: 18,
                        color: Colors.black54,
                      ),
                    ),
                    SizedBox(height: 20),

                    // Book Description
                    Expanded(
                      child: SingleChildScrollView(
                        child: Text(
                          book.description ?? 'No description available',
                          style: TextStyle(
                            fontSize: 16,
                            color: Colors.black87,
                          ),
                        ),
                      ),
                    ),
                    SizedBox(height: 20),

                    // Action buttons
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceAround,
                      children: [
                        ElevatedButton.icon(
                          onPressed: () {
                            // Save to favorites logic
                          },
                          icon: Icon(Icons.favorite_border, color: Colors.black),
                          label: Text(
                            'Save to Favorites',
                            style: TextStyle(color: Colors.black),
                          ),
                          style: ElevatedButton.styleFrom(
                            backgroundColor: AppTheme.primaryColor,
                            foregroundColor: Colors.black,
                          ),
                        ),
                        ElevatedButton.icon(
                          onPressed: () {
                            _fetchEditionsAndPrint(book.key);
                          },
                          icon: Icon(Icons.book, color: Colors.black),
                          label: Text(
                            'Read Now',
                            style: TextStyle(color: Colors.black),
                          ),
                          style: ElevatedButton.styleFrom(
                            backgroundColor: AppTheme.secondaryColor,
                            foregroundColor: Colors.black,
                          ),
                        ),
                      ],
                    ),
                  ],
                ),
              );
            }
          },
        ),
        bottomNavigationBar: Navbar(
          currentIndex: 2, // Assuming the current index is 2 for the SinglePage
          onTap: (index) {
            // Handle navigation based on the selected index
          },
        ),
      ),
    );
  }
}