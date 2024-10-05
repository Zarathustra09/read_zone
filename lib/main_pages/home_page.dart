import 'package:flutter/material.dart';
import 'package:read_zone/services/auth_service.dart';
import 'package:read_zone/services/book_service.dart';
import '../components/navbar.dart';
import 'dart:typed_data';

class HomePage extends StatefulWidget {
  @override
  _HomePageState createState() => _HomePageState();
}

class _HomePageState extends State<HomePage> {
  final AuthService _authService = AuthService();
  final BookService _bookService = BookService();
  int _selectedIndex = 2; // Set Home as the initial selected index
  List<Book> _books = [];
  bool _isLoading = true;
  int _currentPage = 1;
  final int _limit = 5; // Change from 10 to 5

  @override
  void initState() {
    super.initState();
    _fetchBooks();
  }

  void _fetchBooks([String query = 'Psychology']) async {
    setState(() {
      _isLoading = true;
    });
    try {
      final books = await _bookService.fetchBooks(query, limit: _limit, page: _currentPage);
      if (mounted) {
        setState(() {
          _books = books;
          _isLoading = false;
        });
      }
    } catch (e) {
      if (mounted) {
        setState(() {
          _isLoading = false;
        });
      }
      // Handle error
    }
  }

  void _nextPage() {
    setState(() {
      _currentPage++;
    });
    _fetchBooks();
  }

  void _previousPage() {
    if (_currentPage > 1) {
      setState(() {
        _currentPage--;
      });
      _fetchBooks();
    }
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
        title: Text(
          'Read Zone Library',
          style: TextStyle(color: Colors.black),
        ),
        backgroundColor: Color(0xFFE0FBE2),
        elevation: 0,
        actions: [
          IconButton(
            icon: Icon(Icons.logout, color: Colors.black),
            onPressed: () {
              _authService.signout(context);
            },
          ),
        ],
      ),
      body: _isLoading
          ? Center(child: CircularProgressIndicator())
          : SingleChildScrollView(
        child: Padding(
          padding: const EdgeInsets.all(16.0),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // Search Bar
              TextField(
                decoration: InputDecoration(
                  hintText: 'Search books, authors...',
                  prefixIcon: Icon(Icons.search, color: Colors.black),
                  filled: true,
                  fillColor: Color(0xFFBFF6C3),
                  border: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(12),
                    borderSide: BorderSide.none,
                  ),
                ),
              ),
              SizedBox(height: 20),

              // Popular Categories
              Text(
                'Popular Categories',
                style: TextStyle(
                  fontSize: 18,
                  fontWeight: FontWeight.bold,
                  color: Colors.black,
                ),
              ),
              SizedBox(height: 10),
              SingleChildScrollView(
                scrollDirection: Axis.horizontal,
                child: Row(
                  children: [
                    _buildCategoryCard('Fiction', Icons.book),
                    _buildCategoryCard('Science', Icons.science),
                    _buildCategoryCard('History', Icons.history),
                    _buildCategoryCard('Biography', Icons.person),
                  ],
                ),
              ),
              SizedBox(height: 30),

              // Recommended Section
              Text(
                'Recommended for You',
                style: TextStyle(
                  fontSize: 18,
                  fontWeight: FontWeight.bold,
                  color: Colors.black,
                ),
              ),
              SizedBox(height: 10),
              _buildBookRecommendations(),

              // Pagination Buttons
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  ElevatedButton(
                    onPressed: _previousPage,
                    child: Text('<'),
                  ),
                  ElevatedButton(
                    onPressed: _nextPage,
                    child: Text('>'),
                  ),
                ],
              ),
            ],
          ),
        ),
      ),
      bottomNavigationBar: Navbar(
        currentIndex: _selectedIndex,
        onTap: _onItemTapped,
      ),
    );
  }

  // Helper function to build the category card
  Widget _buildCategoryCard(String title, IconData icon) {
    return Card(
      color: Color(0xFFBFF6C3),
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
      child: Container(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          children: [
            Icon(icon, size: 40, color: Colors.black),
            SizedBox(height: 10),
            Text(title, style: TextStyle(color: Colors.black)),
          ],
        ),
      ),
    );
  }

  // Helper function to build the book recommendations section
  Widget _buildBookRecommendations() {
    return ListView.builder(
      shrinkWrap: true,
      physics: NeverScrollableScrollPhysics(),
      itemCount: _books.length,
      itemBuilder: (context, index) {
        return _buildBookTile(_books[index]);
      },
    );
  }

  // Helper function to build a book tile for recommendations
  Widget _buildBookTile(Book book) {
    return ListTile(
      leading: SizedBox(
        width: 50,
        height: 70,
        child: book.cover != null
            ? FutureBuilder<Widget>(
          future: _loadImage(book.cover!),
          builder: (context, snapshot) {
            if (snapshot.connectionState == ConnectionState.waiting) {
              return Center(child: CircularProgressIndicator());
            } else if (snapshot.hasError) {
              return Container(color: Colors.grey);
            } else {
              return snapshot.data!;
            }
          },
        )
            : Container(color: Colors.grey),
      ),
      title: Text(book.title, style: TextStyle(color: Colors.black)),
      subtitle: Text(book.author, style: TextStyle(color: Colors.black54)),
      trailing: Icon(Icons.arrow_forward, color: Colors.black),
      onTap: () {
        // Navigate to book details or action
      },
    );
  }

  Future<Widget> _loadImage(Uint8List imageData) async {
    return Image.memory(imageData, fit: BoxFit.cover);
  }
}