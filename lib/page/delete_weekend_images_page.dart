import 'dart:convert';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:crypto/crypto.dart';
import 'package:http/http.dart' as http;

class DeleteImagesPage extends StatefulWidget {
  final String option;

  DeleteImagesPage({required this.option});

  @override
  _DeleteImagesPageState createState() => _DeleteImagesPageState();
}

class _DeleteImagesPageState extends State<DeleteImagesPage> {
  List<QueryDocumentSnapshot> imagesForDeletion = [];
  List<bool> selectedImages = [];

  @override
  void initState() {
    super.initState();
    _fetchImagesToDelete();
  }

  Future<void> _fetchImagesToDelete() async {
    final daysAgo = int.parse(widget.option.split('주일')[0]);
    final now = DateTime.now();
    final deleteBefore = now.subtract(Duration(days: daysAgo * 7));

    final query = FirebaseFirestore.instance
        .collection('images')
        .where('timestamp', isLessThan: deleteBefore);

    final querySnapshot = await query.get();
    setState(() {
      imagesForDeletion = querySnapshot.docs;
      selectedImages = List<bool>.filled(imagesForDeletion.length, true);
    });
  }

  Future<void> _deleteImages() async {
    final confirm = await showDialog(
      context: context,
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
      final apiKey = "491384474792879";
      final apiSecret = "hE8xMCTm7R8q8mf0K_MrlguymiU";
      final cloudName = "duqykedvy";

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

            final signature = sha256
                .convert(utf8.encode('$paramString$apiSecret'))
                .toString();

            final response = await http.post(
              Uri.parse(
                  'https://api.cloudinary.com/v1_1/$cloudName/image/destroy'),
              body: {
                ...params,
                'signature': signature,
                'api_key': apiKey,
              },
              headers: {'Content-Type': 'application/x-www-form-urlencoded'},
            );

            print("Response Status Code: ${response.statusCode}");
            print("Response Body: ${response.body}");

            if (response.statusCode == 200) {
              await FirebaseFirestore.instance
                  .collection('images')
                  .doc(imageId)
                  .delete();
              print("이미지 삭제 완료. ID: $imageId");
            } else {
              print(
                  'Failed to delete image from Cloudinary. Status code: ${response.statusCode}');
            }
          } else {
            print('URL is empty for image ID: $imageId');
          }
        }
      }

      setState(() {
        _fetchImagesToDelete();
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('사진 삭제'),
      ),
      body: imagesForDeletion.isEmpty
          ? Center(child: CircularProgressIndicator())
          : GridView.builder(
        gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
          crossAxisCount: 3,
          crossAxisSpacing: 8.0,
          mainAxisSpacing: 8.0,
        ),
        itemCount: imagesForDeletion.length,
        itemBuilder: (context, index) {
          final imageData =
          imagesForDeletion[index].data() as Map<String, dynamic>;
          final imageUrl = imageData['url'] as String;
          return Stack(
            children: [
              Image.network(imageUrl, fit: BoxFit.cover),
              Positioned(
                top: 8,
                right: 8,
                child: GestureDetector(
                  onTap: () {
                    setState(() {
                      selectedImages[index] = !selectedImages[index];
                    });
                  },
                  child: Container(
                    decoration: BoxDecoration(
                      shape: BoxShape.circle,
                      color: Colors.white,
                    ),
                    child: selectedImages[index]
                        ? Icon(Icons.check_circle, color: Colors.blue)
                        : Icon(Icons.radio_button_unchecked),
                  ),
                ),
              ),
            ],
          );
        },
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: _deleteImages,
        child: Icon(Icons.delete),
      ),
    );
  }
}