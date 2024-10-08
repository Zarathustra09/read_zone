// lib/services/user_service.dart

import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import '../models/book.dart';

class UserService {
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;

  Future<void> saveBookToFavorites(Book book) async {
    final user = FirebaseAuth.instance.currentUser;
    if (user != null) {
      final favoritesRef = _firestore.collection('users').doc(user.uid).collection('favorites');
      final bookDocRef = favoritesRef.doc(book.key.split('/').last); // Use only the last segment of the key
      await bookDocRef.set(book.toJson());
    }
  }

  Future<List<String>> getFavoriteBookKeys() async {
    final user = FirebaseAuth.instance.currentUser;
    if (user != null) {
      final favoritesRef = _firestore.collection('users').doc(user.uid).collection('favorites');
      final snapshot = await favoritesRef.get();
      return snapshot.docs.map((doc) => '/works/${doc.id}').toList(); // Add '/works/' prefix
    }
    return [];
  }

  Future<List<Book>> getFavoriteBooks() async {
    final user = FirebaseAuth.instance.currentUser;
    if (user != null) {
      final favoritesRef = _firestore.collection('users').doc(user.uid).collection('favorites');
      final snapshot = await favoritesRef.get();
      return snapshot.docs.map((doc) => Book.fromJson(doc.data())).toList();
    }
    return [];
  }

  Future<List<Map<String, dynamic>>> getFavoriteBookKeysWithAuthorKeys() async {
    final user = FirebaseAuth.instance.currentUser;
    if (user != null) {
      final favoritesRef = _firestore.collection('users').doc(user.uid).collection('favorites');
      final snapshot = await favoritesRef.get();
      return snapshot.docs.map((doc) => {
        'key': '/works/${doc.id}', // Add '/works/' prefix
        'authorKey': doc.data()['authorKey'],
      }).toList();
    }
    return [];
  }

  Future<bool> isBookInFavorites(String bookKey) async {
    final user = FirebaseAuth.instance.currentUser;
    if (user != null) {
      final favoritesRef = _firestore.collection('users').doc(user.uid).collection('favorites');
      final bookDocRef = favoritesRef.doc(bookKey.split('/').last); // Use only the last segment of the key
      final docSnapshot = await bookDocRef.get();
      return docSnapshot.exists;
    }
    return false;
  }

  Future<void> unfavoriteBook(String bookKey) async {
    final user = FirebaseAuth.instance.currentUser;
    if (user != null) {
      final favoritesRef = _firestore.collection('users').doc(user.uid).collection('favorites');
      final bookDocRef = favoritesRef.doc(bookKey.split('/').last); // Use only the last segment of the key
      await bookDocRef.delete();
    }
  }
}