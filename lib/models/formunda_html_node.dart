import 'formunda_node.dart';

class FormundaHtmlNode extends FormundaNode {
  final String? content;

  const FormundaHtmlNode({
    required super.id,
    super.condition,
    this.content,
  }) : super(type: 'html');

  @override
  bool operator ==(Object other) {
    if (identical(this, other)) return true;
    if (other.runtimeType != runtimeType) return false;
    return other is FormundaHtmlNode &&
        super == other &&
        other.content == content;
  }

  @override
  int get hashCode => Object.hash(super.hashCode, content);
}
