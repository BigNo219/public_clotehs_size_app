import 'package:flutter/material.dart';
import 'package:ddundddun/page/category_page.dart';
import 'package:ddundddun/functions/refresh_count_file_categories.dart';
import 'package:provider/provider.dart';

class CategorySelectionPage extends StatefulWidget {
  final Function(String, String)? onCategorySelected;

  const CategorySelectionPage({super.key, this.onCategorySelected});

  @override
  _CategorySelectionPageState createState() => _CategorySelectionPageState();
}

class _CategorySelectionPageState extends State<CategorySelectionPage> {
  final RefreshCountFileCategories _refreshCountFileCategories =
      RefreshCountFileCategories();

  String? selectedCategory;

  @override
  void initState() {
    super.initState();
    _refreshCountFileCategories.countFilesInCategories(clothingCategories);
  }

  @override
  Widget build(BuildContext context) {
    return ChangeNotifierProvider.value(
      value: _refreshCountFileCategories,
      child: Row(
        children: [
          Expanded(
            flex: 1,
            child: Consumer<RefreshCountFileCategories>(
              builder: (context, refreshCountFileCategories, child) {
                return ListView.builder(
                  itemCount: clothingCategories.length,
                  itemBuilder: (context, index) {
                    final category = clothingCategories.keys.elementAt(index);
                    return ListTile(
                      title: Text(
                        '$category (${refreshCountFileCategories.fileCounts[category]?.values.reduce((a, b) => a + b) ?? 0})',
                        style: selectedCategory == category
                            ? const TextStyle(
                                fontFamily: 'KoreanFont',
                                fontSize: 14,
                                fontWeight: FontWeight.bold,
                                color: Colors.black)
                            : const TextStyle(
                                fontFamily: 'KoreanFont',
                                fontSize: 14,
                                fontWeight: FontWeight.bold,
                                color: Colors.white),
                      ),
                      onTap: () {
                        setState(() {
                          selectedCategory = category;
                        });
                      },
                      tileColor: selectedCategory == category
                          ? Colors.white
                          : Colors.black,
                    );
                  },
                );
              },
            ),
          ),
          Expanded(
            flex: 2,
            child: selectedCategory != null
                ? ListView.builder(
                    itemCount: clothingCategories[selectedCategory]!.length,
                    itemBuilder: (context, index) {
                      final subCategory =
                          clothingCategories[selectedCategory]![index];
                      return ListTile(
                        title: Text(
                          '$subCategory  (${_refreshCountFileCategories.fileCounts[selectedCategory]?[subCategory] ?? 0})',
                          style: selectedCategory == subCategory
                              ? TextStyle(fontFamily: 'KoreanFont',fontSize: 16, color: Colors.black)
                              : TextStyle(fontFamily: 'KoreanFont',fontSize: 16, color: Colors.white),
                        ),
                        onTap: () {
                          if (widget.onCategorySelected != null) {
                            widget.onCategorySelected!(
                                selectedCategory!, subCategory);
                          } else {
                            Navigator.push(
                              context,
                              MaterialPageRoute(
                                builder: (context) => CategoryPage(
                                    category: selectedCategory!,
                                    subCategory: subCategory),
                              ),
                            ).then((result) {
                              if (result != null && result) {
                                _refreshCountFileCategories
                                    .countFilesInCategories(clothingCategories);
                              }
                            });
                          }
                        },
                        tileColor: selectedCategory == subCategory
                            ? Colors.grey
                            : Colors.black87,
                      );
                    },
                  )
                : Container(),
          ),
        ],
      ),
    );
  }
}

final Map<String, List<String>> clothingCategories = {
  '아우터': ['가디건', '자켓/코트(숏)', '자켓/코트(롱)', '점퍼', '베스트(패딩조끼)'],
  '상의': ['티셔츠(긴소매)', '티셔츠(반소매)', '티셔츠(목폴라)', '민소매(조끼)', '블라우스(셔츠)'],
  '원피스': ['긴팔원피스', '반팔원피스', '민소매원피스', '목폴라원피스'],
  '패션소품': ['가방', '신발'],
  '팬츠': ['긴바지', '반바지', '점프수트'],
  '스커트': ['미니스커트', '롱스커트'],
};
