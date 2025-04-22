import 'package:firebase_storage/firebase_storage.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:logging/logging.dart';
import 'package:flutter/services.dart' show ByteData, Uint8List, rootBundle;

class ImageUploadService {
  final FirebaseStorage _storage = FirebaseStorage.instance;
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;

  Future<void> uploadImages() async {
    List<String> imagePaths = [
      'lib/images/images/default.png',
      'lib/images/images/music.png',
      'lib/images/images/gaming.png',
      'lib/images/images/movies.png',
      'lib/images/images/sports.png',
      'lib/images/images/travel.png',
      'lib/images/images/fitness.png',
      'lib/images/images/fashion.png',
      'lib/images/images/food.png',
      'lib/images/images/photography.png',
      'lib/images/images/health.png',
      'lib/images/images/business.png',
      'lib/images/images/finance.png',
      'lib/images/images/electricalengineering.png',
      'lib/images/images/calculus.png',
      'lib/images/images/physics.png',
      'lib/images/images/chemistry.png',
      'lib/images/images/economics.png',
      'lib/images/images/psychology.png',
      'lib/images/images/history.png',
      'lib/images/images/computerscience.png',
      'lib/images/images/mechanicalengineering.png',
      'lib/images/images/civilengineering.png',
      'lib/images/images/chemicalengineering.png',
      'lib/images/images/bioengineering.png',
    ];

    for (String imagePath in imagePaths) {
      await uploadImage('categories', imagePath);
    }
  }

  Future<void> uploadImage(String collectionName, String imagePath) async {
    try {
      // Load the image as bytes
      ByteData byteData = await rootBundle.load(imagePath);
      Uint8List imageData = byteData.buffer.asUint8List();

      // Create a reference in Firebase Storage
      String fileName = imagePath.split('/').last;
      Reference storageRef = _storage.ref().child('images/$fileName');

      // Upload the image
      UploadTask uploadTask = storageRef.putData(imageData);
      TaskSnapshot snapshot = await uploadTask;

      // Get the download URL
      String downloadUrl = await snapshot.ref.getDownloadURL();

      // Save the download URL to Firestore
      await _firestore.collection(collectionName).add({
        'imageUrl': downloadUrl,
        'uploadedAt': FieldValue.serverTimestamp(),
      });

      Logger("Image uploaded successfully: $downloadUrl");
    } catch (e) {
      Logger("Error uploading image: $e");
    }
  }
}