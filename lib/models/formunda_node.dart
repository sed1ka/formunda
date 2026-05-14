import '../condition/formunda_condition.dart';

abstract class FormundaNode {
  final String id;
  final String type;
  final String? key;
  final FormundaCondition? condition;

  const FormundaNode({
    required this.id,
    required this.type,
    this.key,
    this.condition,
  });

  @override
  bool operator ==(Object other) {
    if (identical(this, other)) return true;
    if (other.runtimeType != runtimeType) return false;
    return other is FormundaNode &&
        other.id == id &&
        other.type == type &&
        other.key == key &&
        other.condition == condition;
  }

  @override
  int get hashCode => Object.hash(id, type, key, condition);
}
