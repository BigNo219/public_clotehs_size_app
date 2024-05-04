import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';

class RefreshCountFileCategories extends ChangeNotifier {
  Map<String, Map<String, int>> _fileCounts = {};

  Map<String, Map<String, int>> get fileCounts => _fileCounts;

  Future<void> countFilesInCategories(Map<String, List<String>> clothingCategories) async {
    _fileCounts = {};

    for (var category in clothingCategories.keys) {
      Map<String, int> subCategoryCounts = {};
      final categoryQuery = FirebaseFirestore.instance
          .collection('images')
          .where('category', isEqualTo: category);

      for (var subCategory in clothingCategories[category]!) {
        final subcategoryQuery = categoryQuery.where('subCategory', isEqualTo: subCategory);
        final subcategorySnapshots = await subcategoryQuery.get();
        subCategoryCounts[subCategory] = subcategorySnapshots.docs.length;
      }

      _fileCounts[category] = subCategoryCounts;
    }

    notifyListeners(); // UI 업데이트를 알립니다.
  }
}