import 'package:formunda/condition/formunda_condition.dart';
import 'package:formunda/models/formunda_field_node.dart';
import 'package:formunda/models/formunda_group_node.dart';
import 'package:formunda/models/formunda_node.dart';
import 'package:formunda/models/formunda_text_node.dart';


class FormundaParser {
  static List<FormundaNode> parse(List data) {
    return data.map((e) => _parseNode(e)).toList();
  }

  static FormundaNode _parseNode(Map<String, dynamic> json) {
    final type = json['type'];
    final condition = FormundaCondition.fromJson(json['condition']);

    if (type == 'group') {
      return FormundaGroupNode(
        id: json['id'],
        type: type,
        condition: condition,
        children: parse(json['components'] ?? []),
      );
    }

    if (type == 'text') {
      return FormundaTextNode(
        id: json['id'],
        text: json['text'] ?? '',
        condition: condition,
      );
    }

    return FormundaFieldNode(
      id: json['id'],
      type: type,
      key: json['key'],
      label: json['label'],
      defaultValue: json['defaultValue'],
      values: json['values'],
      condition: condition,
    );
  }
}