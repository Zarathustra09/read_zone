// lib/main_pages/author_works.dart

import 'package:flutter/material.dart';
import 'package:read_zone/main_pages/single_page.dart';
import 'package:read_zone/theme.dart';
import 'package:read_zone/components/navbar.dart';
import '../services/book_service.dart';

class AuthorWorksPage extends StatefulWidget {
  final String authorKey;

  AuthorWorksPage({required this.authorKey});

  @override
  _AuthorWorksPageState createState() => _AuthorWorksPageState();
}

class _AuthorWorksPageState extends State<AuthorWorksPage> {
  late Future<List<Book>> _authorWorksFuture;
  late Future<Author> _authorFuture;
  int _selectedIndex = 2; // Set Home as the initial selected index

  @override
  void initState() {
    super.initState();
    _authorWorksFuture = BookService().fetchAuthorWorks(widget.authorKey);
    _authorFuture = BookService().fetchAuthorByKey(widget.authorKey);
  }

  void _onItemTapped(int index) {
    setState(() {
      _selectedIndex = index;
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: FutureBuilder<Author>(
          future: _authorFuture,
          builder: (context, snapshot) {
            if (snapshot.connectionState == ConnectionState.waiting) {
              return Text('Loading...');
            } else if (snapshot.hasError) {
              return Text('Error');
            } else if (!snapshot.hasData) {
              return Text('Unknown Author');
            } else {
              final author = snapshot.data!;
              return Text(
                '${author.name}\'s Works',
                style: TextStyle(color: Colors.black),
              );
            }
          },
        ),
        backgroundColor: AppTheme.primaryColor,
        iconTheme: IconThemeData(color: Colors.black),
        elevation: 0,
      ),
      body: FutureBuilder<List<Book>>(
        future: _authorWorksFuture,
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) {
            return Center(child: CircularProgressIndicator());
          } else if (snapshot.hasError) {
            return Center(child: Text('Error: ${snapshot.error}'));
          } else if (!snapshot.hasData || snapshot.data!.isEmpty) {
            return Center(child: Text('No works available'));
          } else {
            final books = snapshot.data!;
            return ListView.builder(
              itemCount: books.length,
              itemBuilder: (context, index) {
                return _buildBookCard(context, books[index]);
              },
            );
          }
        },
      ),
      bottomNavigationBar: Navbar(
        currentIndex: _selectedIndex,
        onTap: _onItemTapped,
      ),
    );
  }

  Widget _buildBookCard(BuildContext context, Book book) {
    return GestureDetector(
      onTap: () {
        Navigator.push(
          context,
          MaterialPageRoute(
            builder: (context) => SinglePage(bookKey: book.key),
          ),
        );
      },
      child: Card(
        elevation: 5,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Book cover
            Container(
              height: 150,
              decoration: BoxDecoration(
                color: Colors.grey[300],
                borderRadius: BorderRadius.circular(12),
                image: book.coverUrl != null
                    ? DecorationImage(
                  image: NetworkImage(book.coverUrl!),
                  fit: BoxFit.cover,
                )
                    : null,
              ),
            ),
            SizedBox(height: 10),

            // Book title
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 8.0),
              child: Text(
                book.title,
                style: TextStyle(
                  fontSize: 16,
                  fontWeight: FontWeight.bold,
                  color: Colors.black,
                ),
                maxLines: 2,
                overflow: TextOverflow.ellipsis,
              ),
            ),
            SizedBox(height: 5),

            // Author name
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 8.0),
              child: FutureBuilder<Author>(
                future: _authorFuture,
                builder: (context, snapshot) {
                  if (snapshot.connectionState == ConnectionState.waiting) {
                    return Text(
                      'Loading...',
                      style: TextStyle(
                        fontSize: 14,
                        color: Colors.black54,
                      ),
                    );
                  } else if (snapshot.hasError) {
                    return Text(
                      'Unknown Author',
                      style: TextStyle(
                        fontSize: 14,
                        color: Colors.black54,
                      ),
                    );
                  } else if (!snapshot.hasData) {
                    return Text(
                      'Unknown Author',
                      style: TextStyle(
                        fontSize: 14,
                        color: Colors.black54,
                      ),
                    );
                  } else {
                    final author = snapshot.data!;
                    return Text(
                      author.name,
                      style: TextStyle(
                        fontSize: 14,
                        color: Colors.black54,
                      ),
                    );
                  }
                },
              ),
            ),
          ],
        ),
      ),
    );
  }
}