import 'package:flutter/foundation.dart';
import 'package:ddundddun/models/category_form.dart';
import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';

class RadioViewModel extends ChangeNotifier {
  Lining? _selectedLining;
  Elasticity? _selectedElasticity;
  Transparency? _selectedTransparency;
  ClothingTexture? _selectedClothingTexture;
  Fit? _selectedFit;
  Thickness? _selectedThickness;
  // Season? _selectedSeason;

  Lining? get selectedLining => _selectedLining;
  Elasticity? get selectedElasticity => _selectedElasticity;
  Transparency? get selectedTransparency => _selectedTransparency;
  ClothingTexture? get selectedClothingTexture => _selectedClothingTexture;
  Fit? get selectedFit => _selectedFit;
  Thickness? get selectedThickness => _selectedThickness;
  // Season? get selectedSeason => _selectedSeason;

  List<Season>? _selectedSeasons;
  List<Season>? get selectedSeasons => _selectedSeasons;


  final ScrollController scrollController = ScrollController();

  void setSelectedLining(Lining? value) {
    _selectedLining = value;
    notifyListeners();
  }

  void setSelectedElasticity(Elasticity? value) {
    _selectedElasticity = value;
    notifyListeners();
  }

  void setSelectedTransparency(Transparency? value) {
    _selectedTransparency = value;
    notifyListeners();
  }

  void setSelectedClothingTexture(ClothingTexture? value) {
    _selectedClothingTexture = value;
    notifyListeners();
  }

  void setSelectedFit(Fit? value) {
    _selectedFit = value;
    notifyListeners();
  }

  void setSelectedThickness(Thickness? value) {
    _selectedThickness = value;
    notifyListeners();
  }

  void setSelectedSeasons(List<Season>? values) {
    // _selectedSeason = value;
    _selectedSeasons = values;
    notifyListeners();
  }

  Future<void> initializeFromFirestore(String imageId) async {
    final doc = await FirebaseFirestore.instance.collection('images').doc(imageId).get();
    final data = doc.data() as Map<String, dynamic>?;

    if (data != null) {
      setSelectedLining(Lining.values.firstWhereOrNull((e) => e.toString().split('.').last == data['lining']));
      setSelectedElasticity(Elasticity.values.firstWhereOrNull((e) => e.toString().split('.').last == data['elasticity']));
      setSelectedTransparency(Transparency.values.firstWhereOrNull((e) => e.toString().split('.').last == data['transparency']));
      setSelectedClothingTexture(ClothingTexture.values.firstWhereOrNull((e) => e.toString().split('.').last == data['texture']));
      setSelectedFit(Fit.values.firstWhereOrNull((e) => e.toString().split('.').last == data['fit']));
      setSelectedThickness(Thickness.values.firstWhereOrNull((e) => e.toString().split('.').last == data['thickness']));
      // setSelectedSeason(Season.values.firstWhereOrNull((e) => e.toString().split('.').last == data['season']));

      final dynamic seasonsData = data['seasons'] ?? data['season'];
      if (seasonsData is String) {
        final season = Season.values.firstWhereOrNull((e) => e.toString().split('.').last == seasonsData);
        setSelectedSeasons(season != null ? [season] : null);
      } else if (seasonsData is List<dynamic>) {
        setSelectedSeasons(seasonsData.map((s) => Season.values.firstWhereOrNull((e) => e.toString().split('.').last == s)).whereType<Season>().toList());
      } else {
        setSelectedSeasons(null);
      }
      // setSelectedSeasons((data['seasons'] as List<dynamic>?)?.map((s) => Season.values.firstWhereOrNull((e) => e.toString().split('.').last == s)).whereType<Season>().toList());
    }
  }
}

extension _FirstWhereOrNullExtension<E> on Iterable<E> {
  E? firstWhereOrNull(bool Function(E) test) {
    for (E element in this) {
      if (test(element)) return element;
    }
    return null;
  }
}