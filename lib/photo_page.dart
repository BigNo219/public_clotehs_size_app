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
        'title': TextEditingController(text: data['title']?.toString() ?? ''),
        'description': TextEditingController(text: data['description']?.toString() ?? ''),
        for (var field in categoryForms[widget.category]!)
          if (data[field] != null) field: TextEditingController(text: data[field].toString()),
      };

      final liningValue = Lining.values.byName(data['lining']);
      if (liningValue != null) {
        _selectedLining = liningValue;
      }

      final elasticityValue = Elasticity.values.byName(data['elasticity']);
      if (elasticityValue != null) {
        _selectedElasticity = elasticityValue;
      }

      final transparencyValue = Transparency.values.byName(data['transparency']);
      if (transparencyValue != null) {
        _selectedTransparency = transparencyValue;
      }

      final textureValue = ClothingTexture.values.byName(data['texture']);
      if (textureValue != null) {
        _selectedClothingTexture = textureValue;
      }

      final fitValue = Fit.values.byName(data['fit']);
      if (fitValue != null) {
        _selectedFit = fitValue;
      }

      final thicknessValue = Thickness.values.byName(data['thickness']);
      if (thicknessValue != null) {
        _selectedThickness = thicknessValue;
      }

      final seasonValue = Season.values.byName(data['season']);
      if (seasonValue != null) {
        _selectedSeason = seasonValue;
      }
    } else {
      _controllers = {
        for (var field in categoryForms[widget.category]!) field: TextEditingController(),
      };
    }

    setState(() {
      _isLoading = false;
    });
  }

  Future<void> _saveDetails() async {
    final fields = categoryForms[widget.category];
    if (fields == null) {
      return;
    }
    final data = {
      'title': _controllers['title']!.text,
      'description': _controllers['description']!.text,
      for (var field in categoryForms[widget.category]!) field: int.parse(_controllers[field]!.text),
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
      SnackBar(content: Text('정보 저장 완료.')),
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
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                Container(
                  width: 400.0,
                  height: 400.0,
                  child: Image.network(
                    imageUrl,
                    fit: BoxFit.cover,
                  ),
                ),
                Padding(
                  padding: EdgeInsets.all(16.0),
                  child: TextField(
                    controller: _controllers['title'],
                    decoration: InputDecoration(
                      labelText: '제목',
                      border: OutlineInputBorder(),
                    ),
                  ),
                ),
                Padding(
                  padding: EdgeInsets.all(16.0),
                  child: TextField(
                    controller: _controllers['description'],
                    decoration: InputDecoration(
                      labelText: '추가 정보',
                      border: OutlineInputBorder(),
                      contentPadding: EdgeInsets.symmetric(vertical: 20.0, horizontal: 10.0),
                    ),
                    maxLines: null,
                    keyboardType: TextInputType.multiline,
                    style: TextStyle(height: 1.0),
                  ),
                ),
                ...categoryForms[widget.category]!.map((field) => Padding(
                  padding: EdgeInsets.all(16.0),
                  child: TextField(
                    controller: _controllers[field],
                    decoration: InputDecoration(
                      labelText: field,
                      border: OutlineInputBorder(),
                    ),
                    keyboardType: TextInputType.number,
                  ),
                )).toList(),
                Padding(
                  padding: EdgeInsets.all(16.0),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        '안감',
                        style: TextStyle(
                          fontSize: 16.0,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                      SizedBox(height: 8.0),
                      Wrap(
                        spacing: 8.0,
                        runSpacing: 8.0,
                        children: Lining.values.map((lining) => Row(
                          mainAxisSize: MainAxisSize.min,
                          children: [
                            Radio<Lining>(
                              value: lining,
                              groupValue: _selectedLining,
                              onChanged: (value) => setState(() => _selectedLining = value),
                            ),
                            Text(liningLabels[lining]!),
                          ],
                        )).toList(),
                      ),
                    ],
                  ),
                ),
                Padding(
                  padding: EdgeInsets.all(16.0),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        '신축성',
                        style: TextStyle(
                          fontSize: 16.0,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                      SizedBox(height: 8.0),
                      Wrap(
                        spacing: 8.0,
                        runSpacing: 8.0,
                        children: Elasticity.values.map((elasticity) => Row(
                          mainAxisSize: MainAxisSize.min,
                          children: [
                            Radio<Elasticity>(
                              value: elasticity,
                              groupValue: _selectedElasticity,
                              onChanged: (value) => setState(() => _selectedElasticity = value),
                            ),
                            Text(elasticityLabels[elasticity]!),
                          ],
                        )).toList(),
                      ),
                    ],
                  ),
                ),
                Padding(
                  padding: EdgeInsets.all(16.0),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        '비침',
                        style: TextStyle(
                          fontSize: 16.0,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                      SizedBox(height: 8.0),
                      Wrap(
                        spacing: 8.0,
                        runSpacing: 8.0,
                        children: Transparency.values.map((transparency) => Row(
                          mainAxisSize: MainAxisSize.min,
                          children: [
                            Radio<Transparency>(
                              value: transparency,
                              groupValue: _selectedTransparency,
                              onChanged: (value) => setState(() => _selectedTransparency = value),
                            ),
                            Text(transparencyLabels[transparency]!),
                          ],
                        )).toList(),
                      ),
                    ],
                  ),
                ),
                Padding(
                  padding: EdgeInsets.all(16.0),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        '촉감',
                        style: TextStyle(
                          fontSize: 16.0,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                      SizedBox(height: 8.0),
                      Wrap(
                        spacing: 8.0,
                        runSpacing: 8.0,
                        children: ClothingTexture.values.map((texture) => Row(
                          mainAxisSize: MainAxisSize.min,
                          children: [
                            Radio<ClothingTexture>(
                              value: texture,
                              groupValue: _selectedClothingTexture,
                              onChanged: (value) => setState(() => _selectedClothingTexture = value),
                            ),
                            Text(textureLabels[texture]!),
                          ],
                        )).toList(),
                      ),
                    ],
                  ),
                ),
                Padding(
                  padding: EdgeInsets.all(16.0),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        '핏감',
                        style: TextStyle(
                          fontSize: 16.0,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                      SizedBox(height: 8.0),
                      Wrap(
                        spacing: 8.0,
                        runSpacing: 8.0,
                        children: Fit.values.map((fit) => Row(
                          mainAxisSize: MainAxisSize.min,
                          children: [
                            Radio<Fit>(
                              value: fit,
                              groupValue: _selectedFit,
                              onChanged: (value) => setState(() => _selectedFit = value),
                            ),
                            Text(fitLabels[fit]!),
                          ],
                        )).toList(),
                      ),
                    ],
                  ),
                ),
                Padding(
                  padding: EdgeInsets.all(16.0),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        '두께감',
                        style: TextStyle(
                          fontSize: 16.0,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                      SizedBox(height: 8.0),
                      Wrap(
                        spacing: 8.0,
                        runSpacing: 8.0,
                        children: Thickness.values.map((thickness) => Row(
                          mainAxisSize: MainAxisSize.min,
                          children: [
                            Radio<Thickness>(
                              value: thickness,
                              groupValue: _selectedThickness,
                              onChanged: (value) => setState(() => _selectedThickness = value),
                            ),
                            Text(thicknessLabels[thickness]!),
                          ],
                        )).toList(),
                      ),
                    ],
                  ),
                ),
                Padding(
                  padding: EdgeInsets.all(16.0),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        '계절감',
                        style: TextStyle(
                          fontSize: 16.0,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                      SizedBox(height: 8.0),
                      Wrap(
                        spacing: 8.0,
                        runSpacing: 8.0,
                        children: Season.values.map((season) => Row(
                          mainAxisSize: MainAxisSize.min,
                          children: [
                            Radio<Season>(
                              value: season,
                              groupValue: _selectedSeason,
                              onChanged: (value) => setState(() => _selectedSeason = value),
                            ),
                            Text(seasonLabels[season]!),
                          ],
                        )).toList(),
                      ),
                    ],
                  ),
                ),
                Padding(
                  padding: EdgeInsets.symmetric(horizontal: 16.0),
                  child: ElevatedButton(
                    onPressed: _saveDetails,
                    style: ButtonStyle(
                      backgroundColor: MaterialStateProperty.all(Colors.black87),  // 배경색 설정
                      foregroundColor: MaterialStateProperty.all(Colors.white),  // 텍스트 및 아이콘 색상 설정
                      shape: MaterialStateProperty.all(  // 버튼 모양 설정
                        RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(20.0),  // 모서리 둥글기 설정
                        ),
                      ),
                      elevation: MaterialStateProperty.all(8.0),  // 그림자 높이 설정
                      padding: MaterialStateProperty.all(  // 내부 여백 설정
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

  @override
  void dispose() {
    _controllers.values.forEach((controller) => controller.dispose());
    super.dispose();
  }
}