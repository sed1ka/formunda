import 'formunda_node.dart';

class FormundaSpacerNode extends FormundaNode {
  final double? height;

  const FormundaSpacerNode({
    required super.id,
    super.condition,
    this.height,
  }) : super(type: 'spacer');

  @override
  bool operator ==(Object other) {
    if (identical(this, other)) return true;
    if (other.runtimeType != runtimeType) return false;
    return other is FormundaSpacerNode && super == other && other.height == height;
  }

  @override
  int get hashCode => Object.hash(super.hashCode, height);
}
