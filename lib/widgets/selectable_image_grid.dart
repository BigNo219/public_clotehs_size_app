import 'package:flutter/material.dart';
import 'package:ddundddun/widgets/optimized_cached_image.dart';
import 'package:cloud_firestore/cloud_firestore.dart';

class SelectableImageGrid extends StatelessWidget {
  final List<QueryDocumentSnapshot> images;
  final Set<String>? selectedImageIds;
  final List<bool>? selectedImages;
  final Function(String)? onSelectImage;
  final Function(int)? onSelectImageByIndex;
  final bool initiallySelected;
  final ScrollController? scrollController;

  const SelectableImageGrid({
    super.key,
    required this.images,
    this.selectedImageIds,
    this.selectedImages,
    this.onSelectImage,
    this.onSelectImageByIndex,
    this.initiallySelected = false,
    this.scrollController,
  });

  @override
  Widget build(BuildContext context) {
    return GridView.builder(
      controller: scrollController,
      gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
        crossAxisCount: 3,
        crossAxisSpacing: 8,
        mainAxisSpacing: 8,
        childAspectRatio: 1,
      ),
      padding: const EdgeInsets.all(8),
      itemCount: images.length,
      itemBuilder: (context, index) {
        final imageDoc = images[index];
        // get() 메서드를 사용하여 안전하게 데이터 접근
        final imageUrl = imageDoc.get('url') as String;
        final imageId = imageDoc.id;

        bool isSelected = false;
        if (selectedImageIds != null) {
          isSelected = selectedImageIds!.contains(imageId);
        } else if (selectedImages != null) {
          isSelected = selectedImages![index];
        } else {
          isSelected = initiallySelected;
        }

        return Stack(
          fit: StackFit.expand,
          children: [
            GestureDetector(
              onTap: () {
                if (onSelectImageByIndex != null) {
                  onSelectImageByIndex!(index);
                } else {
                  onSelectImage!(imageId);
                }
              },
              child: OptimizedCachedImage(imageUrl: imageUrl),
            ),
            Positioned(
              top: 8,
              right: 8,
              child: Container(
                decoration: BoxDecoration(
                  shape: BoxShape.circle,
                  color: Colors.white,
                ),
                child: isSelected
                    ? Icon(Icons.check_circle, color: Colors.blue)
                    : Icon(Icons.radio_button_unchecked),
              ),
            ),
          ],
        );
      },
    );
  }
}