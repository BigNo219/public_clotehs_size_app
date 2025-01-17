import 'package:ddundddun/functions/image_deletion_mixin.dart';
import 'package:ddundddun/widgets/delete_confirmation_dialog.dart';
import 'package:ddundddun/widgets/selectable_image_grid.dart';
import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:provider/provider.dart';

class DeleteSelectedRecentPhotosPageModel extends ChangeNotifier with ImageDeletionMixin {
  List<QueryDocumentSnapshot> _imageDocs = [];
  Set<String> _selectedImageIds = {};

  List<QueryDocumentSnapshot> get imageDocs => _imageDocs;
  Set<String> get selectedImageIds => _selectedImageIds;

  Future<void> fetchImages({DocumentSnapshot? lastDocument}) async {
    Query query = FirebaseFirestore.instance
        .collection('images')
        .orderBy('timestamp', descending: true)
        .limit(45); // 불러올 이미지 개수

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
    final batchSize = 10;
    final batches = _selectedImageIds.length ~/ batchSize + 1;

    for (int i = 0; i < batches; i++) {
      final start = i * batchSize;
      final batchImageIds = _selectedImageIds.skip(start).take(batchSize).toList();

      for (final imageId in batchImageIds) {
        final doc = _imageDocs.firstWhere((doc) => doc.id == imageId);
        final url = doc.get('url') as String;  // get() 메서드 사용
        await deleteCloudinaryImage(url, imageId);
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
  const DeleteSelectedRecentPhotosPage({super.key});

  @override
  _DeleteSelectedRecentPhotosPageState createState() => _DeleteSelectedRecentPhotosPageState();
}

class _DeleteSelectedRecentPhotosPageState extends State<DeleteSelectedRecentPhotosPage> {
  late DeleteSelectedRecentPhotosPageModel _model;
  final ScrollController _scrollController = ScrollController();

  @override
  void initState() {
    super.initState();
    _model = DeleteSelectedRecentPhotosPageModel();
    _model.fetchImages();
  }

  @override
  void dispose() {
    _model.clearImageCache();
    _scrollController.dispose();
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
                      ? () async {
                    final confirmed = await showDeleteConfirmationDialog(
                      context: context,
                      count: selectedCount,
                    );
                    if (confirmed == true) {
                      await model.deleteSelectedImages();
                    }
                  }
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
            if (model.imageDocs.isEmpty) {
              return const Center(child: CircularProgressIndicator());
            }
            return NotificationListener<ScrollNotification>(
              onNotification: (ScrollNotification notification) {
                if (notification is ScrollEndNotification &&
                    notification.metrics.pixels ==
                        notification.metrics.maxScrollExtent) {
                  model.fetchImages(lastDocument: model.imageDocs.last);
                }
                return true;
              },
              child: SelectableImageGrid(
                images: model.imageDocs,
                selectedImageIds: model.selectedImageIds,
                onSelectImage: model.toggleImageSelection,
                scrollController: _scrollController,
              ),
            );
          },
        ),
      ),
    );
  }
}