// recent_photos_page.dart

import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:ddundddun/page/photo_page.dart';
import 'package:provider/provider.dart';
import 'package:cached_network_image/cached_network_image.dart';

class RecentPhotosPageModel extends ChangeNotifier {
  List<QueryDocumentSnapshot> _imageDocs = [];

  List<QueryDocumentSnapshot> get imageDocs => _imageDocs;

  Future<void> fetchImages() async {
    final snapshot = await FirebaseFirestore.instance
        .collection('images')
        .orderBy('timestamp', descending: true)
        .limit(20) // 사진 가져오는 갯수
        .get();

    _imageDocs = snapshot.docs;
    notifyListeners();
  }
}

class RecentPhotosPage extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return ChangeNotifierProvider(
      create: (_) => RecentPhotosPageModel()..fetchImages(),
      child: Scaffold(
        body: Consumer<RecentPhotosPageModel>(
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
                final subCategory = imageDoc['subCategory'];
                return GestureDetector(
                  onTap: () => _openPhotoPage(context, imageUrl, subCategory, imageId),
                  child: ClipRRect(
                    borderRadius: BorderRadius.circular(10),
                    child: CachedNetworkImage(
                      imageUrl: imageUrl,
                      fit: BoxFit.cover,
                      placeholder: (context, url) => const Center(child: CircularProgressIndicator()),
                      errorWidget: (context, url, error) => const Icon(Icons.error),
                    ),
                  ),
                );
              },
            );
          },
        ),
      ),
    );
  }

  void _openPhotoPage(BuildContext context, String? imageUrl, String? subCategory, String? imageId) {
    if (imageUrl != null && subCategory != null && imageId != null) {
      Navigator.push(
        context,
        MaterialPageRoute(
          builder: (context) => PhotoPage(imageUrl: imageUrl, category: subCategory, imageId: imageId),
        ),
      );
    } else {
      print('Invalid arguments passed to PhotoPage');
    }
  }
}