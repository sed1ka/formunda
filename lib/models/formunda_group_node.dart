import 'package:flutter/foundation.dart';
import 'formunda_node.dart';

class FormundaGroupNode extends FormundaNode {
  final List<FormundaNode> children;
  final String? label;
  final bool? showOutline;

  const FormundaGroupNode({
    required super.id,
    required super.type,
    required this.children,
    this.showOutline,
    this.label,
    super.condition,
  });

  @override
  bool operator ==(Object other) {
    if (identical(this, other)) return true;
    if (other.runtimeType != runtimeType) return false;
    return other is FormundaGroupNode &&
        super == other &&
        listEquals(other.children, children) &&
        other.label == label &&
        other.showOutline == showOutline;
  }

  @override
  int get hashCode => Object.hash(super.hashCode, Object.hashAll(children), label, showOutline);
}
