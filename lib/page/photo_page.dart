import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:ddundddun/models/category_form.dart';
import '../models/radio_view_model.dart';
import '../widgets/custom_divider_widget.dart';
import 'package:provider/provider.dart';
import 'package:cached_network_image/cached_network_image.dart';
import '../widgets/radio_group_widget.dart';
import '../widgets/radio_more_check_group_widget.dart';

class PhotoPage extends StatefulWidget {
  final String imageUrl;
  final String category;
  final String imageId;

  PhotoPage({required this.imageUrl, required this.category, required this.imageId});

  @override
  _PhotoPageState createState() => _PhotoPageState();
}

class _PhotoPageState extends State<PhotoPage> {
  late Map<String, TextEditingController> _controllers;
  final ScrollController _scrollController = ScrollController();

  @override
  void initState() {
    super.initState();
    _controllers = {
      'title': TextEditingController(),
      'description': TextEditingController(),
    };
    _fetchDataFromFireStore();
  }

  Future<void> _saveDetails(RadioViewModel viewModel) async {
    try {
      final fields = CategoryInfo.categoryForms[widget.category] ?? [];

      final data = {
        'title': _controllers['title']!.text,
        'customerName': _controllers['customerName']!.text,
        'description': _controllers['description']!.text,
        for (var field in fields)
          field: _controllers[field]?.text.isNotEmpty == true ? double.parse(
              _controllers[field]!.text) : null,
        'lining': viewModel.selectedLining
            ?.toString()
            .split('.')
            .last ?? '',
        'elasticity': viewModel.selectedElasticity
            ?.toString()
            .split('.')
            .last ?? '',
        'transparency': viewModel.selectedTransparency
            ?.toString()
            .split('.')
            .last ?? '',
        'texture': viewModel.selectedClothingTexture
            ?.toString()
            .split('.')
            .last ?? '',
        'fit': viewModel.selectedFit
            ?.toString()
            .split('.')
            .last ?? '',
        'thickness': viewModel.selectedThickness
            ?.toString()
            .split('.')
            .last ?? '',
        'seasons': viewModel.selectedSeasons
            ?.map((season) => season.toString().split('.').last)
            .toList() ?? [],
      };

      await FirebaseFirestore.instance.collection('images')
          .doc(widget.imageId)
          .update(data);

      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('사이즈 및 상세내용이 저장되었습니다.')),
      );
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('저장에 실패했습니다: $e')),
      );
    }
  }

  Future<void> _fetchDataFromFireStore() async {
    final viewModel = context.read<RadioViewModel>();
    await viewModel.initializeFromFirestore(widget.imageId);
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text(
          'SIZE & DETAIL',
          style: TextStyle(color: Colors.white),
      ),
        backgroundColor: Colors.grey,
      ),
      body: StreamBuilder<DocumentSnapshot>(
        stream: FirebaseFirestore.instance.collection('images').doc(widget.imageId).snapshots(),
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) {
            return const Center(child: CircularProgressIndicator());
          }

          if (snapshot.hasError) {
            return Center(child: Text('Error: ${snapshot.error}'));
          }

          final imageData = snapshot.data!.data() as Map<String, dynamic>?;
          final imageUrl = widget.imageUrl;

          final fields = CategoryInfo.categoryForms[widget.category];

          if (fields == null) {
            return const Center(child: Text('해당 카테고리에 대한 정보가 없습니다.'));
          }

          _controllers = {
            'title': TextEditingController(text: imageData?['title'] ?? ''),
            'customerName': TextEditingController(text: imageData?['customerName'] ?? ''),
            'description': TextEditingController(text: imageData?['description'] ?? ''),
            for (var field in fields) field: TextEditingController(text: imageData?[field]?.toString() ?? ''),
          };

          return SingleChildScrollView(
            controller: _scrollController,
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                CachedNetworkImage(
                  imageUrl: imageUrl,
                  width: 300.0,
                  height: 300.0,
                  fit: BoxFit.cover,
                  placeholder: (context, url) => const CircularProgressIndicator(),
                  errorWidget: (context, url, error) => const Icon(Icons.error),
                ),
                _buildMultilineTextField('title', '제목'),
                _buildMultilineTextField('customerName', '거래처 명'),
                _buildMultilineTextField('description', '추가 정보'),
                ...fields.map((field) => _buildTextField(field, field)).toList(),
                Consumer<RadioViewModel>(
                  builder: (context, viewModel, child) {
                    return Column(
                      children: [
                        RadioGroupWidget<Lining>(
                          title: '안감',
                          values: Lining.values,
                          labels: CategoryInfo.liningLabels,
                          selectedValue: viewModel.selectedLining,
                          onChanged: viewModel.setSelectedLining,
                        ),
                        CustomDivider(),
                        RadioGroupWidget<Elasticity>(
                          title: '신축성',
                          values: Elasticity.values,
                          labels: CategoryInfo.elasticityLabels,
                          selectedValue: viewModel.selectedElasticity,
                          onChanged: viewModel.setSelectedElasticity,
                        ),
                        CustomDivider(),
                        RadioGroupWidget<Transparency>(
                          title: '비침',
                          values: Transparency.values,
                          labels: CategoryInfo.transparencyLabels,
                          selectedValue: viewModel.selectedTransparency,
                          onChanged: viewModel.setSelectedTransparency,
                        ),
                        CustomDivider(),
                        RadioGroupWidget<ClothingTexture>(
                          title: '촉감',
                          values: ClothingTexture.values,
                          labels: CategoryInfo.textureLabels,
                          selectedValue: viewModel.selectedClothingTexture,
                          onChanged: viewModel.setSelectedClothingTexture,
                        ),
                        CustomDivider(),
                        RadioGroupWidget<Fit>(
                          title: '핏감',
                          values: Fit.values,
                          labels: CategoryInfo.fitLabels,
                          selectedValue: viewModel.selectedFit,
                          onChanged: viewModel.setSelectedFit,
                        ),
                        CustomDivider(),
                        RadioGroupWidget<Thickness>(
                          title: '두께감',
                          values: Thickness.values,
                          labels: CategoryInfo.thicknessLabels,
                          selectedValue: viewModel.selectedThickness,
                          onChanged: viewModel.setSelectedThickness,
                        ),
                        CustomDivider(),
                        MoreCheckboxGroupWidget<Season>(
                          title: '계절감',
                          values: Season.values,
                          labels: CategoryInfo.seasonLabels,
                          selectedValues: viewModel.selectedSeasons ?? [],
                          onChanged: viewModel.setSelectedSeasons,
                        ),
                        CustomDivider(),
                      ],
                    );
                  },
                ),
                Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 16.0),
                  child: ElevatedButton(
                    onPressed: () => _saveDetails(context.read<RadioViewModel>()),
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
                        const EdgeInsets.symmetric(vertical: 16.0, horizontal: 24.0),
                      ),
                    ),
                    child: const Text('SAVE DETAILS'),
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
      padding: const EdgeInsets.all(16.0),
      child: TextField(
        controller: _controllers[field],
        decoration: InputDecoration(
          labelText: label,
          labelStyle: const TextStyle(
            fontFamily: 'KoreanFont',
            fontSize: 14,
            fontWeight: FontWeight.bold,
          ),
          border: const OutlineInputBorder(),
        ),
        style: const TextStyle(
          fontFamily: 'KoreanFont',
          fontSize: 14,
        ),
        keyboardType: const TextInputType.numberWithOptions(decimal: true),
      ),
    );
  }

  Widget _buildMultilineTextField(String field, String label) {
    return Padding(
      padding: const EdgeInsets.all(18.0),
      child: TextField(
        controller: _controllers[field],
        decoration: InputDecoration(
          labelText: label,
          labelStyle: const TextStyle(
            fontFamily: 'KoreanFont',
            fontSize: 14,
            fontWeight: FontWeight.bold,
          ),
          border: const OutlineInputBorder(),
          contentPadding: const EdgeInsets.symmetric(vertical: 20.0, horizontal: 10.0),
        ),
        maxLines: null,
        keyboardType: TextInputType.multiline,
        style: const TextStyle(height: 1.0, fontFamily: 'KoreanFont'),
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