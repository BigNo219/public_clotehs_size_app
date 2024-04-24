import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';
import 'package:ddundddun/page/category_selection_page.dart';
import 'package:permission_handler/permission_handler.dart';
import 'package:cloudinary_public/cloudinary_public.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:ddundddun/page/recent_photos_page.dart';
import 'package:ddundddun/functions/refresh_count_file_categories.dart';
import 'package:ddundddun/functions/delete_weekend_page.dart';

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

class _MyHomePageState extends State<MyHomePage> with SingleTickerProviderStateMixin {
  late TabController _tabController;

  final _countFileCategories = RefreshCountFileCategories(); // 카테고리 파일 개수 새로고침

  @override
  void initState() {
    super.initState();
    _tabController = TabController(
        length: 3,
        vsync: this,
        initialIndex: 1,
    );
    _requestPermission();
  }

  @override
  void dispose() {
    _tabController.dispose();
    super.dispose();
  }

  final clothingCategories = {
    '상의': ['맨투맨', '반팔티', '후드티', '니트', '나시', '셔츠', '블라우스', '코트'],
    '하의': ['바지', '롱 치마', '숏 치마', '스커트'],
    '원피스': ['롱 원피스', '숏 원피스', '점프수트'],
  };

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
      'timestamp' : FieldValue.serverTimestamp(),
    };

    await FirebaseFirestore.instance.collection('images').add(imageData);
    await showDialog(
      context: context,
      builder: (context) => AlertDialog(
        content: Image.network(imageUrl),
      ),
    );
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
        actions:[
          IconButton(
            icon: Icon(Icons.delete, color: Colors.black),
            onPressed: () {
              Navigator.push(
                context,
                MaterialPageRoute(
                  builder: (context) => DeleteSelectionPage(),
                ),
              );
            },
          ),
          IconButton(
            icon: Icon(Icons.refresh, color: Colors.black),
            onPressed: () {
              setState(() {
                _countFileCategories.countFilesInCategories(clothingCategories); // 카테고리 파일 개수 새로고침
              });
            },
          ),
        ],
        bottom: PreferredSize(
          preferredSize: Size.fromHeight(kToolbarHeight),
          child: Container(
            decoration: BoxDecoration(
              color: Colors.black,
              borderRadius: BorderRadius.circular(20),
            ),
            child: TabBar(
              indicatorColor: Colors.black38,
              labelColor: Colors.white,
              unselectedLabelColor: Colors.grey,
              labelStyle: TextStyle(
                fontSize: 18,
                fontWeight: FontWeight.bold,
                color: Colors.white,
              ),
              unselectedLabelStyle: TextStyle(
                fontSize: 16,
                color: Colors.grey,
              ),
              controller: _tabController,
              tabs: [
                Tab(text: 'Recent'),
                Tab(text: 'Home'),
                Tab(text: 'Categories'),
              ],
            ),
          ),
        ),
      ),
      body: TabBarView(
        controller: _tabController,
        children: [
          RecentPhotosPage(),
          _buildHomeTab(),
          CategorySelectionPage(),
        ],
      ),
    );
  }

  Widget _buildHomeTab() {
    return Center(
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
          ],
        ),
    );
  }
}