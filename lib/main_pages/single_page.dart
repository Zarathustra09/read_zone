import 'package:flutter/material.dart';
import 'package:read_zone/components/navbar.dart';
import 'package:read_zone/theme.dart';
import '../services/book_service.dart';

class SinglePage extends StatefulWidget {
  final String bookKey;

  const SinglePage({Key? key, required this.bookKey}) : super(key: key);

  @override
  _SinglePageState createState() => _SinglePageState();
}

class _SinglePageState extends State<SinglePage> {
  late Future<Book> _bookFuture;

  @override
  void initState() {
    super.initState();
    print('Fetching book with key: ${widget.bookKey}');
    _bookFuture = BookService().fetchBookByKey(widget.bookKey);
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
        body: FutureBuilder<Book>(
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
                    Text(
                      'by ${book.author}',
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
                            // Navigate to the reading page logic
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