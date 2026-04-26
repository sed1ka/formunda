import 'package:flutter/widgets.dart';
import 'package:formunda/controller/formunda_controller.dart';
import 'package:formunda/models/formunda_field_node.dart';
import 'package:formunda/parser/formunda_parser.dart' show FormundaParser;
import 'package:formunda/renderer/formunda_renderer.dart' show FormundaRenderer;

enum RenderMode { column, listView, sliverList }

typedef FormundaCustomBuilder = Widget Function(
  BuildContext context,
  FormundaFieldNode node,
  FormundaController controller,
);

class FormundaWidget extends StatelessWidget {
  final Map<String, dynamic> data;
  final FormundaController controller;
  final bool shrinkWrap;
  final RenderMode renderMode;
  
  /// Memungkinkan user mengganti widget bawaan dengan widget custom mereka sendiri
  /// Contoh: {'textfield': (context, node, ctrl) => MyCustomTextField(...)}
  final Map<String, FormundaCustomBuilder>? customWidgetBuilder;

  FormundaWidget({
    super.key,
    required this.data,
    FormundaController? controller,
    this.shrinkWrap = false,
    this.renderMode = RenderMode.column,
    this.customWidgetBuilder,
  }) : controller = controller ?? FormundaController();

  @override
  Widget build(BuildContext context) {
    // Parsing dilakukan di build, namun untuk kesempurnaan performa pada form statis, 
    // idealnya data diparse sekali saja di level State. 
    // Namun untuk flexibilitas, kita biarkan di sini dengan asumsi data tidak sering berubah.
    final parsedNodes = FormundaParser.parse(this.data['components'] ?? []);

    return FormundaRenderer(
      data: parsedNodes, 
      controller: controller,
      customWidgetBuilder: customWidgetBuilder,
    );
  }
}
