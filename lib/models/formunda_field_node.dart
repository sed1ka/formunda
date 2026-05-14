import 'package:flutter/foundation.dart';
import 'formunda_node.dart';

class FormundaFieldNode extends FormundaNode {
  final String? label;
  final String? description;
  final dynamic defaultValue;
  final List<dynamic>? values;
  final Map<String, dynamic>? validate;
  final String? subtype;
  final String? dateLabel;
  final num? min;
  final num? max;
  final num? step;
  final String? appearance;

  const FormundaFieldNode({
    required super.id,
    required super.type,
    super.key,
    super.condition,
    this.label,
    this.description,
    this.defaultValue,
    this.values,
    this.validate,
    this.subtype,
    this.dateLabel,
    this.min,
    this.max,
    this.step,
    this.appearance,
  });

  @override
  bool operator ==(Object other) {
    if (identical(this, other)) return true;
    if (other.runtimeType != runtimeType) return false;
    return other is FormundaFieldNode &&
        super == other &&
        other.label == label &&
        other.description == description &&
        other.defaultValue == defaultValue &&
        listEquals(other.values, values) &&
        mapEquals(other.validate, validate) &&
        other.subtype == subtype &&
        other.dateLabel == dateLabel &&
        other.min == min &&
        other.max == max &&
        other.step == step &&
        other.appearance == appearance;
  }

  @override
  int get hashCode => Object.hashAll([
        super.hashCode,
        label,
        description,
        defaultValue,
        values,
        validate,
        subtype,
        dateLabel,
        min,
        max,
        step,
        appearance,
      ]);
}
