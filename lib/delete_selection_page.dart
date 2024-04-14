import 'dart:io';
import 'package:flutter/material.dart';
import 'package:path_provider/path_provider.dart';
import 'package:path/path.dart' as path;

class DeleteSelectionPage extends StatelessWidget {
  final List<String> deletionOptions = [
    '1주일된 사진들 삭제',
    '2주일된 사진들 삭제',
    '3주일된 사진들 삭제',
    '4주일된 사진들 삭제',
  ];

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
              _showConfirmationDialog(context, option);
            },
          );
        },
      ),
    );
  }

  void _showConfirmationDialog(BuildContext context, String option) {
    showDialog(
      context: context,
      builder: (context) {
        return AlertDialog(
          title: Text('사진 삭제'),
          content: Text('$option 하시겠습니까?'),
          actions: [
            TextButton(
              onPressed: () {
                Navigator.pop(context);
              },
              child: Text('취소'),
            ),
            TextButton(
              onPressed: () {
                Navigator.pop(context);
                _deletePhotos(context, option);
              },
              child: Text('삭제'),
            ),
          ],
        );
      },
    );
  }

  Future<void> _deletePhotos(BuildContext context, String option) async {
    final appDir = await getApplicationDocumentsDirectory();
    final photoDir = Directory(appDir.path);

    final now = DateTime.now();
    final deleteBefore = _getDaysAgo(option);

    try {
      await for (var entity in photoDir.list(recursive: true)) {
        if (entity is File && path.extension(entity.path) == '.jpg') {
          final fileStat = await entity.stat();
          final modifiedTime = fileStat.modified;

          if (modifiedTime.isBefore(deleteBefore)) {
            await entity.delete();
          }
        }
      }

      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('사진 삭제 완료')),
      );
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('사진 삭제 중 오류 발생: $e')),
      );
    }
  }

  DateTime _getDaysAgo(String option) {
    final now = DateTime.now();
    final daysAgo = int.parse(option.split('주일')[0]);
    return now.subtract(Duration(days: daysAgo * 7));
  }
}