import 'formunda_node.dart';

class FormundaSeparatorNode extends FormundaNode {
  const FormundaSeparatorNode({
    required super.id,
    super.condition,
  }) : super(type: 'separator');
}
