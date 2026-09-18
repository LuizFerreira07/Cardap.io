import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';

class StoreSettingsProvider extends ChangeNotifier {
  static const _key = 'store_settings_v1';

  String name = 'Boteco da Vila — Grill & Bar';
  String description = 'Hambúrgueres na chapa, carnes na brasa e chope gelado. Desde 2014, na esquina da praça.';
  String phone = '+55 (55) 3312-4477';
  String openTime = '18:00';
  String closeTime = '23:30';
  String closedDay = 'Segunda-feira';
  double deliveryFee = 7.90;
  String pixKey = '';

  bool _loading = true;
  bool get isLoading => _loading;

  StoreSettingsProvider() {
    _load();
  }

  Future<void> _load() async {
    final prefs = await SharedPreferences.getInstance();
    final raw = prefs.getString(_key);
    if (raw != null) {
      final json = jsonDecode(raw) as Map<String, dynamic>;
      name = json['name'] as String? ?? name;
      description = json['description'] as String? ?? description;
      phone = json['phone'] as String? ?? phone;
      openTime = json['openTime'] as String? ?? openTime;
      closeTime = json['closeTime'] as String? ?? closeTime;
      closedDay = json['closedDay'] as String? ?? closedDay;
      deliveryFee = (json['deliveryFee'] as num?)?.toDouble() ?? deliveryFee;
      pixKey = json['pixKey'] as String? ?? pixKey;
    }
    _loading = false;
    notifyListeners();
  }

  Future<void> save({
    required String name,
    required String description,
    required String phone,
    required String openTime,
    required String closeTime,
    required String closedDay,
    required double deliveryFee,
    required String pixKey,
  }) async {
    this.name = name;
    this.description = description;
    this.phone = phone;
    this.openTime = openTime;
    this.closeTime = closeTime;
    this.closedDay = closedDay;
    this.deliveryFee = deliveryFee;
    this.pixKey = pixKey.trim();

    final prefs = await SharedPreferences.getInstance();
    await prefs.setString(
      _key,
      jsonEncode({
        'name': name,
        'description': description,
        'phone': phone,
        'openTime': openTime,
        'closeTime': closeTime,
        'closedDay': closedDay,
        'deliveryFee': deliveryFee,
        'pixKey': pixKey.trim(),
      }),
    );
    notifyListeners();
  }
}
