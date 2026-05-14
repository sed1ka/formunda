import 'formunda_node.dart';

class FormundaIFrameNode extends FormundaNode {
  final String? url;
  final double? height;

  const FormundaIFrameNode({
    required super.id,
    super.condition,
    this.url,
    this.height,
  }) : super(type: 'iframe');

  @override
  bool operator ==(Object other) {
    if (identical(this, other)) return true;
    if (other.runtimeType != runtimeType) return false;
    return other is FormundaIFrameNode &&
        super == other &&
        other.url == url &&
        other.height == height;
  }

  @override
  int get hashCode => Object.hash(super.hashCode, url, height);
}
