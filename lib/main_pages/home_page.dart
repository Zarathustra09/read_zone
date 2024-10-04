import 'package:flutter/material.dart';
import 'package:read_zone/services/auth_service.dart';
import 'package:read_zone/services/book_service.dart';
import '../components/navbar.dart';

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

  @override
  void initState() {
    super.initState();
    _fetchBooks();
  }

  void _fetchBooks() async {
    try {
      final books = await _bookService.fetchBooks('flutter');
      setState(() {
        _books = books;
        _isLoading = false;
      });
    } catch (e) {
      setState(() {
        _isLoading = false;
      });
      // Handle error
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
    return Column(
      children: _books.map((book) => _buildBookTile(book)).toList(),
    );
  }

  // Helper function to build a book tile for recommendations
  Widget _buildBookTile(Book book) {
    return ListTile(
      leading: SizedBox(
        width: 50,
        height: 70,
        child: book.coverUrl.isNotEmpty
            ? Image.network(book.coverUrl, fit: BoxFit.cover)
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
}