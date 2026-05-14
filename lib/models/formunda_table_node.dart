import 'package:flutter/foundation.dart';
import 'formunda_node.dart';

class FormundaTableNode extends FormundaNode {
  final String? label;
  final List<FormundaTableColumn> columns;
  final String? dataSource;

  const FormundaTableNode({
    required super.id,
    super.condition,
    this.label,
    required this.columns,
    this.dataSource,
  }) : super(type: 'table');

  @override
  bool operator ==(Object other) {
    if (identical(this, other)) return true;
    if (other.runtimeType != runtimeType) return false;
    return other is FormundaTableNode &&
        super == other &&
        other.label == label &&
        listEquals(other.columns, columns) &&
        other.dataSource == dataSource;
  }

  @override
  int get hashCode => Object.hash(super.hashCode, label, Object.hashAll(columns), dataSource);
}

class FormundaTableColumn {
  final String label;
  final String key;

  const FormundaTableColumn({required this.label, required this.key});

  @override
  bool operator ==(Object other) {
    if (identical(this, other)) return true;
    if (other is! FormundaTableColumn) return false;
    return other.label == label && other.key == key;
  }

  @override
  int get hashCode => Object.hash(label, key);
}
