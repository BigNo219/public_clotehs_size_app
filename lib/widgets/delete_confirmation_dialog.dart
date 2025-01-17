import 'package:flutter/material.dart';

Future<bool?> showDeleteConfirmationDialog({
  required BuildContext context,
  required int count,
}) {
  return showDialog<bool>(
    context: context,
    builder: (context) => AlertDialog(
      title: Text(
        '선택한 사진 삭제',
        style: const TextStyle(fontFamily: 'KoreanFont', color: Colors.black),
      ),
      content: Text(
        '선택한 ${count}개의 사진을 삭제하시겠습니까?',
        style: const TextStyle(fontFamily: 'KoreanFont', color: Colors.black),
      ),
      actions: [
        TextButton(
          onPressed: () => Navigator.pop(context, false),
          child: Text('취소',
              style: const TextStyle(
                  fontFamily: 'KoreanFont', color: Colors.black)),
        ),
        TextButton(
          onPressed: () => Navigator.pop(context, true),
          child: Text('삭제',
              style: const TextStyle(
                  fontFamily: 'KoreanFont', color: Colors.black)),
        ),
      ],
    ),
  );
}