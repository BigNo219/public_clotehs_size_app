import 'dart:io';
import 'package:flutter/material.dart';
import 'package:path_provider/path_provider.dart';
import 'package:path/path.dart' as Path;

class PhotoPage extends StatefulWidget {
  final String imagePath;

  PhotoPage({required this.imagePath});

  @override
  _PhotoPageState createState() => _PhotoPageState();
}

class _PhotoPageState extends State<PhotoPage> {
  late TextEditingController _descriptionController;
  late String _savedImagePath;

  @override
  void initState() {
    super.initState();
    _descriptionController = TextEditingController();
    _savedImagePath = widget.imagePath;
    _loadDescription();
  }

  Future<void> _loadDescription() async {
    final appDir = await getApplicationDocumentsDirectory();
    final descriptionFile = File('${appDir.path}/${Path.basenameWithoutExtension(_savedImagePath)}.txt');

    if (await descriptionFile.exists()) {
      final description = await descriptionFile.readAsString();
      _descriptionController.text = description;
    }
  }

  Future<void> _saveDescription() async {
    final appDir = await getApplicationDocumentsDirectory();
    final descriptionFile = File('${appDir.path}/${Path.basenameWithoutExtension(_savedImagePath)}.txt');

    await descriptionFile.writeAsString(_descriptionController.text);
    ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('정보 저장 완료.')),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: Text('Photo Details')),
      body: SingleChildScrollView(
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            Image.file(File(_savedImagePath)),
            Padding(
              padding: EdgeInsets.all(16.0),
              child: TextField(
                controller: _descriptionController,
                decoration: InputDecoration(
                  labelText: 'Description',
                  border: OutlineInputBorder(),
                ),
                maxLines: 3,
              ),
            ),
            Padding(
              padding: EdgeInsets.symmetric(horizontal: 16.0),
              child: ElevatedButton(
                onPressed: _saveDescription,
                child: Text('Save Description'),
              ),
            ),
          ],
        ),
      ),
    );
  }

  @override
  void dispose() {
    _descriptionController.dispose();
    super.dispose();
  }
}