import 'dart:io';

import 'package:firebase_storage/firebase_storage.dart';

class StorageService {
  final FirebaseStorage _storage = FirebaseStorage.instance;

  Future<String> uploadImage({
    required String folder,
    required String userId,
    required File imageFile,
  }) async {
    final fileName = '${DateTime.now().millisecondsSinceEpoch}.jpg';

    final reference = _storage
        .ref()
        .child(folder)
        .child(userId)
        .child(fileName);

    await reference.putFile(imageFile);

    return await reference.getDownloadURL();
  }

  Future<void> deleteImage(String imageUrl) async {
    if (imageUrl.isEmpty) {
      return;
    }

    try {
      final reference = _storage.refFromURL(imageUrl);

      await reference.delete();
    } catch (_) {
      // Image may already have been deleted.
    }
  }
}
