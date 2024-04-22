// recent_photos_page.dart

import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:ddundddun/photo_page.dart';

class RecentPhotosPage extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: StreamBuilder<QuerySnapshot>(
        stream: FirebaseFirestore.instance
            .collection('images')
            .orderBy('timestamp', descending: true)
            .limit(10)
            .snapshots(),
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) {
            return Center(child: CircularProgressIndicator());
          } else if (snapshot.hasError) {
            return Center(child: Text('Error: ${snapshot.error}'));
          } else {
            final imageDocs = snapshot.data!.docs;
            if (imageDocs.isEmpty) {
              return Center(child: Text('최근 촬영한 사진이 없습니다.'));
            }
            return GridView.builder(
              gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
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