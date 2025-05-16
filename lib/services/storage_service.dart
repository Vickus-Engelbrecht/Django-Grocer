import 'package:firebase_storage/firebase_storage.dart';
import 'dart:io';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:django_grocer/models/user_model.dart';
import 'package:cloud_firestore/cloud_firestore.dart';

class StorageService {
  final FirebaseStorage _storage = FirebaseStorage.instance;

  final FirebaseFirestore _db = FirebaseFirestore.instance; // ✅ Correct

  Future<String> uploadDriverDocument({
    required String userId,
    required File file,
    required String documentType,
  }) async {
    try {
      final ref = _storage.ref().child(
        'driver_documents/$userId/${documentType}_${DateTime.now().millisecondsSinceEpoch}.jpg',
      );

      await ref.putFile(file);
      return await ref.getDownloadURL();
    } catch (e) {
      throw Exception('Failed to upload document: $e');
    }
  }

  Future<void> deleteFile(String url) async {
    try {
      await _storage.refFromURL(url).delete();
    } catch (e) {
      throw Exception('Failed to delete file: $e');
    }
  }

  Stream<AppUser?> getUserStream(String uid) {
    return _db.collection('users').doc(uid).snapshots().map((snapshot) {
      if (snapshot.exists) {
        return AppUser.fromMap(snapshot.data()!, snapshot.id);
      } else {
        return null;
      }
    });
  }
}

final storageServiceProvider = Provider<StorageService>((ref) {
  return StorageService();
});
