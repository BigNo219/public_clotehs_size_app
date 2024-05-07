import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:cached_network_image/cached_network_image.dart';
import 'package:provider/provider.dart';

class DeleteSelectedRecentPhotosPageModel extends ChangeNotifier {
  List<QueryDocumentSnapshot> _imageDocs = [];
  Set<String> _selectedImageIds = {};

  List<QueryDocumentSnapshot> get imageDocs => _imageDocs;
  Set<String> get selectedImageIds => _selectedImageIds;

  Future<void> fetchImages() async {
    final snapshot = await FirebaseFirestore.instance
        .collection('images')
        .orderBy('timestamp', descending: true)
        .limit(10)
        .get();

    _imageDocs = snapshot.docs;
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
    for (final imageId in _selectedImageIds) {
      await FirebaseFirestore.instance.collection('images').doc(imageId).delete();
    }
    _selectedImageIds.clear();
    fetchImages();
  }
}

class DeleteSelectedRecentPhotosPage extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return ChangeNotifierProvider(
      create: (_) => DeleteSelectedRecentPhotosPageModel()..fetchImages(),
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
                  onPressed: selectedCount > 0 ? () => _confirmDeleteSelectedImages(context, model) : null,
                  child: Text('삭제 ($selectedCount)', style: const TextStyle(fontFamily: 'KoreanFont', color: Colors.white)),
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
            return GridView.builder(
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
                return GestureDetector(
                  onTap: () => model.toggleImageSelection(imageId),
                  child: Stack(
                    fit: StackFit.expand,
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
                      if (isSelected)
                        Positioned.fill(
                          child: Container(
                            color: Colors.black54,
                            child: Icon(Icons.check, color: Colors.white),
                          ),
                        ),
                    ],
                  ),
                );
              },
            );
          },
        ),
      ),
    );
  }

  void _confirmDeleteSelectedImages(BuildContext context, DeleteSelectedRecentPhotosPageModel model) {
    showDialog(
      context: context,
      builder: (context) {
        return AlertDialog(
          title: Text('선택한 사진 삭제',
              style: const TextStyle(fontFamily: 'KoreanFont', color: Colors.black)),
          content: Text('선택한 ${model.selectedImageIds.length}개의 사진을 삭제하시겠습니까?',
              style: const TextStyle(fontFamily: 'KoreanFont', color: Colors.black)),
          actions: [
            TextButton(
              onPressed: () => Navigator.pop(context),
              child: Text('취소', style: const TextStyle(fontFamily: 'KoreanFont', color: Colors.black)),
            ),
            TextButton(
              onPressed: () {
                model.deleteSelectedImages();
                Navigator.pop(context);
              },
              child: Text('삭제', style: const TextStyle(fontFamily: 'KoreanFont', color: Colors.black)),
            ),
          ],
        );
      },
    );
  }
}