import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';

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
    try {
      for (int i = 0; i < imagesForDeletion.length; i++) {
        if (selectedImages[i]) {
          await imagesForDeletion[i].reference.delete();
        }
      }

      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('사진 삭제 완료')),
      );

      Navigator.pop(context);
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('사진 삭제 중 오류 발생: $e')),
      );
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
          final imageData = imagesForDeletion[index].data() as Map<String, dynamic>;
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