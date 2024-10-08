import 'package:flutter/material.dart';
import 'package:read_zone/main_pages/single_page.dart';
import 'package:read_zone/theme.dart'; // Import your theme
import 'package:read_zone/components/navbar.dart'; // Import your Navbar
import 'package:read_zone/services/book_service.dart'; // Import your BookService
import 'package:read_zone/models/book.dart'; // Import your Book model

class SearchPage extends StatefulWidget {
  const SearchPage({Key? key}) : super(key: key);

  @override
  _SearchPageState createState() => _SearchPageState();
}

class _SearchPageState extends State<SearchPage> {
  TextEditingController _searchController = TextEditingController();
  List<Book> searchResults = []; // Placeholder for search results
  bool isLoading = false; // Loading state
  int _currentPage = 1;
  final int _limit = 5;

  void _performSearch(String query) async {
    setState(() {
      isLoading = true; // Show loading indicator
    });

    try {
      searchResults = await fetchSearchResults(query, limit: _limit, offset: (_currentPage - 1) * _limit);
    } catch (e) {
      // Handle error
    } finally {
      setState(() {
        isLoading = false; // Hide loading indicator
      });
    }
  }

  void _nextPage() {
    setState(() {
      _currentPage++;
    });
    _performSearch(_searchController.text);
  }

  void _previousPage() {
    if (_currentPage > 1) {
      setState(() {
        _currentPage--;
      });
      _performSearch(_searchController.text);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        backgroundColor: AppTheme.primaryColor,
        title: const Text(
          'Search Books',
          style: TextStyle(color: Colors.black), // Use black for title contrast
        ),
      ),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          children: [
            TextField(
              controller: _searchController,
              decoration: InputDecoration(
                labelText: 'Search',
                prefixIcon: Icon(Icons.search),
              ),
              onSubmitted: _performSearch,
            ),
            const SizedBox(height: 16),
            isLoading
                ? Center(child: CircularProgressIndicator())
                : Expanded(
              child: ListView.builder(
                itemCount: searchResults.length,
                itemBuilder: (context, index) {
                  final book = searchResults[index];
                  return Card(
                    color: AppTheme.accentColor,
                    child: ListTile(
                      leading: SizedBox(
                        width: 50,
                        height: 70,
                        child: book.coverUrl != null
                            ? Image.network(book.coverUrl!, fit: BoxFit.cover)
                            : Container(color: Colors.grey),
                      ),
                      title: Text(
                        book.title,
                        style: const TextStyle(
                          fontSize: 18,
                          fontWeight: FontWeight.bold,
                          color: Colors.black,
                        ),
                      ),
                      subtitle: Text(
                        book.author,
                        style: TextStyle(color: Colors.black54),
                      ),
                      onTap: () {
                        print('Book Key: ${book.key}');
                        Navigator.push(
                          context,
                          MaterialPageRoute(
                            builder: (context) => SinglePage(bookKey: book.key),
                          ),
                        );
                      },
                    ),
                  );
                },
              ),
            ),
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                ElevatedButton(
                  onPressed: _previousPage,
                  child: Text('Previous'),
                ),
                ElevatedButton(
                  onPressed: _nextPage,
                  child: Text('Next'),
                ),
              ],
            ),
          ],
        ),
      ),
      bottomNavigationBar: Navbar(
        currentIndex: 0, // Set the index to 0 for Search
        onTap: (index) {
          // Handle navigation
        },
      ),
    );
  }
}