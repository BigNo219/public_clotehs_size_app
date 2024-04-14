import 'package:flutter/material.dart';
import 'package:ddundddun/category_page.dart';

class CategorySelectionPage extends StatelessWidget {
  final Map<String, List<String>> clothingCategories = {
    '상의': ['맨투맨', '반팔티', '후드티', '니트', '가디건', '코트', '셔츠', '블라우스'],
    '하의': ['바지', '롱치마', '숏치마', '멜빵바지', '레깅스', '스커트'],
    '원피스': ['롱원피스', '숏원피스', '점프수트'],
  };

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: Text('카테고리 선택')),
      body: ListView.builder(
        itemCount: clothingCategories.length,
        itemBuilder: (context, index) {
          final category = clothingCategories.keys.elementAt(index);
          final subCategories = clothingCategories[category]!;
          return Card(
            elevation: 2,
            margin: EdgeInsets.symmetric(horizontal: 16, vertical: 8),
            child: ExpansionTile(
              title: Text(
                category,
                style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
              ),
              children: subCategories.map((subCategory) {
                return ListTile(
                  title: Text(subCategory),
                  onTap: () {
                    Navigator.push(
                      context,
                      MaterialPageRoute(
                        builder: (context) => CategoryPage(category: category, subCategory: subCategory),
                      ),
                    );
                  },
                );
              }).toList(),
            ),
          );
        },
      ),
    );
  }
}