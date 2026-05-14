import 'formunda_node.dart';

class FormundaImageNode extends FormundaNode {
  final String? source;
  final String? alt;

  const FormundaImageNode({
    required super.id,
    super.condition,
    this.source,
    this.alt,
  }) : super(type: 'image');

  @override
  bool operator ==(Object other) {
    if (identical(this, other)) return true;
    if (other.runtimeType != runtimeType) return false;
    return other is FormundaImageNode &&
        super == other &&
        other.source == source &&
        other.alt == alt;
  }

  @override
  int get hashCode => Object.hash(super.hashCode, source, alt);
}
