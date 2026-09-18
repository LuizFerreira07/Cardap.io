import 'package:flutter/material.dart';

class FavoritesProvider extends ChangeNotifier {
  final Set<String> _ids = {};

  bool isFavorite(String menuItemId) => _ids.contains(menuItemId);

  void toggle(String menuItemId) {
    if (_ids.contains(menuItemId)) {
      _ids.remove(menuItemId);
    } else {
      _ids.add(menuItemId);
    }
    notifyListeners();
  }
}
