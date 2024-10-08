// lib/main_pages/favorite_page.dart

import 'package:flutter/material.dart';
import 'package:read_zone/theme.dart';
import 'package:read_zone/components/navbar.dart';
import '../models/book.dart';
import '../models/author.dart';
import '../services/user_service.dart';
import '../services/book_service.dart';
import 'single_page.dart';

class FavoritePage extends StatefulWidget {
  const FavoritePage({Key? key}) : super(key: key);

  @override
  _FavoritePageState createState() => _FavoritePageState();
}

class _FavoritePageState extends State<FavoritePage> {
  final UserService _userService = UserService();
  final BookService _bookService = BookService();
  List<Book> _favoriteBooks = [];
  Map<String, Author> _authors = {};
  bool _isLoading = true;

  @override
  void initState() {
    super.initState();
    _fetchFavoriteBooks();
  }

  Future<void> _fetchFavoriteBooks() async {
    final favoriteKeysWithAuthorKeys = await _userService.getFavoriteBookKeysWithAuthorKeys();
    final books = await Future.wait(favoriteKeysWithAuthorKeys.map((entry) async {
      final book = await _bookService.fetchBookByKey(entry['key']);
      final author = await _bookService.fetchAuthorByKey(entry['authorKey']);
      _authors[entry['key']] = author;
      return book;
    }));
    setState(() {
      _favoriteBooks = books;
      _isLoading = false;
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        backgroundColor: AppTheme.primaryColor,
        title: const Text(
          'Favorite Books',
          style: TextStyle(color: Colors.black),
        ),
      ),
      body: _isLoading
          ? Center(child: CircularProgressIndicator())
          : _favoriteBooks.isNotEmpty
          ? ListView.builder(
        padding: const EdgeInsets.all(16),
        itemCount: _favoriteBooks.length,
        itemBuilder: (context, index) {
          final book = _favoriteBooks[index];
          final author = _authors[book.key];
          return Card(
            color: AppTheme.accentColor,
            child: InkWell(
              onTap: () {
                Navigator.push(
                  context,
                  MaterialPageRoute(
                    builder: (context) => SinglePage(bookKey: book.key),
                  ),
                );
              },
              child: ListTile(
                leading: book.coverUrl != null
                    ? Image.network(book.coverUrl!, width: 50, height: 75, fit: BoxFit.cover)
                    : Icon(Icons.book, size: 50, color: Colors.black26),
                title: Text(
                  book.title,
                  style: const TextStyle(
                    fontSize: 18,
                    fontWeight: FontWeight.bold,
                    color: Colors.black,
                  ),
                ),
                subtitle: Text(
                  author?.name ?? 'Unknown Author',
                  style: TextStyle(
                    fontSize: 16,
                    color: Colors.grey.shade800,
                  ),
                ),
              ),
            ),
          );
        },
      )
          : const Center(
        child: Text(
          'No favorite books yet!',
          style: TextStyle(
            fontSize: 18,
            color: Colors.black54,
          ),
        ),
      ),
      bottomNavigationBar: Navbar(
        currentIndex: 1,
        onTap: (index) {
          // Handle navigation
        },
      ),
    );
  }
}