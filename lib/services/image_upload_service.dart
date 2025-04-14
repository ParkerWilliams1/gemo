import 'package:firebase_storage/firebase_storage.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:logger/logger.dart';
import 'package:flutter/services.dart' show ByteData, Uint8List, rootBundle;

class ImageUploadService {
  final FirebaseStorage _storage = FirebaseStorage.instance;
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;
  final Logger _logger = Logger(); // Initialize the Logger instance

  Future<void> uploadImages() async {
    List<String> imagePaths = [
      'assets/images/default.png',
      'assets/images/music.png',
      'assets/images/gaming.png',
      'assets/images/movies.png',
      'assets/images/sports.png',
      'assets/images/travel.png',
      'assets/images/fitness.png',
      'assets/images/fashion.png',
      'assets/images/food.png',
      'assets/images/photography.png',
      'assets/images/health.png',
      'assets/images/business.png',
      'assets/images/finance.png',
      'assets/images/electricalengineering.png',
      'assets/images/calculus.png',
      'assets/images/physics.png',
      'assets/images/chemistry.png',
      'assets/images/economics.png',
      'assets/images/psychology.png',
      'assets/images/history.png',
      'assets/images/computerscience.png',
      'assets/images/mechanicalengineering.png',
      'assets/images/civilengineering.png',
      'assets/images/chemicalengineering.png',
      'assets/images/bioengineering.png',
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

      _logger.i("Image uploaded successfully: $downloadUrl");
    } catch (e) {
      _logger.e("Error uploading image: $e");
    }
  }
}