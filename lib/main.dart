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
import 'package:flutter_dotenv/flutter_dotenv.dart';
import 'package:provider/provider.dart';
import 'package:ddundddun/models/radio_view_model.dart';

final GlobalKey<NavigatorState> navigatorKey = GlobalKey<NavigatorState>();

Future<void> main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await dotenv.load(fileName: '.env');
  await Firebase.initializeApp();
  runApp(
    ChangeNotifierProvider(
      create: (context) => RadioViewModel(),
      child: const MyApp(),
    ),
  );
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      navigatorKey: navigatorKey,
      debugShowCheckedModeBanner: false,
      title: 'Size App',
      theme: ThemeData(
        fontFamily: 'EnglishFont',
        primarySwatch: Colors.blue,
        textTheme: const TextTheme(
          titleMedium: TextStyle(fontFamily: 'KoreanFont'), // 디버그 배너 폰트 변경
        ),
      ),
      home: const MyHomePage(),
    );
  }
}

class MyHomePage extends StatefulWidget {
  const MyHomePage({super.key});

  @override
  _MyHomePageState createState() => _MyHomePageState();
}

class _MyHomePageState extends State<MyHomePage>
    with SingleTickerProviderStateMixin {
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
    '아우터': ['가디건', '자켓/코트(숏)', '자켓/코트(롱)', '점퍼', '베스트(패딩조끼)'],
    '상의': ['티셔츠(긴소매)', '티셔츠(반소매)', '티셔츠(목폴라)', '민소매(조끼)', '블라우스(셔츠)'],
    '원피스': ['긴팔원피스', '반팔원피스', '민소매원피스', '목폴라원피스'],
    '패션소품': ['가방', '신발'],
    '팬츠': ['긴바지', '반바지', '점프수트'],
    '스커트': ['미니스커트', '롱스커트']
  };

  // 카메라 및 사진, 저장소 접근 권한 요청
  Future<void> _requestPermission() async {
    final status = await [
      Permission.camera,
      Permission.photos,
    ].request();

    if (status[Permission.camera]!.isDenied ||
        status[Permission.photos]!.isDenied) {
      // 권한이 거부되면 추가적인 안내를 제공
      showDialog(
        context: context,
        builder: (context) => AlertDialog(
          title: const Text("필요한 권한", style: TextStyle(fontFamily: 'KoreanFont')),
          content: const Text("앱에서 필요한 권한이 거부되었습니다. 설정에서 권한을 허용해주세요.", style: TextStyle(fontFamily: 'KoreanFont')),
          actions: [
            TextButton(
              onPressed: () {
                openAppSettings(); // 사용자가 앱 설정 페이지로 이동시키는 함수
                Navigator.of(context).pop();
              },
              child: const Text(
                "설정으로 이동", style: TextStyle(fontFamily: 'KoreanFont')
              ),
            ),
            TextButton(
              onPressed: () => Navigator.of(context).pop(),
              child: const Text("취소", style: TextStyle(fontFamily: 'KoreanFont')),
            ),
          ],
        ),
      );
    }
  }

  Future<String> uploadImageToCloudinary(
      String imagePath, String cloudinaryImagePath) async {
    try {
      final cloudinary = CloudinaryPublic(
        dotenv.env['CLOUD_NAME']!,
        dotenv.env['CLOUDINARY_PRESET']!,
        apiKey: dotenv.env['API_KEY']!,
        apiSecret: dotenv.env['API_SECRET']!,
        cache: false,
      );

      final response = await cloudinary.uploadFile(
        CloudinaryFile.fromFile(
          imagePath,
          resourceType: CloudinaryResourceType.Image,
          folder: cloudinaryImagePath,
        ),
      );

      return response.secureUrl;
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
          title: const Text('Select Category'),
          content: SingleChildScrollView(
            child: ListBody(
              children: clothingCategories.entries.map((entry) {
                final category = entry.key;
                final subCategories = entry.value;
                return ExpansionTile(
                  title: Text(category, style: const TextStyle(fontFamily: 'KoreanFont')),
                  children: subCategories.map((subCategory) {
                    return GestureDetector(
                      onTap: () {
                        Navigator.of(context).pop();
                        _saveImage(imagePath, category, subCategory);
                      },
                      child: Padding(
                        padding: const EdgeInsets.symmetric(
                            vertical: 8.0, horizontal: 16.0),
                        child: Text(subCategory, style: const TextStyle(fontFamily: 'KoreanFont')),
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
              child: const Text('Cancel'),
            ),
          ],
        );
      },
    );
  }

  Future<void> _saveImage(
      String imagePath, String category, String subCategory) async {
    final cloudinaryImagePath = '$category/$subCategory';

    final imageUrl =
        await uploadImageToCloudinary(imagePath, cloudinaryImagePath);
    print('Image URL: $imageUrl');

    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(content: Text('" $category -> $subCategory "에 저장되었습니다.', style: const TextStyle(fontFamily: 'KoreanFont'))),
    );

    final imageData = {
      'url': imageUrl,
      'category': category,
      'subCategory': subCategory,
      'timestamp': FieldValue.serverTimestamp(),
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
        title: const Text(
          '[ UN;BUTTY ] ... Size App',
          style: TextStyle(
            color: Colors.white,
            fontWeight: FontWeight.bold,
            fontSize: 18,
          ),
        ),
        backgroundColor: Colors.black,
        actions: [
          IconButton(
            icon: const Icon(Icons.delete, color: Colors.grey),
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
            icon: const Icon(Icons.refresh, color: Colors.grey),
            onPressed: () {
              setState(() {
                _countFileCategories.countFilesInCategories(
                    clothingCategories); // 카테고리 파일 개수 새로고침
              });
            },
          ),
        ],
      ),
      body: TabBarView(
        controller: _tabController,
        children: [
          RecentPhotosPage(),
          _buildHomeTab(),
          CategorySelectionPage(),
        ],
      ),
      bottomNavigationBar: Container(
        height: 60,
        decoration: BoxDecoration(
          color: Colors.black,
          borderRadius: BorderRadius.only(
            topLeft: Radius.circular(20),
            topRight: Radius.circular(20),
          ),
        ),
        child: TabBar(
          indicatorColor: Colors.black38,
          labelColor: Colors.white,
          unselectedLabelColor: Colors.grey,
          labelStyle: const TextStyle(
            fontSize: 18,
            fontWeight: FontWeight.bold,
            color: Colors.white,
          ),
          unselectedLabelStyle: const TextStyle(
            fontSize: 16,
            color: Colors.grey,
          ),
          controller: _tabController,
          tabs: [
            const Tab(text: 'Recent'),
            const Tab(text: 'Home'),
            const Tab(text: 'Categories'),
          ],
        ),
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
          const SizedBox(height: 40),
          Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              ElevatedButton(
                onPressed: _selectImageFromGallery,
                style: ElevatedButton.styleFrom(
                  backgroundColor: Colors.grey[600],
                  foregroundColor: Colors.white,
                  padding:
                      const EdgeInsets.symmetric(horizontal: 20, vertical: 20),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(25),
                  ),
                ),
                child: const Text(
                  'Gallery',
                  style: TextStyle(fontSize: 20),
                ),
              ),
              const SizedBox(width: 20),
              ElevatedButton(
                onPressed: _takePicture,
                style: ElevatedButton.styleFrom(
                  backgroundColor: Colors.grey[800],
                  foregroundColor: Colors.white,
                  padding:
                      const EdgeInsets.symmetric(horizontal: 20, vertical: 20),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(25),
                  ),
                ),
                child: const Text(
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
