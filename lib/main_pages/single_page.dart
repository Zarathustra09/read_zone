// lib/main_pages/single_page.dart

import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:read_zone/components/navbar.dart';
import 'package:read_zone/main_pages/read_page.dart';
import 'package:read_zone/theme.dart';
import '../models/author.dart';
import '../models/book.dart';
import '../models/single_book.dart';
import '../services/book_service.dart';
import '../services/user_service.dart';
import 'author_works.dart';
import 'package:http/http.dart' as http;

class SinglePage extends StatefulWidget {
  final String bookKey;

  const SinglePage({Key? key, required this.bookKey}) : super(key: key);

  @override
  _SinglePageState createState() => _SinglePageState();
}

class _SinglePageState extends State<SinglePage> {
  late Future<SinglePageBook> _bookFuture;
  Future<Author>? _authorFuture;
  final UserService _userService = UserService();
  bool _isFavorite = false;
  bool _isLoading = false;

  @override
  void initState() {
    super.initState();
    _bookFuture = _fetchBookByKey(widget.bookKey);
    _checkIfFavorite();
  }

  Future<void> _checkIfFavorite() async {
    final isFavorite = await _userService.isBookInFavorites(widget.bookKey);
    setState(() {
      _isFavorite = isFavorite;
    });
  }

  Future<SinglePageBook> _fetchBookByKey(String key) async {
    final String url = 'https://openlibrary.org/$key.json';
    final headers = {
      'User-Agent': 'read_zone/1.0 (joshua.pardo30@gmail.com)',
    };
    final uri = Uri.parse(url);
    final response = await http.get(uri, headers: headers);

    if (response.statusCode == 200) {
      final Map<String, dynamic> data = json.decode(response.body);
      return SinglePageBook.fromJson(data);
    } else {
      throw Exception('Failed to load book');
    }
  }

  Future<void> _fetchEditionsAndPrint(String key) async {
    setState(() {
      _isLoading = true;
    });

    try {
      final editions = await fetchEditionsByKey(key);
      if (editions.isNotEmpty) {
        final lastEdition = editions.last;
        String? validIsbn;

        if (lastEdition.isbn10 != null) {
          for (var isbn in lastEdition.isbn10!.reversed) {
            if (isbn.isNotEmpty) {
              validIsbn = isbn;
              break;
            }
          }
        }

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
          } else {
            _showMessage("The book is not available");
          }
        } else {
          _showMessage("The book is not available");
        }
      } else {
        _showMessage("The book is not available");
      }
    } catch (e) {
      print('Error fetching editions: $e');
    } finally {
      setState(() {
        _isLoading = false;
      });
    }
  }

  void _showMessage(String message) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(message),
        backgroundColor: Colors.red,
      ),
    );
  }

  Future<String?> fetchBookDetailsByISBN(String isbn) async {
    final String url = 'http://openlibrary.org/api/volumes/brief/isbn/$isbn.json';
    final headers = {
      'User-Agent': 'read_zone/1.0 (joshua.pardo30@gmail.com)',
    };
    final uri = Uri.parse(url);
    final response = await http.get(uri, headers: headers);

    if (response.statusCode == 200) {
      final Map<String, dynamic> data = json.decode(response.body);
      if (data.containsKey('items') && data['items'].isNotEmpty) {
        final itemUrl = data['items'][0]['itemURL'];
        return itemUrl;
      }
    }
    return null;
  }

  Future<bool> _onWillPop() async {
    return true;
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
            if (snapshot.connectionState == ConnectionState.waiting) {
              return Center(child: CircularProgressIndicator());
            } else if (snapshot.hasError) {
              return Center(child: Text('Error: ${snapshot.error}'));
            } else if (!snapshot.hasData) {
              return Center(child: Text('No data available'));
            } else {
              final book = snapshot.data!;
              if (book.authorKey != 'Unknown Author') {
                _authorFuture = BookService().fetchAuthorByKey(book.authorKey);
              }
              return Padding(
                padding: const EdgeInsets.all(16.0),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
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
                    Text(
                      book.title,
                      style: TextStyle(
                        fontSize: 24,
                        fontWeight: FontWeight.bold,
                        color: Colors.black,
                      ),
                    ),
                    SizedBox(height: 10),
                    _authorFuture != null
                        ? FutureBuilder<Author>(
                      future: _authorFuture,
                      builder: (context, snapshot) {
                        if (snapshot.connectionState == ConnectionState.waiting) {
                          return Text(
                            'Loading...',
                            style: TextStyle(
                              fontSize: 18,
                              color: Colors.black54,
                            ),
                          );
                        } else if (snapshot.hasError) {
                          return Text(
                            'Unknown Author',
                            style: TextStyle(
                              fontSize: 18,
                              color: Colors.black54,
                            ),
                          );
                        } else if (!snapshot.hasData) {
                          return Text(
                            'Unknown Author',
                            style: TextStyle(
                              fontSize: 18,
                              color: Colors.black54,
                            ),
                          );
                        } else {
                          final author = snapshot.data!;
                          return Text(
                            'by ${author.name}',
                            style: TextStyle(
                              fontSize: 18,
                              color: Colors.black54,
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
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceAround,
                      children: [
                        ElevatedButton.icon(
                          onPressed: () async {
                            if (_isFavorite) {
                              await _userService.unfavoriteBook(widget.bookKey);
                            } else {
                              final book = await _bookFuture;
                              await _userService.saveBookToFavorites(Book(
                                key: book.key,
                                title: book.title,
                                author: book.author,
                                authorKey: book.authorKey,
                                coverUrl: book.coverUrl,
                                description: book.description,
                              ));
                            }
                            _checkIfFavorite();
                          },
                          icon: Icon(
                            _isFavorite ? Icons.favorite : Icons.favorite_border,
                            color: Colors.black,
                          ),
                          label: Text(
                            _isFavorite ? 'Remove from Favorites' : 'Save to Favorites',
                            style: TextStyle(color: Colors.black),
                          ),
                          style: ElevatedButton.styleFrom(
                            backgroundColor: AppTheme.primaryColor,
                            foregroundColor: Colors.black,
                          ),
                        ),
                        ElevatedButton.icon(
                          onPressed: _isLoading
                              ? null
                              : () {
                            _fetchEditionsAndPrint(widget.bookKey);
                          },
                          icon: _isLoading
                              ? CircularProgressIndicator(
                            color: Colors.black,
                          )
                              : Icon(Icons.book, color: Colors.black),
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