import 'dart:io';
import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';
import 'package:path_provider/path_provider.dart';
import 'package:ddundddun/category_selection_page.dart';
import 'package:ddundddun/delete_selection_page.dart';
import 'package:permission_handler/permission_handler.dart';
import 'package:cloudinary_public/cloudinary_public.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:cloud_firestore/cloud_firestore.dart';


void main() async{
  WidgetsFlutterBinding.ensureInitialized();

  await Firebase.initializeApp();
  runApp(MyApp());
}

class MyApp extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
     return MaterialApp(
        debugShowCheckedModeBanner: false,
        title: 'Size App',
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

  @override
  void initState() {
    super.initState();
    _requestPermission();
  }

  // 카메라 및 사진, 저장소 접근 권한 요청
  Future<void> _requestPermission() async {
    final status = await [
      Permission.camera,
    ].request();

    if (status[Permission.camera]!.isDenied ) {
      // 권한이 거부되면 추가적인 안내를 제공
      showDialog(
        context: context,
        builder: (context) => AlertDialog(
          title: Text("필요한 권한"),
          content: Text("앱에서 필요한 권한이 거부되었습니다. 설정에서 권한을 허용해주세요."),
          actions: [
            TextButton(
              onPressed: ()  {
                openAppSettings(); // 사용자가 앱 설정 페이지로 이동시키는 함수
                Navigator.of(context).pop();
              },
              child: Text(
                "설정으로 이동",
                ),
            ),
            TextButton(
              onPressed: () => Navigator.of(context).pop(),
              child: Text("취소"),
            ),
          ],
        ),
      );
    }
  }

  Future<String> uploadImageToCloudinary(
      String imagePath,
      String cloudinaryImagePath ) async {
    try {
      final cloudinary = CloudinaryPublic(
          'duqykedvy',
          'flutter_clotehs_size_app',
          apiKey: '491384474792879',
          apiSecret: 'hE8xMCTm7R8q8mf0K_MrlguymiU',
          cache: false);

      final response = await cloudinary.uploadFile(
        CloudinaryFile.fromFile(
            imagePath,
            resourceType: CloudinaryResourceType.Image,
            folder: cloudinaryImagePath),
      );

      return response.secureUrl!;
    } catch (e) {
      print('Failed to upload image to Cloudinary: $e');
      return '';
    }
  }

  Future<void> _takePicture() async {
    final picker = ImagePicker();
    final pickedImage = await picker.pickImage(source: ImageSource.camera);

    if (pickedImage != null) {
      final imagePath = pickedImage.path;
      await _showCategoryDialog(imagePath);
    }
  }

  Future<void> _selectImageFromGallery() async {
    final picker = ImagePicker();
    final pickedImage = await picker.pickImage(source: ImageSource.gallery);

    if (pickedImage != null) {
      final imagePath = pickedImage.path;
      await _showCategoryDialog(imagePath);
    }
  }

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

  Future<void> _saveImage(String imagePath, String category, String subCategory) async {
    final cloudinaryImagePath = '$category/$subCategory';

    final imageUrl = await uploadImageToCloudinary(
        imagePath,
        cloudinaryImagePath
    );
    print('Image URL: $imageUrl');

    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(content: Text('" $category -> $subCategory "에 저장되었습니다.')),
    );

    final imageData = {
      'url' : imageUrl,
      'category' : category,
      'subCategory' : subCategory,
    };

    await FirebaseFirestore.instance.collection('images').add(imageData);
    await showDialog(
      context: context,
      builder: (context) => AlertDialog(
        content: Image.network(imageUrl),
      ),
    );
  }

  // 앱 용량 계산
  Future<String> _calculateAppSize() async {
    final appDir = await getApplicationDocumentsDirectory();
    final appSize = await _getTotalSizeOfFilesInDir(appDir);
    final sizeInMB = (appSize / (1024 * 1024)).toStringAsFixed(2);
    return '$sizeInMB MB';
  }

  // 디렉토리 용량 계산
  Future<int> _getTotalSizeOfFilesInDir(final FileSystemEntity file) async {
    if (file is File) {
      final fileStat = await file.stat();
      return fileStat.size;
    }
    if (file is Directory) {
      final children = file.listSync();
      int total = 0;
      for (final FileSystemEntity child in children) {
        total += await _getTotalSizeOfFilesInDir(child);
      }
      return total;
    }
    return 0;
  }


  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      appBar: AppBar(
        title: Text(
          '[ UN;BUTTY ] ... Size App',
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
              'assets/logo2.png',
              width: 200,
              height: 120,
            ),
            SizedBox(height: 40),
            Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                ElevatedButton(
                  onPressed: _selectImageFromGallery,
                  style: ElevatedButton.styleFrom(
                    backgroundColor: Colors.grey[600],
                    foregroundColor: Colors.white,
                    padding: EdgeInsets.symmetric(horizontal: 20, vertical: 20),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(25),
                    ),
                  ),
                  child: Text(
                    'Gallery',
                    style: TextStyle(fontSize: 20),
                  ),
                ),
                SizedBox(width: 20),
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
                    'Camera',
                    style: TextStyle(fontSize: 20),
                  ),
                ),
              ],
            ),
            SizedBox(height: 20),
            FutureBuilder<String>(
              future: _calculateAppSize(),
              builder: (context, snapshot) {
                if (snapshot.connectionState == ConnectionState.waiting) {
                  return CircularProgressIndicator();
                } else if (snapshot.hasError) {
                  return Text('Error: ${snapshot.error}');
                } else {
                  return Text(
                    '앱 용량: ${snapshot.data}',
                    style: TextStyle(fontSize: 16),
                  );
                }
              },
            ),
          ],
        ),
      ),
    );
  }
}