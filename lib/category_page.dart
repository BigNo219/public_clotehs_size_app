import 'dart:io';
import 'package:flutter/material.dart';
import 'package:path/path.dart' as path;
import 'package:path_provider/path_provider.dart';
import 'package:ddundddun/photo_page.dart';

class CategoryPage extends StatefulWidget {
  final String category;
  final String subCategory;

  CategoryPage({required this.category, required this.subCategory});

  @override
  _CategoryPageState createState() => _CategoryPageState();
}

class _CategoryPageState extends State<CategoryPage> {
  late Future<List<FileSystemEntity>> _imageFilesFuture;

  @override
  void initState() {
    super.initState();
    _imageFilesFuture = _getImageFiles();
  }

  Future<List<FileSystemEntity>> _getImageFiles() async {
    final appDir = await getApplicationDocumentsDirectory();
    final categoryDir = Directory(path.join(appDir.path, widget.category, widget.subCategory));
    print('Searching images in: ${categoryDir.path}');

    if (await categoryDir.exists()) {
      final imageFiles = <FileSystemEntity>[];
      await for (var entity in categoryDir.list(recursive: true)) {
        if (entity is File && path.extension(entity.path) == '.jpg') {
          imageFiles.add(entity);
        }
      }
      return imageFiles;
    } else {
      return [];
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: Text('${widget.category} - ${widget.subCategory}')),
      body: FutureBuilder<List<FileSystemEntity>>(
        future: _imageFilesFuture,
        builder: (context, snapshot) {
          if (snapshot.hasData) {
            final imageFiles = snapshot.data!;
            if(imageFiles.isEmpty) {
              return Center(child: Text('해당 카테고리에 저장된 사진이 없습니다.'));
            }
            return GridView.builder(
              gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
                crossAxisCount: 3,
                crossAxisSpacing: 4,
                mainAxisSpacing: 4,
              ),
              itemCount: imageFiles.length,
              itemBuilder: (context, index) {
                final imageFile = imageFiles[index];
                return GestureDetector(
                  onTap: () {
                    Navigator.push(
                      context,
                      MaterialPageRoute(
                        builder: (context) => PhotoPage(imagePath: imageFile.path),
                      ),
                    );
                  },
                  child: Image.file(
                    File(imageFile.path),
                    fit: BoxFit.cover,
                  ),
                );
              },
            );
          } else if (snapshot.hasError) {
            return Center(child: Text('Error: ${snapshot.error}'));
          } else {
            return Center(child: CircularProgressIndicator());
          }
        },
      ),
    );
  }
}