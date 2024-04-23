import 'package:flutter/material.dart';
import 'package:cloudinary_public/cloudinary_public.dart';
import 'package:ddundddun/page/photo_page.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:http/http.dart' as http;
import 'dart:convert';
import 'package:crypto/crypto.dart';



class CategoryPage extends StatefulWidget {
  final String category;
  final String subCategory;

  CategoryPage({required this.category, required this.subCategory});

  @override
  _CategoryPageState createState() => _CategoryPageState();
}

class _CategoryPageState extends State<CategoryPage> {
  late Future<List<String>> _imageUrlsFuture;
  bool _isSelectionMode = false;
  final Set<String> _selectedImageIds = {};

  @override
  void initState() {
    super.initState();
    _imageUrlsFuture = _getImageUrls();
  }

  Future<List<String>> _getImageUrls() async {
    final cloudinary = CloudinaryPublic(
        'duqykedvy',
        'flutter_clotehs_size_app',
        apiKey: '491384474792879',
        apiSecret: 'hE8xMCTm7R8q8mf0K_MrlguymiU',
        cache: false);
    final response = await cloudinary.searchResources(
      expression: 'folder:${widget.category}/${widget.subCategory}',
      maxResults: 100,
    );

    return response.resources.map((resource) => resource.secureUrl).toList();
  }

  void _openPhotoPage(String imageUrl, String category, String imageId) {
    Navigator.push(
      context,
      MaterialPageRoute(
        builder: (context) => PhotoPage(imageUrl: imageUrl, category: category, imageId: imageId),
      ),
    );
  }

  Future<List<Map<String, dynamic>>> _getImageDataList(String category, String subCategory) async {
    final querySnapshot = await FirebaseFirestore.instance
      .collection('images')
      .where('category', isEqualTo: category)
      .where('subCategory', isEqualTo: subCategory)
      .get();

    return querySnapshot.docs.map((doc) => {
      'id': doc.id,
      'url': doc.data()['url'],
      'category': doc.data()['category'],
      'subCategory': doc.data()['subCategory'],
    }).toList().cast<Map<String, dynamic>>();
  }

  void _toggleSelectionMode() {
    setState(() {
      _isSelectionMode = !_isSelectionMode;
      _selectedImageIds.clear();
    });
  }

  void _selectImage(String imageId) {
    setState(() {
      if(_selectedImageIds.contains(imageId)) {
        _selectedImageIds.remove(imageId);
      } else {
        _selectedImageIds.add(imageId);
      }
    });
  }

  Future<void> _deleteImages() async {
    final confirm = await showDialog(
      context: context,
      builder: (context) =>
          AlertDialog(
            title: Text('이미지 삭제'),
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

      for (final imageId in _selectedImageIds) {
        final doc = await FirebaseFirestore.instance.collection('images').doc(imageId).get();
        final data = doc.data();
        String url = data?['url'] ?? '';

        if (url.isNotEmpty) {
          final parts = url.split('/');
          final fileName = parts.last.split('.').first;  // Assuming the file extension and other parameters are correctly stripped
          final folderPathParts = parts.sublist(7, parts.length - 1);
          final encodedFileName = Uri.encodeComponent(fileName);
          final encodedPublicId = folderPathParts.join('/') + '/' + encodedFileName;
          final decodedPathParts = folderPathParts.map(Uri.decodeComponent).toList();
          final realPublicId = decodedPathParts.join('/') + '/' + fileName;

          print ('decodePathParts : $decodedPathParts');
          print ('realPublicId : $realPublicId');
          final timestamp = (DateTime.now().millisecondsSinceEpoch / 1000).round();

          final params = {
            'public_id': realPublicId,
            'timestamp': timestamp.toString(),
          };

          final sortedParams = Map.fromEntries(params.entries.toList()..sort((a, b) => a.key.compareTo(b.key)));
          final paramString = sortedParams.entries
              .map((entry) => '${entry.key}=${entry.value}')
              .join('&');

          final signatureString = '$paramString$apiSecret';
          print('signatureString : $signatureString');

          final signature = sha256.convert(utf8.encode(signatureString)).toString();
          print('signature : $signature');

          final deleteUrl = 'https://api.cloudinary.com/v1_1/$cloudName/image/destroy';

          final response = await http.post(
            Uri.parse(deleteUrl),
            body: {
              'public_id': realPublicId,
              'signature': signature,
              'api_key': apiKey,
              'timestamp': params['timestamp'],
            },
            headers: {
              'Content-Type': 'application/x-www-form-urlencoded'
            },
          );

          print("Response Status Code: ${response.statusCode}");
          print("Response Body: ${response.body}");

          if (response.statusCode == 200) {
            await FirebaseFirestore.instance.collection('images').doc(imageId).delete();
            print("이미지 삭제 완료. ID: $imageId");
          } else {
            print('Failed to delete image from Cloudinary., Status code: ${response.statusCode}');
          }
        } else {
          print('URL is empty for image ID: $imageId');
        }
      }

      setState(() {
        _selectedImageIds.clear();
        _isSelectionMode = false;
      });
    }
  }
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('${widget.category} - ${widget.subCategory}'),
        actions: [
          IconButton(
            icon: Icon(Icons.delete, color: Colors.black),
            onPressed: _isSelectionMode ? _deleteImages : _toggleSelectionMode,
          ),
        ],
      ),
      body: FutureBuilder<List<Map<String, dynamic>>>(
        future: _getImageDataList(widget.category, widget.subCategory),
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) {
            return Center(child: CircularProgressIndicator());
          } else if (snapshot.hasError) {
            return Center(child: Text('Error: ${snapshot.error}'));
          } else {
            final imageDataList = snapshot.data!;
            if (imageDataList.isEmpty) {
              return Center(child: Text('해당 카테고리에 저장된 사진이 없습니다.'));
            }
            return GridView.builder(
              gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
                crossAxisCount: 3,
                crossAxisSpacing: 8,
                mainAxisSpacing: 8,
                childAspectRatio: 1,
              ),
              padding: EdgeInsets.all(8),
              itemCount: imageDataList.length,
              itemBuilder: (context, index) {
                final imageData = imageDataList[index];
                final imageUrl = imageData['url'];
                final imageId = imageData['id'];
                final category = imageData['subCategory'];
                final isSelected = _selectedImageIds.contains(imageId);
                return GestureDetector(
                  onTap: _isSelectionMode
                    ? () => _selectImage(imageId)
                    : () => _openPhotoPage(imageUrl, category, imageId),
                  child : Stack(
                    children: [
                      ClipRRect(
                        borderRadius: BorderRadius.circular(10),
                        child: Image.network(
                          imageUrl,
                          fit: BoxFit.cover,
                        ),
                      ),
                      if(_isSelectionMode)
                        Positioned(
                          top: 5,
                          right: 5,
                          child: Icon(
                            isSelected ? Icons.check_circle : Icons.radio_button_unchecked,
                            color: isSelected ? Colors.green : Colors.white,
                          ),
                        ),
                    ],
                  ),
                );
              },
            );
          }
        },
      ),
    );
  }
}