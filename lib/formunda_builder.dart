import 'package:flutter/widgets.dart';
import 'package:formunda/controller/formunda_controller.dart';
import 'package:formunda/parser/formunda_parser.dart' show FormundaParser;
import 'package:formunda/renderer/formunda_renderer.dart' show FormundaRenderer;


class FormundaBuilder extends StatelessWidget {
  final Map<String, dynamic> json;
  final FormundaController controller;

  FormundaBuilder({
    super.key,
    required this.json,
    FormundaController? controller,
  }) : controller = controller ?? FormundaController();

  @override
  Widget build(BuildContext context) {
    final nodes = FormundaParser.parse(json['components']);

    return FormundaRenderer(
      nodes: nodes,
      controller: controller,
    );
  }
}
