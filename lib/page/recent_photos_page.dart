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

  void resetImages() {
    _imageDocs.clear();
    _lastDocument = null;
    fetchImages(isInitialLoad: true); // 초기 로드 플래그 전달
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
  @override
  _RecentPhotoPageState createState() => _RecentPhotoPageState();
}

class _RecentPhotoPageState extends State<RecentPhotosPage> {
  @override
  void dispose() {
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
                final imageDocs = model.imageDocs;
                if (imageDocs.isEmpty) {
                  return const Center(child: CircularProgressIndicator());
                }
                return NotificationListener<ScrollNotification>(
                  onNotification: (ScrollNotification scrollInfo) {
                    if (!model.isLoading &&
                        scrollInfo.metrics.pixels ==
                            scrollInfo.metrics.maxScrollExtent) {
                      model.fetchImages();
                    }
                    return true;
                  },
                  child: GridView.builder(
                    gridDelegate:
                        const SliverGridDelegateWithFixedCrossAxisCount(
                      crossAxisCount: 3,
                      crossAxisSpacing: 8,
                      mainAxisSpacing: 8,
                      childAspectRatio: 1,
                    ),
                    padding: EdgeInsets.all(8),
                    itemCount: imageDocs.length + 1,
                    itemBuilder: (context, index) {
                      if (index < imageDocs.length) {
                        final imageDoc = imageDocs[index];
                        final imageUrl = imageDoc['url'];
                        final imageId = imageDoc.id;
                        final subCategory = imageDoc['subCategory'];
                        return GestureDetector(
                          onTap: () => _openPhotoPage(
                              context, imageUrl, subCategory, imageId),
                          child: OptimizedCachedImage(imageUrl: imageUrl),
                        );
                      } else if (model.isLoading) {
                        return const Center(child: CircularProgressIndicator());
                      } else {
                        return const SizedBox.shrink();
                      }
                    },
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
