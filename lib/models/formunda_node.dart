import '../condition/formunda_condition.dart';

abstract class FormundaNode {
  final String id;
  final String type;
  final String? key;
  final FormundaCondition? condition;

  FormundaNode({
    required this.id,
    required this.type,
    this.key,
    this.condition,
  });
}