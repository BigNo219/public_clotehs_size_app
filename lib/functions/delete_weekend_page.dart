import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:ddundddun/page/delete_weekend_images_page.dart';
import '../page/delete_selected_recent_photos_page.dart';

class DeleteSelectionPage extends StatefulWidget {
  @override
  _DeleteSelectionPageState createState() => _DeleteSelectionPageState();
}

class _DeleteSelectionPageState extends State<DeleteSelectionPage> {
  final List<String> deletionOptions = [
    '최근 사진 선택 삭제',
    '1주일 이상된 사진들 삭제',
    '2주일 이상된 사진들 삭제',
    '3주일 이상된 사진들 삭제',
    '4주일 이상된 사진들 삭제',
  ];

  List<QueryDocumentSnapshot> imagesForDeletion = [];

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text(
          'Photos to Delete',
          style: TextStyle(
            color: Colors.white,
            fontWeight: FontWeight.bold,
          ),
        ),
        backgroundColor: Colors.grey,
      ),
      body: ListView.builder(
        itemCount: deletionOptions.length + 1, // +1 은 구분선을 위한 추가 항목
        itemBuilder: (context, index) {
          if (index == 1) {
            return const Divider(
              color: Colors.grey,
              height: 5,
              thickness: 5,
            );
          }

          final optionIndex = index > 1 ? index - 1 : index;
          final option = deletionOptions[optionIndex];

          return ListTile(
            title: Text(
                option,
                style: const TextStyle(
                  color: Colors.black,
                  fontWeight: FontWeight.bold,
                ),
            ),
            onTap: () {
              if (option == '최근 사진 선택 삭제') {
                Navigator.push(
                  context,
                  MaterialPageRoute(
                    builder: (context) => DeleteSelectedRecentPhotosPage(),
                  ),
                );
              } else {
                Navigator.push(
                  context,
                  MaterialPageRoute(
                    builder: (context) => DeleteImagesPage(option: option),
                  ),
                );
              }
            },
          );
        },
      ),
    );
  }
}
