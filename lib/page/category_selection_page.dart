import 'package:flutter/material.dart';
import 'package:ddundddun/page/category_page.dart';
import 'package:ddundddun/functions/refresh_count_file_categories.dart';

class CategorySelectionPage extends StatefulWidget {
  final Function(String, String)? onCategorySelected;

  CategorySelectionPage({this.onCategorySelected});

  @override
  _CategorySelectionPageState createState() => _CategorySelectionPageState();

}

class _CategorySelectionPageState extends State<CategorySelectionPage> {
  final RefreshCountFileCategories _refreshCountFileCategories = RefreshCountFileCategories();

  @override
  void initState() {
    super.initState();
    _refreshCountFileCategories.countFilesInCategories(clothingCategories);
  }

  @override
  Widget build(BuildContext context) {
    return ListView.builder(
      itemCount: clothingCategories.length,
      itemBuilder: (context, index) {
        final category = clothingCategories.keys.elementAt(index);
        final subCategories = clothingCategories[category]!;
        return Card(
          color: Colors.black,
          elevation: 2,
          margin: EdgeInsets.symmetric(horizontal: 16, vertical: 8),
          child: ExpansionTile(
            title: Text(
              '$category  (${_refreshCountFileCategories.fileCounts[category]?.values.fold(0, (sum, item) => sum + item) ?? 0})',
              style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold, color: Colors.white),
            ),
            children: subCategories.map((subCategory) {
              return ListTile(
                title: Text(
                  '      - $subCategory  (${_refreshCountFileCategories.fileCounts[category]?[subCategory] ?? 0})',
                  style: TextStyle(fontSize: 14, fontWeight: FontWeight.bold, color: Colors.white),
                ),
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
                        _refreshCountFileCategories.countFilesInCategories(clothingCategories);
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
  '원피스': ['롱 원피스', '숏 원피스', '점프수트'],
};