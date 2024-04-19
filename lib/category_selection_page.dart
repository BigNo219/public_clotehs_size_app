import 'dart:io';
import 'package:flutter/material.dart';
import 'package:path_provider/path_provider.dart';
import 'package:path/path.dart' as path;
import 'package:ddundddun/category_page.dart';

class CategorySelectionPage extends StatefulWidget {
  final Function(String, String)? onCategorySelected;

  CategorySelectionPage({this.onCategorySelected});

  @override
  _CategorySelectionPageState createState() => _CategorySelectionPageState();

}

class _CategorySelectionPageState extends State<CategorySelectionPage> {
  Map<String, Map<String, int>> fileCounts = {};

  @override
  void initState() {
    super.initState();
    _countFilesInCategories();
  }

  // 카테고리별 파일 개수 세기
  Future<void> _countFilesInCategories() async {
    final appDir = await getApplicationDocumentsDirectory();
    Map<String, Map<String, int>> tempCounts = {};

    for (var category in clothingCategories.keys) {
      Map<String, int> subCategoryCounts = {};
      for (var subCategory in clothingCategories[category]!) {
        final subCategoryDir = Directory(path.join(appDir.path, category, subCategory));
        int fileCount = 0;

        if (await subCategoryDir.exists()) {
          fileCount = await subCategoryDir.list().where((item) => item is File).length;
        }

        subCategoryCounts[subCategory] = fileCount;
      }
      tempCounts[category] = subCategoryCounts;
    }

    setState(() {
      fileCounts = tempCounts;
    });
  }

  @override
  Widget build(BuildContext context) {
    return ListView.builder(
      itemCount: clothingCategories.length,
      itemBuilder: (context, index) {
        final category = clothingCategories.keys.elementAt(index);
        final subCategories = clothingCategories[category]!;
        return Card(
          elevation: 2,
          margin: EdgeInsets.symmetric(horizontal: 16, vertical: 8),
          child: ExpansionTile(
            title: Text(
              '$category (${fileCounts[category]?.values.fold(0, (sum, item) => sum + item) ?? 0} 개)',
              style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
            ),
            children: subCategories.map((subCategory) {
              return ListTile(
                title: Text('$subCategory (${fileCounts[category]?[subCategory] ?? 0} 개)'),
                onTap: () {
                  if (widget.onCategorySelected != null) {
                    widget.onCategorySelected!(category, subCategory);
                  } else {
                    Navigator.push(
                      context,
                      MaterialPageRoute(
                        builder: (context) => CategoryPage(category: category, subCategory: subCategory),
                      ),
                    ).then ((result) {
                      if (result != null && result) {
                        _countFilesInCategories();
                      }
                    });
                  }
                },
              );
            }).toList(),
          ),
        );
      },
    );
  }
}

final Map<String, List<String>> clothingCategories = {
  '상의': ['맨투맨', '반팔티', '후드티', '니트', '나시', '셔츠', '블라우스', '코트'],
  '하의': ['바지', '롱 치마', '숏 치마', '스커트'],
  '원피스': ['롱원피스', '숏원피스', '점프수트'],
};