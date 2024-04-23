import 'package:cloud_firestore/cloud_firestore.dart';

class RefreshCountFileCategories {
  Map<String, Map<String, int>> fileCounts = {};

  Future<void> countFilesInCategories(Map<String, List<String>> clothingCategories) async {
    Map<String, Map<String, int>> tempCounts = {};

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

      tempCounts[category] = subCategoryCounts;
    }

    fileCounts = tempCounts;
  }
}