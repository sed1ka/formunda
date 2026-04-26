import 'formunda_node.dart';

class FormundaGroupNode extends FormundaNode {
  final List<FormundaNode> children;
  final String? label;
  final bool? showOutline;

  FormundaGroupNode({
    required super.id,
    required super.type,
    required this.children,
    this.showOutline,
    this.label,
    super.condition,
  });
}