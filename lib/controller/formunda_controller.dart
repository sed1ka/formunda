
import 'package:flutter/material.dart';

class FormundaController extends ChangeNotifier {
  final Map<String, dynamic> _values = {};

  Function(String key, dynamic value)? onChanged;

  dynamic getValue(String key) => _values[key];

  void setValue(String key, dynamic value) {
    if (_values[key] == value) return;
    _values[key] = value;
    onChanged?.call(key, value);
    notifyListeners();
  }

  Map<String, dynamic> get values => _values;

  void submit() {
    debugPrint("Form Submitted: $_values");
  }
}