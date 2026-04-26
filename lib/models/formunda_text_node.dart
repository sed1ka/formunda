import 'formunda_node.dart';

class FormundaTextNode extends FormundaNode {
  final String text;

  FormundaTextNode({
    required super.id,
    required this.text,
    super.condition,
  }) : super(type: 'text');
}