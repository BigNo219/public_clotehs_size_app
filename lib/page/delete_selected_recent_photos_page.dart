import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:cached_network_image/cached_network_image.dart';
import 'package:provider/provider.dart';
import 'package:flutter_dotenv/flutter_dotenv.dart';
import 'package:crypto/crypto.dart';
import 'dart:convert';
import 'package:http/http.dart' as http;

class DeleteSelectedRecentPhotosPageModel extends ChangeNotifier {
  List<QueryDocumentSnapshot> _imageDocs = [];
  Set<String> _selectedImageIds = {};

  List<QueryDocumentSnapshot> get imageDocs => _imageDocs;
  Set<String> get selectedImageIds => _selectedImageIds;

  Future<void> fetchImages({DocumentSnapshot? lastDocument}) async {
    Query query = FirebaseFirestore.instance
        .collection('images')
        .orderBy('timestamp', descending: true)
        .limit(15);

    if (lastDocument != null) {
      query = query.startAfterDocument(lastDocument);
    }

    final snapshot = await query.get();

    _imageDocs.addAll(snapshot.docs);
    notifyListeners();
  }

  void toggleImageSelection(String imageId) {
    if (_selectedImageIds.contains(imageId)) {
      _selectedImageIds.remove(imageId);
    } else {
      _selectedImageIds.add(imageId);
    }
    notifyListeners();
  }

  Future<void> deleteSelectedImages() async {
    final apiKey = dotenv.env['API_KEY']!;
    final apiSecret = dotenv.env['API_SECRET']!;
    final cloudName = dotenv.env['CLOUD_NAME']!;
    final cloudinaryUrl = dotenv.env['CLOUDINARY_URL']!;
    final cloudinaryEndpoint = dotenv.env['CLOUDINARY_URL_ENDPOINT']!;

    final batchSize = 10;
    final batches = _selectedImageIds.length ~/ batchSize + 1;

    for (int i = 0; i < batches; i++) {
      final start = i * batchSize;
      final end = (i + 1) * batchSize;
      final batchImageIds = _selectedImageIds.skip(start).take(batchSize).toList();

      final imageDocs = await Future.wait(
        batchImageIds.map((imageId) =>
            FirebaseFirestore.instance.collection('images').doc(imageId).get()
        ),
      );

      for (final doc in imageDocs) {
        final url = doc.data()?['url'] as String? ?? '';

        if (url.isNotEmpty) {
          final parts = url.split('/');
          final fileName = parts.last.split('.').first;
          final folderPathParts = parts.sublist(7, parts.length - 1);
          final decodedPathParts = folderPathParts.map(Uri.decodeComponent).toList();
          final publicId = decodedPathParts.join('/') + '/' + fileName;

          final timestamp = (DateTime.now().millisecondsSinceEpoch / 1000).round();

          final params = {
            'public_id': publicId,
            'timestamp': timestamp.toString(),
          };

          final paramString = params.entries
              .map((entry) => '${entry.key}=${entry.value}')
              .join('&');

          final signature = sha256.convert(utf8.encode('$paramString$apiSecret')).toString();

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
            await doc.reference.delete();
          } else {
            print('Failed to delete image from Cloudinary. Status code: ${response.statusCode}');
          }
        }
      }
    }

    _selectedImageIds.clear();
    _imageDocs.clear();
    await fetchImages();
  }

  void clearImageCache() {
    PaintingBinding.instance.imageCache.clear();
  }
}

class DeleteSelectedRecentPhotosPage extends StatefulWidget {
  @override
  _DeleteSelectedRecentPhotosPageState createState() =>
      _DeleteSelectedRecentPhotosPageState();
}

