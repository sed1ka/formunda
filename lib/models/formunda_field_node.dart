import 'formunda_node.dart';

class FormundaFieldNode extends FormundaNode {
  final String? label;
  final dynamic defaultValue;
  final List<dynamic>? values;

  FormundaFieldNode({
    required super.id,
    required super.type,
    super.key,
    this.label,
    this.defaultValue,
    this.values,
    super.condition,
  });
}