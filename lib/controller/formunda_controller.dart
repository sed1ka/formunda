import 'dart:async';
import 'package:flutter/material.dart';

class FormundaController extends ChangeNotifier {
  final Map<String, dynamic> _values = {};
  
  // Stream untuk melisten perubahan spesifik pada key tertentu
  final _fieldStreamController = StreamController<String>.broadcast();
  Stream<String> get fieldStream => _fieldStreamController.stream;

  Function(String key, dynamic value)? onChanged;

  dynamic getValue(String key) => _values[key];

  /// Mengupdate nilai tanpa memicu notifyListeners() global jika tidak perlu.
  /// [batchUpdate] digunakan jika kita ingin melakukan banyak perubahan sekaligus baru kemudian merender ulang.
  void setValue(String key, dynamic value, {bool batchUpdate = false}) {
    if (_values[key] == value) return;
    _values[key] = value;
    
    // Beritahu listener spesifik key ini (untuk performa)
    _fieldStreamController.add(key);
    
    onChanged?.call(key, value);
    
    // Hanya panggil notifyListeners (global rebuild) jika ada perubahan struktur 
    // atau jika dipaksa (misal untuk conditional visibility global)
    if (!batchUpdate) {
      notifyListeners();
    }
  }

  Map<String, dynamic> get values => _values;

  void submit() {
    debugPrint("Form Submitted: $_values");
  }

  @override
  void dispose() {
    _fieldStreamController.close();
    super.dispose();
  }
}
