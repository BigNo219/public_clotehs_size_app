import 'dart:convert';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:ddundddun/widgets/optimized_cached_image.dart';
import 'package:flutter/material.dart';
import 'package:crypto/crypto.dart';
import 'package:http/http.dart' as http;
import 'package:cached_network_image/cached_network_image.dart';
import 'package:provider/provider.dart';
import 'package:flutter_dotenv/flutter_dotenv.dart';
import '../main.dart';

class DeleteImagesPage extends StatelessWidget {
  final String option;

  DeleteImagesPage({required this.option});

  @override
  Widget build(BuildContext context) {
    return ChangeNotifierProvider(
      create: (_) => DeleteImagesPageModel(option),
      child: Scaffold(
        appBar: AppBar(
          backgroundColor: Colors.grey,
          title: Text(
              '사진 삭제',
              style: TextStyle(
                fontFamily: 'KoreanFamily',
                color: Colors.white,
                fontWeight: FontWeight.bold,
              ),
          ),
        ),
        body: Consumer<DeleteImagesPageModel>(
          builder: (context, model, child) {
            if (model.imagesForDeletion.isEmpty) {
              return Center(child: CircularProgressIndicator());
            } else {
              return GridView.builder(
                gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
                  crossAxisCount: 3,
                  crossAxisSpacing: 8.0,
                  mainAxisSpacing: 8.0,
                ),
                itemCount: model.imagesForDeletion.length,
                itemBuilder: (context, index) {
                  final imageData =
                  model.imagesForDeletion[index].data() as Map<String, dynamic>;
                  final imageUrl = imageData['url'] as String;
                  return Stack(
                    children: [
                      OptimizedCachedImage(imageUrl: imageUrl),
                      Positioned(
                        top: 8,
                        right: 8,
                        child: GestureDetector(
                          onTap: () {
                            model.toggleImageSelection(index);
                          },
                          child: Container(
                            decoration: BoxDecoration(
                              shape: BoxShape.circle,
                              color: Colors.white,
                            ),
                            child: model.selectedImages[index]
                                ? Icon(Icons.check_circle, color: Colors.blue)
                                : Icon(Icons.radio_button_unchecked),
                          ),
                        ),
                      ),
                    ],
                  );
                },
              );
            }
          },
        ),
        floatingActionButton: Consumer<DeleteImagesPageModel>(
          builder: (context, model, child) => FloatingActionButton(
            onPressed: model.deleteImages,
            backgroundColor: Colors.black,
            child: Icon(Icons.delete, color: Colors.white),
          ),
        ),
      ),
    );
  }
}

class DeleteImagesPageModel extends ChangeNotifier {
  final String option;
  List<QueryDocumentSnapshot> imagesForDeletion = [];
  List<bool> selectedImages = [];

  DeleteImagesPageModel(this.option) {
    _fetchImagesToDelete();
  }

  Future<void> _fetchImagesToDelete() async {
    final daysAgo = int.parse(option.split('주일')[0]);
    final now = DateTime.now();
    final deleteBefore = now.subtract(Duration(days: daysAgo * 7));

    final query = FirebaseFirestore.instance
        .collection('images')
        .where('timestamp', isLessThan: deleteBefore);

    final querySnapshot = await query.get();
    imagesForDeletion = querySnapshot.docs;
    selectedImages = List<bool>.filled(imagesForDeletion.length, true);
    notifyListeners();
  }

  void toggleImageSelection(int index) {
    selectedImages[index] = !selectedImages[index];
    notifyListeners();
  }

  Future<void> deleteImages() async {
    final confirm = await showDialog(
      context: navigatorKey.currentContext!,
      builder: (context) => AlertDialog(
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

      for (int i = 0; i < imagesForDeletion.length; i++) {
        if (selectedImages[i]) {
          final imageId = imagesForDeletion[i].id;
          final imageData = imagesForDeletion[i].data() as Map<String, dynamic>?;
          final url = imageData?['url'] as String? ?? '';

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
      }

      _fetchImagesToDelete();
    }
  }
}