class _DeleteSelectedRecentPhotosPageState
    extends State<DeleteSelectedRecentPhotosPage> {
  late DeleteSelectedRecentPhotosPageModel _model;

  @override
  void initState() {
    super.initState();
    _model = DeleteSelectedRecentPhotosPageModel();
    _model.fetchImages();
  }

  @override
  void dispose() {
    _model.clearImageCache();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return ChangeNotifierProvider.value(
      value: _model,
      child: Scaffold(
        appBar: AppBar(
          title: const Text(
            '최신 사진 선택 삭제',
            style: TextStyle(fontFamily: 'KoreanFont', color: Colors.white),
          ),
          backgroundColor: Colors.grey,
          actions: [
            Consumer<DeleteSelectedRecentPhotosPageModel>(
              builder: (context, model, child) {
                final selectedCount = model.selectedImageIds.length;
                return TextButton(
                  onPressed: selectedCount > 0
                      ? () => _confirmDeleteSelectedImages(context, model)
                      : null,
                  child: Text(
                    '삭제 ($selectedCount)',
                    style: const TextStyle(
                        fontFamily: 'KoreanFont', color: Colors.white),
                  ),
                );
              },
            ),
          ],
        ),
        body: Consumer<DeleteSelectedRecentPhotosPageModel>(
          builder: (context, model, child) {
            final imageDocs = model.imageDocs;
            if (imageDocs.isEmpty) {
              return const Center(child: CircularProgressIndicator());
            }
            return NotificationListener<ScrollNotification>(
              onNotification: (ScrollNotification notification) {
                if (notification is ScrollEndNotification &&
                    notification.metrics.pixels ==
                        notification.metrics.maxScrollExtent) {
                  model.fetchImages(lastDocument: imageDocs.last);
                }
                return true;
              },
              child: GridView.builder(
                gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
                  crossAxisCount: 3,
                  crossAxisSpacing: 8,
                  mainAxisSpacing: 8,
                  childAspectRatio: 1,
                ),
                padding: EdgeInsets.all(8),
                itemCount: imageDocs.length,
                itemBuilder: (context, index) {
                  final imageDoc = imageDocs[index];
                  final imageUrl = imageDoc['url'];
                  final imageId = imageDoc.id;
                  final isSelected = model.selectedImageIds.contains(imageId);
                  return Stack(
                    fit: StackFit.expand,
                    children: [
                      GestureDetector(
                        onTap: () => model.toggleImageSelection(imageId),
                        child: ClipRRect(
                          borderRadius: BorderRadius.circular(10),
                          child: CachedNetworkImage(
                            imageUrl: imageUrl,
                            fit: BoxFit.cover,
                            placeholder: (context, url) => Center(
                                child: CircularProgressIndicator()),
                            errorWidget: (context, url, error) =>
                                Icon(Icons.error),
                          ),
                        ),
                      ),
                      if (isSelected)
                        Positioned.fill(
                          child: DecoratedBox(
                            decoration: BoxDecoration(
                              color: Colors.black54,
                              borderRadius: BorderRadius.circular(10),
                            ),
                            child: Icon(Icons.check, color: Colors.white),
                          ),
                        ),
                    ],
                  );
                },
              ),
            );
          },
        ),
      ),
    );
  }

  void _confirmDeleteSelectedImages(
      BuildContext context, DeleteSelectedRecentPhotosPageModel model) {
    showDialog(
      context: context,
      builder: (context) {
        return AlertDialog(
          title: Text(
            '선택한 사진 삭제',
            style:
            const TextStyle(fontFamily: 'KoreanFont', color: Colors.black),
          ),
          content: Text(
            '선택한 ${model.selectedImageIds.length}개의 사진을 삭제하시겠습니까?',
            style:
            const TextStyle(fontFamily: 'KoreanFont', color: Colors.black),
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.pop(context),
              child: Text('취소',
                  style: const TextStyle(
                      fontFamily: 'KoreanFont', color: Colors.black)),
            ),
            TextButton(
              onPressed: () {
                model.deleteSelectedImages();
                Navigator.pop(context);
              },
              child: Text('삭제',
                  style: const TextStyle(
                      fontFamily: 'KoreanFont', color: Colors.black)),
            ),
          ],
        );
      },
    );
  }
}