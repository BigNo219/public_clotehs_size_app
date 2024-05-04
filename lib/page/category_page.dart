import 'package:flutter/material.dart';
import 'package:ddundddun/page/photo_page.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:http/http.dart' as http;
import 'dart:convert';
import 'package:crypto/crypto.dart';
import 'package:cached_network_image/cached_network_image.dart';
import 'package:provider/provider.dart';
import 'package:flutter_dotenv/flutter_dotenv.dart';
import '../main.dart';

class CategoryPage extends StatelessWidget {
  final String category;
  final String subCategory;

  CategoryPage({required this.category, required this.subCategory});

  @override
  Widget build(BuildContext context) {
    return ChangeNotifierProvider(
      create: (_) => CategoryPageModel(category, subCategory),
      child: Scaffold(
        appBar: AppBar(
          title: Text('$category - $subCategory'),
          actions: [
            Consumer<CategoryPageModel>(
              builder: (context, model, child) => IconButton(
                icon: Icon(Icons.delete, color: Colors.black),
                onPressed: model.isSelectionMode ? model.deleteImages : model.toggleSelectionMode,
              ),
            ),
          ],
        ),
        body: Consumer<CategoryPageModel>(
          builder: (context, model, child) {
            if (model.isLoading) {
              return Center(child: CircularProgressIndicator());
            } else if (model.hasError) {
              return Center(child: Text('Error: ${model.errorMessage}'));
            } else {
              final imageDataList = model.imageDataList;
              if (imageDataList.isEmpty) {
                return Center(child: Text('해당 카테고리에 저장된 사진이 없습니다.'));
              }
              return GridView.builder(
                gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
                  crossAxisCount: 3,
                  crossAxisSpacing: 1,
                  mainAxisSpacing: 1,
                ),
                padding: EdgeInsets.all(10),
                itemCount: imageDataList.length,
                itemBuilder: (context, index) {
                  final imageData = imageDataList[index];
                  final imageUrl = imageData['url'];
                  final imageId = imageData['id'];
                  final category = imageData['subCategory'];
                  final isSelected = model.isImageSelected(imageId);
                  return GestureDetector(
                    onTap: model.isSelectionMode
                        ? () => model.selectImage(imageId)
                        : () => _openPhotoPage(context, imageUrl, category, imageId),
                    child: Stack(
                      children: [
                        ClipRRect(
                          borderRadius: BorderRadius.circular(10),
                          child: CachedNetworkImage(
                            imageUrl: imageUrl,
                            fit: BoxFit.cover,
                            placeholder: (context, url) => Center(child: CircularProgressIndicator()),
                            errorWidget: (context, url, error) => Icon(Icons.error),
                          ),
                        ),
                        if (model.isSelectionMode)
                          Positioned(
                            top: 5,
                            right: 5,
                            child: Icon(
                              isSelected ? Icons.check_circle : Icons.radio_button_unchecked,
                              color: isSelected ? Colors.green : Colors.white,
                            ),
                          ),
                      ],
                    ),
                  );
                },
              );
            }
          },
        ),
      ),
    );
  }


  void _openPhotoPage(BuildContext context, String imageUrl, String category,
      String imageId) {
    Navigator.push(
      context,
      MaterialPageRoute(
        builder: (context) =>
            PhotoPage(imageUrl: imageUrl, category: category, imageId: imageId),
      ),
    );
  }
}

class CategoryPageModel extends ChangeNotifier {
  final String category;
  final String subCategory;
  bool isLoading = true;
  bool hasError = false;
  String errorMessage = '';
  List<Map<String, dynamic>> imageDataList = [];
  bool isSelectionMode = false;
  final Set<String> selectedImageIds = {};

  CategoryPageModel(this.category, this.subCategory) {
    loadImageData();
  }

  Future<void> loadImageData() async {
    try {
      imageDataList = await _getImageDataList(category, subCategory);
      isLoading = false;
      notifyListeners();
    } catch (error) {
      isLoading = false;
      hasError = true;
      errorMessage = error.toString();
      notifyListeners();
    }
  }

  Future<List<Map<String, dynamic>>> _getImageDataList(String category,
      String subCategory) async {
    final querySnapshot = await FirebaseFirestore.instance
        .collection('images')
        .where('category', isEqualTo: category)
        .where('subCategory', isEqualTo: subCategory)
        .get();

    return querySnapshot.docs
        .map((doc) =>
    {
      'id': doc.id,
      'url': doc.data()['url'],
      'category': doc.data()['category'],
      'subCategory': doc.data()['subCategory'],
    })
        .toList()
        .cast<Map<String, dynamic>>();
  }

  void toggleSelectionMode() {
    isSelectionMode = !isSelectionMode;
    selectedImageIds.clear();
    notifyListeners();
  }

  void selectImage(String imageId) {
    if (selectedImageIds.contains(imageId)) {
      selectedImageIds.remove(imageId);
    } else {
      selectedImageIds.add(imageId);
    }
    notifyListeners();
  }

  bool isImageSelected(String imageId) {
    return selectedImageIds.contains(imageId);
  }

  Future<void> deleteImages() async {
    final confirm = await showDialog(
      context: navigatorKey.currentContext!,
      builder: (context) =>
          AlertDialog(
            title: Text('사진 삭제'),
            content: Text('선택한 이미지를 삭제하시겠습니까?'),
            actions: [
              TextButton(
                onPressed: () => Navigator.of(context).pop(false),
                child: Text('취소'),
              ),
              TextButton(
                onPressed: () => Navigator.of(context).pop(true),
                child: Text('삭제'),
              ),
            ],
          ),
    );

    if (confirm == true) {
      final apiKey = dotenv.env['API_KEY']!;
      final apiSecret = dotenv.env['API_SECRET']!;
      final cloudName = dotenv.env['CLOUD_NAME']!;
      final cloudinaryUrl = dotenv.env['CLOUDINARY_URL']!;
      final cloudinaryEndpoint = dotenv.env['CLOUDINARY_URL_ENDPOINT']!;

      for (final imageId in selectedImageIds) {
        final doc = await FirebaseFirestore.instance
            .collection('images')
            .doc(imageId)
            .get();
        final url = doc.data()?['url'] as String? ?? '';

        if (url.isNotEmpty) {
          final parts = url.split('/');
          final fileName = parts.last
              .split('.')
              .first;
          final folderPathParts = parts.sublist(7, parts.length - 1);
          final decodedPathParts =
          folderPathParts.map(Uri.decodeComponent).toList();
          final publicId = decodedPathParts.join('/') + '/' + fileName;

          final timestamp =
          (DateTime
              .now()
              .millisecondsSinceEpoch / 1000).round();

          final params = {
            'public_id': publicId,
            'timestamp': timestamp.toString(),
          };

          final paramString = params.entries
              .map((entry) => '${entry.key}=${entry.value}')
              .join('&');

          final signature =
          sha256.convert(utf8.encode('$paramString$apiSecret')).toString();

          final response = await http.post(
            Uri.parse('$cloudinaryUrl$cloudName$cloudinaryEndpoint'),
            body: {
              ...params,
              'signature': signature,
              'api_key': apiKey,
            },
            headers: {'Content-Type': 'application/x-www-form-urlencoded'},
          );

          if (response.statusCode == 200) {
            await FirebaseFirestore.instance
                .collection('images')
                .doc(imageId)
                .delete();
          } else {
            print(
                'Failed to delete image from Cloudinary. Status code: ${response
                    .statusCode}');
          }
        }
      }

      selectedImageIds.clear();
      isSelectionMode = false;
      await loadImageData();
    }
  }
}
