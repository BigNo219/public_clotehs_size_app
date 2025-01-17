import 'package:ddundddun/widgets/optimized_cached_image.dart';
import 'package:flutter/material.dart';
import 'package:ddundddun/page/photo_page.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:http/http.dart' as http;
import 'dart:convert';
import 'package:crypto/crypto.dart';
import 'package:provider/provider.dart';
import 'package:flutter_dotenv/flutter_dotenv.dart';
import '../main.dart';

class CategoryPage extends StatelessWidget {
  final String category;
  final String subCategory;

  const CategoryPage(
      {super.key, required this.category, required this.subCategory});

  @override
  Widget build(BuildContext context) {
    return ChangeNotifierProvider(
      create: (_) => CategoryPageModel(category, subCategory),
      child: Scaffold(
        appBar: AppBar(
          backgroundColor: Colors.grey,
          title: Text('$category - $subCategory',
              style: const TextStyle(
                  fontFamily: 'KoreanFamily',
                  fontSize: 20,
                  fontWeight: FontWeight.bold,
                  color: Colors.white)),
          actions: [
            Consumer<CategoryPageModel>(
              builder: (context, model, child) => IconButton(
                icon: const Icon(Icons.delete, color: Colors.white),
                onPressed: model.isSelectionMode
                    ? model.deleteImages
                    : model.toggleSelectionMode,
              ),
            ),
          ],
        ),
        body: Column(
          children: [
            _buildFilterCheckboxes(),
            Expanded(
              child: Consumer<CategoryPageModel>(
                builder: (context, model, child) {
                  if (model.isLoading && model.imageDataList.isEmpty) {
                    return const Center(child: CircularProgressIndicator());
                  } else if (model.hasError) {
                    return Center(child: Text('Error: ${model.errorMessage}'));
                  } else {
                    final imageDataList = model.imageDataList;
                    if (imageDataList.isEmpty) {
                      return Center(
                          child: const Text('해당 카테고리에 저장된 사진이 없습니다.',
                              style:
                                  const TextStyle(fontFamily: 'KoreanFamily')));
                    }
                    return NotificationListener<ScrollNotification>(
                      onNotification: (ScrollNotification scrollInfo) {
                        if (!model.isLoading &&
                            scrollInfo.metrics.pixels ==
                                scrollInfo.metrics.maxScrollExtent) {
                          model.loadImageData();
                        }
                        return true;
                      },
                      child: GridView.builder(
                        gridDelegate:
                            const SliverGridDelegateWithFixedCrossAxisCount(
                          crossAxisCount: 3,
                          crossAxisSpacing: 1,
                          mainAxisSpacing: 1,
                        ),
                        padding: EdgeInsets.all(10),
                        itemCount: imageDataList.length + 1,
                        itemBuilder: (context, index) {
                          if (index < imageDataList.length) {
                            final imageData = imageDataList[index];
                            final imageUrl = imageData['url'];
                            final imageId = imageData['id'];
                            final category = imageData['subCategory'];
                            final isSelected = model.isImageSelected(imageId);
                            return GestureDetector(
                              onTap: model.isSelectionMode
                                  ? () => model.selectImage(imageId)
                                  : () => _openPhotoPage(
                                      context, imageUrl, category, imageId),
                              child: Stack(
                                children: [
                                  OptimizedCachedImage(imageUrl: imageUrl),
                                  if (model.isSelectionMode)
                                    Positioned(
                                      top: 5,
                                      right: 5,
                                      child: Icon(
                                        isSelected
                                            ? Icons.check_circle
                                            : Icons.radio_button_unchecked,
                                        color: isSelected
                                            ? Colors.green
                                            : Colors.white,
                                      ),
                                    ),
                                ],
                              ),
                            );
                          } else if (model.isLoading) {
                            return Center(child: CircularProgressIndicator());
                          } else {
                            return SizedBox.shrink();
                          }
                        },
                      ),
                    );
                  }
                },
              ),
            ),
          ],
        ),
      ),
    );
  }

  void _openPhotoPage(
      BuildContext context, String imageUrl, String category, String imageId) {
    Navigator.push(
      context,
      MaterialPageRoute(
        builder: (context) =>
            PhotoPage(imageUrl: imageUrl, category: category, imageId: imageId),
      ),
    );
  }

