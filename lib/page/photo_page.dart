import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:ddundddun/models/category_form.dart';

class PhotoPage extends StatefulWidget {
  final String imageUrl;
  final String category;
  final String imageId;

  PhotoPage({required this.imageUrl, required this.category, required this.imageId});

  @override
  _PhotoPageState createState() => _PhotoPageState();
}

class _PhotoPageState extends State<PhotoPage> {
  late Map<String, TextEditingController> _controllers = {
    'title': TextEditingController(),
    'description': TextEditingController(),
  };
  Lining? _selectedLining;
  Elasticity? _selectedElasticity;
  Transparency? _selectedTransparency;
  ClothingTexture? _selectedClothingTexture;
  Fit? _selectedFit;
  Thickness? _selectedThickness;
  Season? _selectedSeason;
  bool _isLoading = false;

  final _scrollController = ScrollController();

  @override
  void initState() {
    super.initState();
    _loadInitialData();
  }

  Future<void> _loadInitialData() async {
    setState(() {
      _isLoading = true;
    });

    final docSnapshot = await FirebaseFirestore.instance.collection('images').doc(widget.imageId).get();
    final data = docSnapshot.data() as Map<String, dynamic>?;

    if (data != null) {
      _controllers = {
        'title': TextEditingController(text: data['title'] ?? ''),
        'customerName': TextEditingController(text: data['customerName'] ?? ''),
        'description': TextEditingController(text: data['description'] ?? ''),
      };

      final fields = categoryForms[widget.category];
      if (fields != null) {
        for (var field in fields) {
          _controllers[field] = TextEditingController(text: data[field]?.toString() ?? '');
        }
      }

      _selectedLining = data['lining'] != null ? Lining.values.byName(data['lining']) : null;
      _selectedElasticity = data['elasticity'] != null ? Elasticity.values.byName(data['elasticity']) : null;
      _selectedTransparency = data['transparency'] != null ? Transparency.values.byName(data['transparency']) : null;
      _selectedClothingTexture = data['texture'] != null ? ClothingTexture.values.byName(data['texture']) : null;
      _selectedFit = data['fit'] != null ? Fit.values.byName(data['fit']) : null;
      _selectedThickness = data['thickness'] != null ? Thickness.values.byName(data['thickness']) : null;
      _selectedSeason = data['season'] != null ? Season.values.byName(data['season']) : null;
    } else {
      final fields = categoryForms[widget.category];
      if (fields != null) {
        _controllers = {
          for (var field in fields) field: TextEditingController(),
        };
      }
    }

    setState(() {
      _isLoading = false;
    });
  }

  Future<void> _saveDetails() async {
    final fields = categoryForms[widget.category] ?? [];

    final data = {
      'title': _controllers['title']!.text,
      'customerName': _controllers['customerName']!.text,
      'description': _controllers['description']!.text,
      for (var field in fields)
        field: _controllers[field]?.text.isNotEmpty == true ? int.parse(_controllers[field]!.text) : null,
      'lining': _selectedLining?.toString().split('.').last ?? '',
      'elasticity': _selectedElasticity?.toString().split('.').last ?? '',
      'transparency': _selectedTransparency?.toString().split('.').last ?? '',
      'texture': _selectedClothingTexture?.toString().split('.').last ?? '',
      'fit': _selectedFit?.toString().split('.').last ?? '',
      'thickness': _selectedThickness?.toString().split('.').last ?? '',
      'season': _selectedSeason?.toString().split('.').last ?? '',
    };

    await FirebaseFirestore.instance.collection('images').doc(widget.imageId).update(data);

    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(content: Text('사이즈 및 상세내용이 저장되었습니다.')),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: Text('사이즈 및 상세내용 입력')),
      body: FutureBuilder<DocumentSnapshot>(
        future: FirebaseFirestore.instance.collection('images').doc(widget.imageId).get(),
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) {
            return Center(child: CircularProgressIndicator());
          }

          if (snapshot.hasError) {
            return Center(child: Text('Error: ${snapshot.error}'));
          }

          final imageData = snapshot.data!.data() as Map<String, dynamic>;
          final imageUrl = imageData['url'] as String;

          final fields = categoryForms[widget.category];

