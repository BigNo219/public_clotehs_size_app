import 'package:flutter/foundation.dart';
import 'package:ddundddun/models/category_form.dart';
import 'package:flutter/material.dart';

class RadioViewModel extends ChangeNotifier {
  Lining? _selectedLining;
  Elasticity? _selectedElasticity;
  Transparency? _selectedTransparency;
  ClothingTexture? _selectedClothingTexture;
  Fit? _selectedFit;
  Thickness? _selectedThickness;
  Season? _selectedSeason;

  Lining? get selectedLining => _selectedLining;
  Elasticity? get selectedElasticity => _selectedElasticity;
  Transparency? get selectedTransparency => _selectedTransparency;
  ClothingTexture? get selectedClothingTexture => _selectedClothingTexture;
  Fit? get selectedFit => _selectedFit;
  Thickness? get selectedThickness => _selectedThickness;
  Season? get selectedSeason => _selectedSeason;

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

  void setSelectedSeason(Season? value) {
    _selectedSeason = value;
    notifyListeners();
  }
}