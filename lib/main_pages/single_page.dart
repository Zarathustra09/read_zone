import 'package:flutter/material.dart';
import 'package:read_zone/theme.dart';

class BookPage extends StatelessWidget {
  final String title;
  final String author;
  final String imagePath;
  final String description;

  BookPage({
    required this.title,
    required this.author,
    required this.imagePath,
    required this.description,
  });

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(
          'Book Details',
          style: TextStyle(color: Colors.black), // Black text
        ),
        backgroundColor: AppTheme.primaryColor,
        iconTheme: IconThemeData(color: Colors.black),
        elevation: 0,
      ),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Book cover
            Center(
              child: Container(
                width: 150,
                height: 230,
                decoration: BoxDecoration(
                  borderRadius: BorderRadius.circular(12),
                  boxShadow: [
                    BoxShadow(
                      color: Colors.black12,
                      blurRadius: 6,
                      offset: Offset(0, 2),
                    ),
                  ],
                ),
                child: ClipRRect(
                  borderRadius: BorderRadius.circular(12),
                  child: Image.asset(imagePath, fit: BoxFit.cover),
                ),
              ),
            ),
            SizedBox(height: 20),

            // Book Title
            Text(
              title,
              style: TextStyle(
                fontSize: 24,
                fontWeight: FontWeight.bold,
                color: Colors.black,
              ),
            ),
            SizedBox(height: 10),

            // Book Author
            Text(
              'by $author',
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
                  description,
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
                  label: Text('Save to Favorites', style: TextStyle(color: Colors.black)),
                  style: ElevatedButton.styleFrom(
                    backgroundColor: AppTheme.primaryColor,
                    foregroundColor: Colors.black,
                  ),
                ),
                ElevatedButton.icon(
                  onPressed: () {
                    // Navigate to the reading page
                  },
                  icon: Icon(Icons.book, color: Colors.black),
                  label: Text('Read Now', style: TextStyle(color: Colors.black)),
                  style: ElevatedButton.styleFrom(
                    backgroundColor: AppTheme.secondaryColor,
                    foregroundColor: Colors.black,
                  ),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }
}
