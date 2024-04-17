import 'package:flutter/material.dart';
import 'package:cloudinary_public/cloudinary_public.dart';
import 'package:ddundddun/photo_page.dart';

class CategoryPage extends StatefulWidget {
  final String category;
  final String subCategory;

  CategoryPage({required this.category, required this.subCategory});

  @override
  _CategoryPageState createState() => _CategoryPageState();
}

class _CategoryPageState extends State<CategoryPage> {
  late Future<List<String>> _imageUrlsFuture;

  @override
  void initState() {
    super.initState();
    _imageUrlsFuture = _getImageUrls();
  }

  Future<List<String>> _getImageUrls() async {
    final cloudinary = CloudinaryPublic(
        'duqykedvy',
        'flutter_clotehs_size_app',
        apiKey: '491384474792879',
        apiSecret: 'hE8xMCTm7R8q8mf0K_MrlguymiU',
        cache: false);
    final response = await cloudinary.searchResources(
      expression: 'folder:${widget.category}/${widget.subCategory}',
      maxResults: 100,
    );

    return response.resources.map((resource) => resource.secureUrl).toList();
  }

  void _openPhotoPage(String imageUrl) {
    Navigator.push(
      context,
      MaterialPageRoute(
        builder: (context) => PhotoPage(imageUrl: imageUrl),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('${widget.category} - ${widget.subCategory}'),
      ),
      body: FutureBuilder<List<String>>(
        future: _imageUrlsFuture,
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) {
            return Center(child: CircularProgressIndicator());
          } else if (snapshot.hasError) {
            return Center(child: Text('Error: ${snapshot.error}'));
          } else {
            final imageUrls = snapshot.data!;
            if (imageUrls.isEmpty) {
              return Center(child: Text('해당 카테고리에 저장된 사진이 없습니다.'));
            }
            return GridView.builder(
              gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
                crossAxisCount: 3,
                crossAxisSpacing: 8,
                mainAxisSpacing: 8,
                childAspectRatio: 1,
              ),
              padding: EdgeInsets.all(8),
              itemCount: imageUrls.length,
              itemBuilder: (context, index) {
                final imageUrl = imageUrls[index];
                return GestureDetector(
                  onTap: () => _openPhotoPage(imageUrl),
                  child : ClipRRect(
                  borderRadius: BorderRadius.circular(10),
                  child: Image.network(
                    imageUrl,
                    fit: BoxFit.cover,
                  ),
                ),
                );
              },
            );
          }
        },
      ),
    );
  }
}