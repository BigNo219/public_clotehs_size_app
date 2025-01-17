import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:provider/provider.dart';

import '../../functions/image_deletion_mixin.dart';
import '../../widgets/delete_confirmation_dialog.dart';
import '../../widgets/selectable_image_grid.dart';

class DeleteImagesPage extends StatelessWidget {
  final String option;

  const DeleteImagesPage({super.key, required this.option});

  @override
  Widget build(BuildContext context) {
    return ChangeNotifierProvider(
      create: (_) => DeleteImagesPageModel(option),
      child: Scaffold(
        appBar: AppBar(
          backgroundColor: Colors.grey,
          title: Text(
            '${option} 이상된 사진 삭제',
            style: TextStyle(
              fontFamily: 'KoreanFamily',
              color: Colors.white,
              fontWeight: FontWeight.bold,
            ),
          ),
          actions: [
            Consumer<DeleteImagesPageModel>(
              builder: (context, model, child) {
                final selectedCount = model.selectedImages.where((selected) => selected).length;
                return TextButton(
                  onPressed: selectedCount > 0
                      ? () async {
                    final confirmed = await showDeleteConfirmationDialog(
                      context: context,
                      count: selectedCount,
                    );
                    if (confirmed == true) {
                      model.deleteImages();
                    }
                  }
                      : null,
                  child: Text(
                    '삭제 ($selectedCount)',
                    style: const TextStyle(
                      fontFamily: 'KoreanFont',
                      color: Colors.white,
                    ),
                  ),
                );
              },
            ),
          ],
        ),
        body: Consumer<DeleteImagesPageModel>(
          builder: (context, model, child) {
            if (model.imagesForDeletion.isEmpty) {
              return const Center(child: CircularProgressIndicator());
            }
            return SelectableImageGrid(
              images: model.imagesForDeletion,
              selectedImages: model.selectedImages,
              onSelectImageByIndex: model.toggleImageSelection,
              initiallySelected: true,
            );
          },
        ),
      ),
    );
  }
}

class DeleteImagesPageModel extends ChangeNotifier with ImageDeletionMixin {
  final String option;
  List<QueryDocumentSnapshot> _imagesForDeletion = [];
  List<bool> _selectedImages = [];

  List<QueryDocumentSnapshot> get imagesForDeletion => _imagesForDeletion;
  List<bool> get selectedImages => _selectedImages;

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
    _imagesForDeletion = querySnapshot.docs;
    _selectedImages = List<bool>.filled(_imagesForDeletion.length, true);
    notifyListeners();
  }

  void toggleImageSelection(int index) {
    _selectedImages[index] = !_selectedImages[index];
    notifyListeners();
  }

  Future<void> deleteImages() async {
    for (int i = 0; i < _imagesForDeletion.length; i++) {
      if (_selectedImages[i]) {
        final doc = _imagesForDeletion[i];
        final url = doc.get('url') as String;  // get() 메서드 사용
        await deleteCloudinaryImage(url, doc.id);
      }
    }
    await _fetchImagesToDelete();
  }
}