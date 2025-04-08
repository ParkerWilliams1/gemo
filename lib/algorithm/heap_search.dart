import 'dart:async';
import 'package:logging/logging.dart';
import 'package:cloud_firestore/cloud_firestore.dart';

class Category {
  String name;
  int clicks;

  Category(this.name, this.clicks);
}

// Firestore Query to Fetch Data
Future<List<Category>> fetchCategories() async {
  QuerySnapshot snapshot =
      await FirebaseFirestore.instance.collection('categories').get();

  List<Category> categories = snapshot.docs.map((doc) {
    return Category(doc['name'], doc['clicks']);
  }).toList();

  return categories;
}

// Heap Sort Implementation
void heapify(List<Category> arr, int n, int i) {
  int largest = i;
  int left = 2 * i + 1;
  int right = 2 * i + 2;

  if (left < n && arr[left].clicks > arr[largest].clicks) {
    largest = left;
  }

  if (right < n && arr[right].clicks > arr[largest].clicks) {
    largest = right;
  }

  if (largest != i) {
    Category temp = arr[i];
    arr[i] = arr[largest];
    arr[largest] = temp;

    heapify(arr, n, largest);
  }
}

void heapSort(List<Category> arr) {
  int n = arr.length;

  for (int i = (n ~/ 2) - 1; i >= 0; i--) {
    heapify(arr, n, i);
  }

  for (int i = n - 1; i > 0; i--) {
    Category temp = arr[0];
    arr[0] = arr[i];
    arr[i] = temp;

    heapify(arr, i, 0);
  }
}

// Update Firestore with Click Count
Future<void> updateCategoryClicks(String categoryName, int newClicks) async {
  try {
    await FirebaseFirestore.instance
        .collection('categories')
        .doc(categoryName) // Assuming the document ID is the category name
        .update({'clicks': newClicks});
  } catch (e) {
    Logger('Error updating clicks for $categoryName: $e');
  }
}

// Usage Example
void main() async {
  List<Category> categories = await fetchCategories();
  heapSort(categories);

  for (var category in categories) {
    Logger('${category.name}: ${category.clicks} clicks');
    // Simulate a click and update Firestore
    category.clicks += 1; // Increment clicks
    await updateCategoryClicks(category.name, category.clicks);
  }
}


