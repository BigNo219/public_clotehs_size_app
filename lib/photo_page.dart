import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:provider/provider.dart';
import 'package:ddundddun/models/category_form.dart';

class PhotoPage extends StatelessWidget {
  final String imageUrl;
  final String category;
  final String imageId;

  PhotoPage({required this.imageUrl, required this.category, required this.imageId});

  @override
  Widget build(BuildContext context) {
    return ChangeNotifierProvider(
      create: (_) => PhotoPageModel(imageId, category),
      child: Scaffold(
        appBar: AppBar(title: Text('Photo Details')),
        body: Consumer<PhotoPageModel>(
          builder: (context, model, child) {
            if (model.isLoading) {
              return Center(child: CircularProgressIndicator());
            }

            if (model.hasError) {
              return Center(child: Text('Error: ${model.errorMessage}'));
            }

            final fields = categoryForms[category];
            if (fields == null) {
              return Center(child: Text('해당 카테고리에 대한 정보가 없습니다.'));
            }

            return SingleChildScrollView(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.stretch,
                children: [
                  Image.network(imageUrl),
                  ...fields.map((field) => Padding(
                    padding: EdgeInsets.all(16.0),
                    child: TextField(
                      controller: model.controllers[field],
                      decoration: InputDecoration(
                        labelText: field,
                        border: OutlineInputBorder(),
                      ),
                      keyboardType: TextInputType.number,
                    ),
                  )).toList(),
                  _buildOptionSection(context, '안감', 'Lining', Lining.values, liningLabels, model),
                  _buildOptionSection(context, '신축성', 'Elasticity', Elasticity.values, elasticityLabels, model),
                  _buildOptionSection(context, '비침', 'Transparency', Transparency.values, transparencyLabels, model),
                  _buildOptionSection(context, '촉감', 'ClothingTexture', ClothingTexture.values, textureLabels, model),
                  _buildOptionSection(context, '핏감', 'Fit', Fit.values, fitLabels, model),
                  _buildOptionSection(context, '두께감', 'Thickness', Thickness.values, thicknessLabels, model),
                  _buildOptionSection(context, '계절감', 'Season', Season.values, seasonLabels, model),
                  Padding(
                    padding: EdgeInsets.symmetric(horizontal: 16.0),
                    child: ElevatedButton(
                      onPressed: () => model.saveDetails(context),
                      child: Text('저장'),
                    ),
                  ),
                ],
              ),
            );
          },
        ),
      ),
    );
  }

  Widget _buildOptionSection(
      BuildContext context,
      String label,
      String listLabel,
      List<dynamic> values,
      Map<dynamic, String> labels,
      PhotoPageModel model,
      ) {

    return Padding(
      padding: EdgeInsets.all(16.0),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            label,
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
                Radio(
                  value: value,
                  groupValue: model.selectedOptions[listLabel.toLowerCase()],
                  onChanged: (newValue) => model.updateOption(listLabel.toLowerCase(), newValue),
                ),
                Text(labels[value]!),
              ],
            )).toList(),
          ),
        ],
      ),
    );
  }
}

class PhotoPageModel extends ChangeNotifier {
  final String imageId;
  late Map<String, TextEditingController> _controllers;
  late Map<String, dynamic> _selectedOptions;

  PhotoPageModel(this.imageId, String category) {
    _controllers = {
      for (var field in categoryForms[category]!) field: TextEditingController(),
    };
    _selectedOptions = {
      'lining': null,
      'elasticity': null,
      'transparency': null,
      'texture': null,
      'fit': null,
      'thickness': null,
      'season': null,
    };
    _loadInitialData(imageId, category);
  }

  bool get isLoading => _isLoading;
  bool _isLoading = true;

  bool get hasError => _hasError;
  bool _hasError = false;
  String _errorMessage = '';
  String get errorMessage => _errorMessage;

  Map<String, TextEditingController> get controllers => _controllers;

  Map<String, dynamic> get selectedOptions => _selectedOptions;

  Future<void> _loadInitialData(String imageId, String category) async {
    try {
      final docSnapshot = await FirebaseFirestore.instance.collection('images').doc(imageId).get();
      final data = docSnapshot.data() as Map<String, dynamic>?;

      if (data != null) {
        _controllers = {
          for (var field in categoryForms[category]!) field: TextEditingController(text: data[field]?.toString() ?? ''),
        };

        _selectedOptions = {
          'lining': data['lining'] != null ? Lining.values.firstWhere((e) => e.toString().split('.').last == data['lining'], orElse: () => Lining.no) : null,
          'elasticity': data['elasticity'] != null ? Elasticity.values.firstWhere((e) => e.toString().split('.').last == data['elasticity'], orElse: () => Elasticity.none) : null,
          'transparency': data['transparency'] != null ? Transparency.values.firstWhere((e) => e.toString().split('.').last == data['transparency'], orElse: () => Transparency.yes) : null,
          'texture': data['texture'] != null ? ClothingTexture.values.firstWhere((e) => e.toString().split('.').last == data['texture'], orElse: () => ClothingTexture.soft) : null,
          'fit': data['fit'] != null ? Fit.values.firstWhere((e) => e.toString().split('.').last == data['fit'], orElse: () => Fit.tight) : null,
          'thickness': data['thickness'] != null ? Thickness.values.firstWhere((e) => e.toString().split('.').last == data['thickness'], orElse: () => Thickness.thin) : null,
          'season': data['season'] != null ? Season.values.firstWhere((e) => e.toString().split('.').last == data['season'], orElse: () => Season.winter) : null,
        };

        print(_selectedOptions);
      }
    } catch (e) {
      _hasError = true;
      _errorMessage = e.toString();
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }

  void updateOption(String key, dynamic value) {
    _selectedOptions[key] = value;
    notifyListeners();
  }

  Future<void> saveDetails(BuildContext context) async {
    final data = {
      for (var field in _controllers.keys) field: int.parse(_controllers[field]!.text),
      'lining': _selectedOptions['lining'].toString().split('.').last ?? '',
      'elasticity': _selectedOptions['elasticity'].toString().split('.').last ?? '',
      'transparency': _selectedOptions['transparency'].toString().split('.').last ?? '',
      'texture': _selectedOptions['texture'].toString().split('.').last ?? '',
      'fit': _selectedOptions['fit'].toString().split('.').last ?? '',
      'thickness': _selectedOptions['thickness'].toString().split('.').last ?? '',
      'season': _selectedOptions['season'].toString().split('.').last ?? '',
    };

    try {
      await FirebaseFirestore.instance.collection('images').doc(imageId).update(data);
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('정보 저장 완료.')),
      );
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('저장 중 오류 발생: $e')),
      );
    }
  }

  @override
  void dispose() {
    _controllers.values.forEach((controller) => controller.dispose());
    super.dispose();
  }
}