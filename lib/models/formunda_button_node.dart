import 'formunda_node.dart';

class FormundaButtonNode extends FormundaNode {
  final String? label;
  final String? action;

  const FormundaButtonNode({
    required super.id,
    super.condition,
    this.label,
    this.action,
  }) : super(type: 'button');

  @override
  bool operator ==(Object other) {
    if (identical(this, other)) return true;
    if (other.runtimeType != runtimeType) return false;
    return other is FormundaButtonNode &&
        super == other &&
        other.label == label &&
        other.action == action;
  }

  @override
  int get hashCode => Object.hash(super.hashCode, label, action);
}
