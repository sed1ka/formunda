import 'dart:async';
import 'package:flutter/material.dart';

class FormundaController extends ChangeNotifier {
  final Map<String, dynamic> _values = {};
  
  /// Menyimpan FocusNode untuk setiap field agar bisa dikontrol secara programatik
  final Map<String, FocusNode> _focusNodes = {};
  
  final _fieldStreamController = StreamController<String>.broadcast();
  Stream<String> get fieldStream => _fieldStreamController.stream;

  Function(String key, dynamic value)? onChanged;

  dynamic getValue(String key) => _values[key];

  void setValue(String key, dynamic value, {bool batchUpdate = false}) {
    if (_values[key] == value) return;
    _values[key] = value;
    _fieldStreamController.add(key);
    onChanged?.call(key, value);
    if (!batchUpdate) notifyListeners();
  }

  /// Mendaftarkan FocusNode ke dalam registry controller
  void registerFocusNode(String id, FocusNode node) {
    _focusNodes[id] = node;
  }

  /// Fungsi untuk scroll ke field secara aman tanpa perhitungan piksel manual.
  /// Cara kerjanya: Memberikan fokus ke field tersebut, 
  /// lalu field tersebut akan otomatis memastikan dirinya terlihat di layar.
  void scrollToField(String id) {
    final node = _focusNodes[id];
    if (node != null) {
      node.requestFocus();
    }
  }

  Map<String, dynamic> get values => _values;

  @override
  void dispose() {
    _fieldStreamController.close();
    // FocusNode di-dispose oleh widget yang memilikinya, 
    // tapi kita bersihkan registry di sini.
    _focusNodes.clear();
    super.dispose();
  }
}