          if (fields == null) {
            return Center(child: Text('해당 카테고리에 대한 정보가 없습니다.'));
          }
          return SingleChildScrollView(
            controller: _scrollController,
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                Container(
                  width: 300.0,
                  height: 300.0,
                  child: Image.network(
                    imageUrl,
                    fit: BoxFit.cover,
                  ),
                ),
                _buildTextField('title', '제목'),
                _buildTextField('customerName', '거래처 명'),
                _buildMultilineTextField('description', '추가 정보'),
                ...categoryForms[widget.category]!.map((field) => _buildTextField(field, field)).toList(),
                _buildRadioGroup<Lining>('안감', Lining.values, liningLabels, _selectedLining, (value) => _selectedLining = value),
                _buildRadioGroup<Elasticity>('신축성', Elasticity.values, elasticityLabels, _selectedElasticity, (value) => _selectedElasticity = value),
                _buildRadioGroup<Transparency>('비침', Transparency.values, transparencyLabels, _selectedTransparency, (value) => _selectedTransparency = value),
                _buildRadioGroup<ClothingTexture>('촉감', ClothingTexture.values, textureLabels, _selectedClothingTexture, (value) => _selectedClothingTexture = value),
                _buildRadioGroup<Fit>('핏감', Fit.values, fitLabels, _selectedFit, (value) => _selectedFit = value),
                _buildRadioGroup<Thickness>('두께감', Thickness.values, thicknessLabels, _selectedThickness, (value) => _selectedThickness = value),
                _buildRadioGroup<Season>('계절감', Season.values, seasonLabels, _selectedSeason, (value) => _selectedSeason = value),
                Padding(
                  padding: EdgeInsets.symmetric(horizontal: 16.0),
                  child: ElevatedButton(
                    onPressed: _saveDetails,
                    style: ButtonStyle(
                      backgroundColor: MaterialStateProperty.all(Colors.black87),
                      foregroundColor: MaterialStateProperty.all(Colors.white),
                      shape: MaterialStateProperty.all(
                        RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(20.0),
                        ),
                      ),
                      elevation: MaterialStateProperty.all(8.0),
                      padding: MaterialStateProperty.all(
                        EdgeInsets.symmetric(vertical: 16.0, horizontal: 24.0),
                      ),
                    ),
                    child: Text('저장'),
                  ),
                ),
              ],
            ),
          );
        },
      ),
    );
  }

  Widget _buildTextField(String field, String label) {
    return Padding(
      padding: EdgeInsets.all(16.0),
      child: TextField(
        controller: _controllers[field],
        decoration: InputDecoration(
          labelText: label,
          labelStyle: TextStyle(
            fontSize: 18,
            fontWeight: FontWeight.bold,
          ),
          border: OutlineInputBorder(),
        ),
      ),
    );
  }

  Widget _buildMultilineTextField(String field, String label) {
    return Padding(
      padding: EdgeInsets.all(16.0),
      child: TextField(
        controller: _controllers[field],
        decoration: InputDecoration(
          labelText: label,
          labelStyle: TextStyle(
            fontSize: 18,
            fontWeight: FontWeight.bold,
          ),
          border: OutlineInputBorder(),
          contentPadding: EdgeInsets.symmetric(vertical: 20.0, horizontal: 10.0),
        ),
        maxLines: null,
        keyboardType: TextInputType.multiline,
        style: TextStyle(height: 1.0),
      ),
    );
  }

  Widget _buildRadioGroup<T>(
      String title,
      List<T> values,
      Map<T, String> labels,
      T? selectedValue,
      void Function(T?) onChanged,
      ) {
    return Padding(
      padding: EdgeInsets.all(16.0),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            title,
            style: TextStyle(
              fontSize: 16.0,
              fontWeight: FontWeight.bold,
            ),
          ),
          SizedBox(height: 8.0),
          Wrap(
            spacing: 8.0,
            runSpacing: 8.0,
            children: values.map((value) => Row(
              mainAxisSize: MainAxisSize.min,
              children: [
                Radio<T>(
                  value: value,
                  groupValue: selectedValue,
                  onChanged: (value) {
                    final currentScrollPosition = _scrollController.position.pixels;
                    setState(() => onChanged(value));
                    _scrollController.animateTo(
                      currentScrollPosition,
                      duration: Duration(milliseconds: 200),
                      curve: Curves.easeInOut,
                    );
                  },
                ),
                Text(labels[value]!),
              ],
            )).toList(),
          ),
        ],
      ),
    );
  }

  @override
  void dispose() {
    _scrollController.dispose();
    _controllers.values.forEach((controller) => controller.dispose());
    super.dispose();
  }
}