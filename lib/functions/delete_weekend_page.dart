import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:ddundddun/page/delete_weekend_images_page.dart';

class DeleteSelectionPage extends StatefulWidget {
  @override
  _DeleteSelectionPageState createState() => _DeleteSelectionPageState();
}

class _DeleteSelectionPageState extends State<DeleteSelectionPage> {
  final List<String> deletionOptions = [
    '1주일된 사진들 삭제',
    '2주일된 사진들 삭제',
    '3주일된 사진들 삭제',
    '4주일된 사진들 삭제',
  ];

  List<QueryDocumentSnapshot> imagesForDeletion = [];

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: Text('사진 삭제')),
      body: ListView.builder(
        itemCount: deletionOptions.length,
        itemBuilder: (context, index) {
          final option = deletionOptions[index];
          return ListTile(
            title: Text(option),
            onTap: () {
              Navigator.push(
                context,
                MaterialPageRoute(
                  builder: (context) => DeleteImagesPage(option: option),
                ),
              );
            },
          );
        },
      ),
    );
  }
}