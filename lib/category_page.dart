import 'dart:io';
import 'package:flutter/material.dart';
import 'package:path/path.dart' as path;
import 'package:path_provider/path_provider.dart';
import 'package:ddundddun/photo_page.dart';
import 'package:ddundddun/category_selection_page.dart';

class CategoryPage extends StatefulWidget {
  final String category;
  final String subCategory;

  CategoryPage({required this.category, required this.subCategory});

  @override
  _CategoryPageState createState() => _CategoryPageState();
}

class _CategoryPageState extends State<CategoryPage> {
  late Future<List<FileSystemEntity>> _imageFilesFuture;
  List<String> _selectedImagePaths = [];
  bool _isSelectionMode = false;

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

  void _toggleSelectionMode() {
    setState(() {
      _isSelectionMode = !_isSelectionMode;
      _selectedImagePaths.clear();
    });
  }

  void _selectImage(String imagePath) {
    setState(() {
      if (_selectedImagePaths.contains(imagePath)) {
        _selectedImagePaths.remove(imagePath);
      } else {
        _selectedImagePaths.add(imagePath);
      }
    });
  }

  Future<void> _deleteSelectedImages() async {
    if (_selectedImagePaths.isEmpty) return;

    final confirmed = await showDialog(
      context: context,
      builder: (context) {
        return AlertDialog(
          title: Text('사진 삭제'),
          content: Text('선택한 사진을 삭제하시겠습니까?'),
          actions: [
            TextButton(
              onPressed: () => Navigator.pop(context, false),
              child: Text('취소'),
            ),
            TextButton(
              onPressed: () => Navigator.pop(context, true),
              child: Text('삭제'),
            ),
          ],
        );
      },
    );

    if (confirmed == true) {
      for (String imagePath in _selectedImagePaths) {
        try {
          await File(imagePath).delete();
          // 관련된 데이터 삭제 로직 추가
        } catch (e) {
          print('Failed to delete image: $imagePath, error: $e');
        }
      }
      setState(() {
        _selectedImagePaths.clear();
        _isSelectionMode = false;
        _imageFilesFuture = _getImageFiles();
      });
      Navigator.pop(context, true);  // Return true on successful delete
    }
  }

  Future<void> _moveSelectedImages() async {
    if (_selectedImagePaths.isEmpty) return;

    final result = await showDialog(
      context: context,
      builder: (context) => CategorySelectionPage(
        onCategorySelected: (category, subCategory) {
          Navigator.pop(context, [category, subCategory]);
        },
      ),
    );

    if (result != null && result.length == 2) {
      final selectedCategory = result[0];
      final selectedSubCategory = result[1];

      for (String imagePath in _selectedImagePaths) {
        final file = File(imagePath);
        final oldPath = file.path;
        final newPath = path.join(
          (await getApplicationDocumentsDirectory()).path,
          selectedCategory,
          selectedSubCategory,
          path.basename(imagePath),
        );

        try {
          await file.rename(newPath);
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(content: Text('카테고리 이동 성공: $oldPath -> $newPath'))
          );
        } catch (e) {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(content: Text('카테고리 이동 실패: $oldPath, error: $e'))
          );
        }
      }

      setState(() {
        _selectedImagePaths.clear();
        _isSelectionMode = false;
        _imageFilesFuture = _getImageFiles();
      });
      Navigator.pop(context, true);  // Return true on successful delete
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('${widget.category} - ${widget.subCategory}'),
        actions: _isSelectionMode ? [
          IconButton(
            icon: Icon(Icons.send, color: Colors.cyanAccent),
            onPressed: _moveSelectedImages,
          ),
          IconButton(
            icon: Icon(Icons.delete, color: Colors.red),
            onPressed: _deleteSelectedImages,
          ),
        ] : [
          IconButton(
            icon: Icon(Icons.edit, color: Colors.grey),
            onPressed: () {
              setState(() {
                _toggleSelectionMode();
              });
            },
          ),
        ],
      ),
      body: FutureBuilder<List<FileSystemEntity>>(
        future: _imageFilesFuture,
        builder: (context, snapshot) {
          if (snapshot.hasData) {
            final imageFiles = snapshot.data!;
            if (imageFiles.isEmpty) {
              return Center(child: Text('해당 카테고리에 저장된 사진이 없습니다.'));
            }
            return GridView.builder(
              gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
                crossAxisCount: 3,
                crossAxisSpacing: 8,
                mainAxisSpacing: 8,
              ),
              padding: EdgeInsets.all(8),
              itemCount: imageFiles.length,
              itemBuilder: (context, index) {
                final imageFile = imageFiles[index];
                return GestureDetector(
                  onTap: _isSelectionMode
                      ? () => _selectImage(imageFile.path)
                      : () {
                    Navigator.push(
                      context,
                      MaterialPageRoute(
                        builder: (context) => PhotoPage(imagePath: imageFile.path),
                      ),
                    );
                  },
                  child: Stack(
                    children: [
                      ClipRRect(
                        borderRadius: BorderRadius.circular(10),
                        child: Image.file(
                          File(imageFile.path),
                          fit: BoxFit.cover,
                        ),
                      ),
                      if (_isSelectionMode)
                        Positioned(
                          top: 8,
                          right: 8,
                          child: Icon(
                            _selectedImagePaths.contains(imageFile.path)
                                ? Icons.check_circle
                                : Icons.radio_button_unchecked,
                            color: Colors.blue,
                          ),
                        ),
                    ],
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