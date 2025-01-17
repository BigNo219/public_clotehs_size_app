import 'package:ddundddun/page/delete/delete_selected_old_photo_page.dart';
import 'package:ddundddun/page/delete/delete_weekend_images_page.dart';
import 'package:flutter/material.dart';
import 'delete_selected_recent_photos_page.dart';

class DeleteSelectionPage extends StatefulWidget {
  const DeleteSelectionPage({super.key});

  @override
  _DeleteSelectionPageState createState() => _DeleteSelectionPageState();
}

class _DeleteSelectionPageState extends State<DeleteSelectionPage> {
  final List<Map<String, dynamic>> deletionOptions = [
    {
      'title': '최근 사진 선택 삭제',
      'type': 'recent'
    },
    {
      'title': '오래된 순 사진 선택 삭제',
      'type': 'old'
    },
    {
      'title': '1주일 이상된 사진들 선택 삭제',
      'type': 'week',
      'period': 1
    },
    {
      'title': '2주일 이상된 사진들 선택 삭제',
      'type': 'week',
      'period': 2
    },
    {
      'title': '3주일 이상된 사진들 선택 삭제',
      'type': 'week',
      'period': 3
    },
    {
      'title': '4주일 이상된 사진들 선택 삭제',
      'type': 'week',
      'period': 4
    },
  ];

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
        itemCount: deletionOptions.length + 2, // 구분선 2개를 위해 +2
        itemBuilder: (context, index) {
          // 첫 번째 구분선 (최근/오래된 순 구분)
          if (index == 3) {
            return const Divider(
              color: Colors.grey,
              height: 5,
              thickness: 5,
            );
          }

          // 두 번째 구분선 (주별 삭제 구분)
          if (index == 0) {
            return const SizedBox.shrink();
          }

          final optionIndex = index > 2 ? index - 1 : index;
          final option = deletionOptions[optionIndex - 1];

          return ListTile(
            title: Text(
              option['title'],
              style: const TextStyle(
                color: Colors.black,
                fontWeight: FontWeight.bold,
                fontFamily: 'KoreanFamily',
              ),
            ),
            onTap: () {
              switch (option['type']) {
                case 'recent':
                  Navigator.push(
                    context,
                    MaterialPageRoute(
                      builder: (context) => DeleteSelectedRecentPhotosPage(),
                    ),
                  );
                  break;
                case 'old':
                  Navigator.push(
                    context,
                    MaterialPageRoute(
                      builder: (context) => DeleteSelectedOldPhotosPage(),
                    ),
                  );
                  break;
                case 'week':
                  Navigator.push(
                    context,
                    MaterialPageRoute(
                      builder: (context) => DeleteImagesPage(option: '${option['period']}주일'),
                    ),
                  );
                  break;
              }
            },
          );
        },
      ),
    );
  }
}