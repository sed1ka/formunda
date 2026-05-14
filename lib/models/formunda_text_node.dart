import 'formunda_node.dart';

class FormundaTextNode extends FormundaNode {
  final String text;

  const FormundaTextNode({
    required super.id,
    required this.text,
    super.condition,
  }) : super(type: 'text');

  @override
  bool operator ==(Object other) {
    if (identical(this, other)) return true;
    if (other.runtimeType != runtimeType) return false;
    return other is FormundaTextNode && super == other && other.text == text;
  }

  @override
  int get hashCode => Object.hash(super.hashCode, text);
}
