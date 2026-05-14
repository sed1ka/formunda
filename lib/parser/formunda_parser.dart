import 'package:formunda/condition/formunda_condition.dart';
import 'package:formunda/models/formunda_field_node.dart';
import 'package:formunda/models/formunda_group_node.dart';
import 'package:formunda/models/formunda_node.dart';
import 'package:formunda/models/formunda_text_node.dart';
import 'package:formunda/models/formunda_image_node.dart';
import 'package:formunda/models/formunda_spacer_node.dart';
import 'package:formunda/models/formunda_separator_node.dart';
import 'package:formunda/models/formunda_table_node.dart';
import 'package:formunda/models/formunda_button_node.dart';
import 'package:formunda/models/formunda_html_node.dart';
import 'package:formunda/models/formunda_iframe_node.dart';


class FormundaParser {
  static List<FormundaNode> parse(List data) {
    return data.map((e) => _parseNode(e)).toList();
  }

  static FormundaNode _parseNode(Map<String, dynamic> json) {
    final type = json['type'];
    final id = json['id'] ?? '';
    final condition = FormundaCondition.fromJson(json['condition']);

    switch (type) {
      case 'group':
      case 'dynamiclist':
        return FormundaGroupNode(
          id: id,
          type: type,
          label: json['label'],
          showOutline: json['showOutline'],
          condition: condition,
          children: parse(json['components'] ?? []),
        );

      case 'text':
        return FormundaTextNode(
          id: id,
          text: json['text'] ?? '',
          condition: condition,
        );

      case 'image':
        return FormundaImageNode(
          id: id,
          source: json['source'],
          alt: json['alt'],
          condition: condition,
        );

      case 'html':
        return FormundaHtmlNode(
          id: id,
          content: json['content'],
          condition: condition,
        );

      case 'iframe':
        return FormundaIFrameNode(
          id: id,
          url: json['url'],
          height: (json['height'] as num?)?.toDouble(),
          condition: condition,
        );

      case 'spacer':
        return FormundaSpacerNode(
          id: id,
          height: (json['height'] as num?)?.toDouble(),
          condition: condition,
        );

      case 'separator':
        return FormundaSeparatorNode(
          id: id,
          condition: condition,
        );

      case 'table':
        final cols = (json['columns'] as List? ?? [])
            .map((c) => FormundaTableColumn(
                  label: c['label'] ?? '',
                  key: c['key'] ?? '',
                ))
            .toList();
        return FormundaTableNode(
          id: id,
          label: json['label'],
          columns: cols,
          dataSource: json['dataSource'],
          condition: condition,
        );

      case 'button':
        return FormundaButtonNode(
          id: id,
          label: json['label'],
          action: json['action'],
          condition: condition,
        );

      default:
        return FormundaFieldNode(
          id: id,
          type: type,
          key: json['key'],
          label: json['label'],
          description: json['description'],
          defaultValue: json['defaultValue'],
          values: json['values'],
          validate: json['validate'],
          subtype: json['subtype'],
          dateLabel: json['dateLabel'],
          min: json['min'],
          max: json['max'],
          step: json['step'],
          appearance: json['appearance'],
          condition: condition,
        );
    }
  }
}
