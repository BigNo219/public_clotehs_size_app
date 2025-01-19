import 'package:ddundddun/widgets/optimized_cached_image.dart';
import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:ddundddun/page/photo_page.dart';
import 'package:provider/provider.dart';

class RecentPhotosPageModel extends ChangeNotifier {
  List<QueryDocumentSnapshot> _imageDocs = [];
  List<String> _selectedFilters = [];
  DocumentSnapshot? _lastDocument;
  bool _isLoading = false;

  static const int initialLoadCount = 45; // 처음 로드할 이미지 수
  static const int additionalLoadCount = 24; // 스크롤 추가로 로드할 이미지 수

  List<QueryDocumentSnapshot> get imageDocs => _imageDocs;

  List<String> get selectedFilters => _selectedFilters;

  bool get isLoading => _isLoading;

  Future<void> fetchImages({bool isInitialLoad = false}) async {
    if (_isLoading) return;

    _isLoading = true;
    notifyListeners();

    Query query = FirebaseFirestore.instance
        .collection('images')
        .orderBy('timestamp', descending: true)
        .limit(isInitialLoad
            ? initialLoadCount
            : additionalLoadCount); // 초기 로드인 경우 더 많은 이미지 로드

    if (_lastDocument != null) {
      query = query.startAfterDocument(_lastDocument!);
    }

    if (_selectedFilters.isNotEmpty) {
      query = query.where('shoppingMalls', arrayContainsAny: _selectedFilters);
    }

    final snapshot = await query.get();

    _imageDocs.addAll(snapshot.docs);
    _lastDocument = snapshot.docs.isNotEmpty ? snapshot.docs.last : null;

    _isLoading = false;
    notifyListeners();
  }

  Future<void> resetImages() async {
    _imageDocs = [];
    _lastDocument = null;
    _isLoading = false;
    notifyListeners();
    await fetchImages(isInitialLoad: true);
  }

  Future<void> refresh() async {
    _imageDocs = [];
    _lastDocument = null;
    _isLoading = false;
    notifyListeners();
    await fetchImages(isInitialLoad: true);
  }

  void toggleFilter(String filter) {
    if (_selectedFilters.contains(filter)) {
      _selectedFilters.remove(filter);
    } else {
      _selectedFilters.add(filter);
    }
    resetImages();
  }
}

class RecentPhotosPage extends StatefulWidget {
  const RecentPhotosPage({super.key});

  @override
  _RecentPhotoPageState createState() => _RecentPhotoPageState();
}

class _RecentPhotoPageState extends State<RecentPhotosPage> {
  final ScrollController _scrollController = ScrollController();

  @override
  void dispose() {
    _scrollController.dispose();  // ScrollController 해제
    super.dispose();
    PaintingBinding.instance.imageCache.clear();
  }

  @override
  Widget build(BuildContext context) {
    return ChangeNotifierProvider(
      create: (_) => RecentPhotosPageModel()..fetchImages(isInitialLoad: true),
      child: Column(
        children: [
          _buildFilterCheckboxes(),
          Expanded(
            child: Consumer<RecentPhotosPageModel>(
              builder: (context, model, child) {
                return RefreshIndicator(
                  onRefresh: () async {
                    await model.refresh();  // refresh 메서드 호출
                  },
                  child: CustomScrollView(  // CustomScrollView로 변경
                    physics: const AlwaysScrollableScrollPhysics(),
                    controller: _scrollController,
                    slivers: [
                      SliverToBoxAdapter(
                        child: model.imageDocs.isEmpty && model.isLoading
                            ? const Center(child: CircularProgressIndicator())
                            : null,
                      ),
                      SliverGrid(
                        gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
                          crossAxisCount: 3,
                          crossAxisSpacing: 8,
                          mainAxisSpacing: 8,
                          childAspectRatio: 1,
                        ),
                        delegate: SliverChildBuilderDelegate(
                              (context, index) {
                            if (index < model.imageDocs.length) {
                              final imageDoc = model.imageDocs[index];
                              final imageUrl = imageDoc['url'];
                              final imageId = imageDoc.id;
                              final subCategory = imageDoc['subCategory'];
                              return GestureDetector(
                                onTap: () => _openPhotoPage(
                                    context, imageUrl, subCategory, imageId),
                                child: OptimizedCachedImage(imageUrl: imageUrl),
                              );
                            } else if (model.isLoading) {
                              return const Center(
                                  child: CircularProgressIndicator());
                            }
                            return null;
                          },
                          childCount: model.imageDocs.length + (model.isLoading ? 1 : 0),
                        ),
                      ),
                    ],
                  ),
                );
              },
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildFilterCheckboxes() {
    return Consumer<RecentPhotosPageModel>(
      builder: (context, model, child) {
        return Container(
          height: 40,
          color: Colors.grey[200],
          padding: EdgeInsets.all(3.0),
          child: Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              _buildFilterCheckbox('UNBUTTY', model),
              _buildFilterCheckbox('MYUARIN', model),
              _buildFilterCheckbox('NONBETTER', model),
            ],
          ),
        );
      },
    );
  }

  Widget _buildFilterCheckbox(String label, RecentPhotosPageModel model) {
    return Row(
      children: [
        Checkbox(
          value: model.selectedFilters.contains(label),
          onChanged: (value) => model.toggleFilter(label),
        ),
        Text(
          label,
          style: TextStyle(
            fontSize: 10,
          ),
        ),
      ],
    );
  }

  void _openPhotoPage(BuildContext context, String? imageUrl,
      String? subCategory, String? imageId) {
    if (imageUrl != null && subCategory != null && imageId != null) {
      Navigator.push(
        context,
        MaterialPageRoute(
          builder: (context) => PhotoPage(
              imageUrl: imageUrl, category: subCategory, imageId: imageId),
        ),
      );
    } else {
      print('Invalid arguments passed to PhotoPage');
    }
  }
}