  Widget _buildFilterCheckboxes() {
    return Consumer<CategoryPageModel>(
      builder: (context, model, child) {
        return Container(
          height: 40,
          color: Colors.grey[200],
          padding: EdgeInsets.all(3.0),
          child: Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              _buildFilterCheckbox('UNBUTTY', model),
              _buildFilterCheckbox('MYUARIN', model),
              _buildFilterCheckbox('NONBETTER', model),
            ],
          ),
        );
      },
    );
  }

  Widget _buildFilterCheckbox(String label, CategoryPageModel model) {
    return Row(
      children: [
        Checkbox(
          value: model.selectedFilters.contains(label),
          onChanged: (value) => model.toggleFilter(label),
        ),
        Text(label,
            style: const TextStyle(
              fontSize: 10,
            )),
      ],
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

  // 필터링을 위한 변수
  List<String> selectedFilters = [];

  CategoryPageModel(this.category, this.subCategory) {
    loadImageData();
  }

  // 최신 필터 + 스크롤 시 추가 데이터 로드
  Timestamp? _lastTimestamp;
  String? _lastDocumentId;
  Map<String, Map<String, dynamic>> _imageDataMap = {};

  Future<void> loadImageData() async {
    try {
      final newImageDataList = await _getImageDataList(category, subCategory);
      newImageDataList.forEach((imageData) {
        _imageDataMap[imageData['id']] = imageData;
      });
      imageDataList = _imageDataMap.values.toList();
      isLoading = false;
      notifyListeners();
    } catch (error) {
      isLoading = false;
      hasError = true;
      errorMessage = error.toString();
      notifyListeners();
    }
  }

  Future<List<Map<String, dynamic>>> _getImageDataList(
      String category, String subCategory) async {
    Query query = FirebaseFirestore.instance
        .collection('images')
        .where('category', isEqualTo: category)
        .where('subCategory', isEqualTo: subCategory)
        .orderBy('timestamp', descending: true);

    if (selectedFilters.isNotEmpty) {
      query = query.where('shoppingMalls', arrayContainsAny: selectedFilters);
    }

    if (_lastTimestamp != null && _lastDocumentId != null) {
      final lastDocumentSnapshot = await FirebaseFirestore.instance
          .collection('images')
          .doc(_lastDocumentId)
          .get();

      query = query.startAfterDocument(lastDocumentSnapshot);
    }

    query = query.limit(15);

    final querySnapshot = await query.get();

    if (querySnapshot.docs.isNotEmpty) {
      _lastTimestamp = querySnapshot.docs.last['timestamp'] as Timestamp?;
      _lastDocumentId = querySnapshot.docs.last.id;
    }

    print('Last timestamp: $_lastTimestamp');
    print('Last document ID: $_lastDocumentId');
    print('Number of documents: ${querySnapshot.docs.length}');

    final imageDataList = querySnapshot.docs
        .map((doc) => {
              'id': doc.id,
              'url': (doc.data() as Map<String, dynamic>?)?['url'],
              'category': (doc.data() as Map<String, dynamic>?)?['category'],
              'subCategory':
                  (doc.data() as Map<String, dynamic>?)?['subCategory'],
              'timestamp': (doc.data() as Map<String, dynamic>?)?['timestamp'],
            })
        .toList()
        .cast<Map<String, dynamic>>();

    return imageDataList;
  }

  void toggleFilter(String filter) {
    if (selectedFilters.contains(filter)) {
      selectedFilters.remove(filter);
    } else {
      selectedFilters.add(filter);
    }
    _imageDataMap.clear();
    imageDataList.clear();
    _lastTimestamp = null;
    _lastDocumentId = null;
    loadImageData();
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
      builder: (context) => AlertDialog(
        title:
            Text('사진 삭제', style: const TextStyle(fontFamily: 'KoreanFamily')),
        content: Text('선택한 이미지를 삭제하시겠습니까?',
            style: const TextStyle(fontFamily: 'KoreanFamily')),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(context).pop(false),
            child:
                Text('취소', style: const TextStyle(fontFamily: 'KoreanFamily')),
          ),
          TextButton(
            onPressed: () => Navigator.of(context).pop(true),
            child:
                Text('삭제', style: const TextStyle(fontFamily: 'KoreanFamily')),
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
          final fileName = parts.last.split('.').first;
          final folderPathParts = parts.sublist(7, parts.length - 1);
          final decodedPathParts =
              folderPathParts.map(Uri.decodeComponent).toList();
          final publicId = decodedPathParts.join('/') + '/' + fileName;

          final timestamp =
              (DateTime.now().millisecondsSinceEpoch / 1000).round();

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
                'Failed to delete image from Cloudinary. Status code: ${response.statusCode}');
          }
        }
      }

      selectedImageIds.clear();
      isSelectionMode = false;
      await loadImageData();
    }
  }
}
