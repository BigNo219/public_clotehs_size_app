import 'dart:io';
import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';
import 'package:path/path.dart' as path;
import 'package:path_provider/path_provider.dart';
import 'package:intl/intl.dart';
import 'package:ddundddun/category_selection_page.dart';
import 'package:ddundddun/delete_selection_page.dart';

void main() {
  runApp(MyApp());
}

class MyApp extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      debugShowCheckedModeBanner: false,

      title: 'DDunddun App',
      theme: ThemeData(
        primarySwatch: Colors.blue,
      ),
      home: MyHomePage(),
    );
  }
}

class MyHomePage extends StatefulWidget {
  @override
  _MyHomePageState createState() => _MyHomePageState();
}

class _MyHomePageState extends State<MyHomePage> {
  final clothingCategories = {
    '상의': ['맨투맨', '반팔티', '후드티', '니트', '가디건', '코트', '셔츠', '블라우스'],
    '하의': ['바지', '롱치마', '숏치마', '멜빵바지', '레깅스', '스커트'],
    '원피스': ['롱원피스', '숏원피스', '점프수트'],
  };

  String _selectedCategory = '상의';
  String _selectedSubCategory = '맨투맨';

  Future<void> _takePicture() async {
    final picker = ImagePicker();
    final pickedImage = await picker.pickImage(source: ImageSource.camera);

    if (pickedImage != null) {
      final imagePath = pickedImage.path;
      await _showCategoryDialog(imagePath);
    }
  }

  // 카테고리 선택 다이얼로그 표시
  Future<void> _showCategoryDialog(String imagePath) async {
    await showDialog(
      context: context,
      builder: (context) {
        return AlertDialog(
          title: Text('Select Category'),
          content: SingleChildScrollView(
            child: ListBody(
              children: clothingCategories.entries.map((entry) {
                final category = entry.key;
                final subCategories = entry.value;
                return ExpansionTile(
                  title: Text(category),
                  children: subCategories.map((subCategory) {
                    return GestureDetector(
                      onTap: () {
                        Navigator.of(context).pop();
                        _saveImage(imagePath, category, subCategory);
                      },
                      child: Padding(
                        padding: EdgeInsets.symmetric(vertical: 8.0, horizontal: 16.0),
                        child: Text(subCategory),
                      ),
                    );
                  }).toList(),
                );
              }).toList(),
            ),
          ),
          actions: [
            TextButton(
              onPressed: () {
                Navigator.of(context).pop();
              },
              child: Text('Cancel'),
            ),
          ],
        );
      },
    );
  }

  // 사진 저장 함수
  Future<void> _saveImage(String imagePath, String category, String subCategory) async {
    final appDir = await getApplicationDocumentsDirectory();
    final timeDir = _getTimeDirPath();
    final categoryDir = Directory(path.join(appDir.path, category, subCategory)); // 0final categoryDir = Directory(path.join(appDir.path, timeDir, category, subCategory));
    await categoryDir.create(recursive: true);

    final fileName = DateTime.now().millisecondsSinceEpoch.toString();
    final savedImagePath = path.join(categoryDir.path, '$fileName.jpg');
    await File(imagePath).copy(savedImagePath);
    print('Saving image to $savedImagePath');

    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(content: Text('" $category -> $subCategory "에 저장되었습니다.'))
    );
  }

  // 시간별 디렉토리 경로 생성
  String _getTimeDirPath() {
    final now = DateTime.now();
    final dateDir = DateFormat('yyyyMMdd').format(now);
    final weekdayDir = DateFormat('EEEE').format(now);

    return path.join(dateDir, weekdayDir);
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      appBar: AppBar(
        title: Text(
          '3LStudio Size',
          style: TextStyle(
            color: Colors.black,
            fontWeight: FontWeight.bold,
            fontSize: 24,
          ),
        ),
        actions: [
          IconButton(
            icon: Icon(Icons.delete, color: Colors.grey),
            onPressed: () {
              Navigator.push(
                context,
                MaterialPageRoute(builder: (context) => DeleteSelectionPage()),
              );
            },
          ),
          IconButton(
            icon: Icon(Icons.photo_library, color: Colors.grey[600]),
            onPressed: () {
              Navigator.push(
                context,
                MaterialPageRoute(builder: (context) => CategorySelectionPage()),
              );
            },
          ),
        ],
      ),
      body: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Image.asset(
              'assets/logo.png',
              width: 200,
              height: 120,
            ),
            SizedBox(height: 40),
            ElevatedButton(
              onPressed: _takePicture,
              style: ElevatedButton.styleFrom(
                backgroundColor: Colors.grey[800],
                foregroundColor: Colors.white,
                padding: EdgeInsets.symmetric(horizontal: 20, vertical: 20),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(25),
                ),
              ),
              child: Text(
                '촬영',
                style: TextStyle(fontSize: 20),
              ),
            ),
          ],
        ),
      ),
    );
  }
}