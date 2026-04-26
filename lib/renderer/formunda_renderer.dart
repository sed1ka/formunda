import 'package:flutter/material.dart';
import '../controller/formunda_controller.dart';
import '../models/formunda_node.dart';
import '../modes/render_mode.dart';
import '../formunda_builder.dart';
import 'formunda_widget_factory.dart';

class FormundaRenderer extends StatefulWidget {
  final List<FormundaNode> data;
  final FormundaController controller;
  final RenderMode renderMode;
  final FormundaCustomWidgetBuilder? customWidgetBuilder;

  const FormundaRenderer({
    super.key,
    required this.data,
    required this.controller,
    required this.renderMode,
    this.customWidgetBuilder,
  });

  @override
  State<FormundaRenderer> createState() => _FormundaRendererState();
}

class _FormundaRendererState extends State<FormundaRenderer> {
  late FormundaWidgetFactory _wf;

  @override
  void initState() {
    super.initState();
    _wf = FormundaWidgetFactory(
      widget.controller,
      customWidgetBuilder: widget.customWidgetBuilder,
    );
  }

  @override
  void didUpdateWidget(FormundaRenderer oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (widget.customWidgetBuilder != oldWidget.customWidgetBuilder) {
      _wf = FormundaWidgetFactory(
        widget.controller,
        customWidgetBuilder: widget.customWidgetBuilder,
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    return widget.renderMode.buildBodyWidget(
      context,
      widget.data,
      (context, index) => _wf.buildNode(context, widget.data[index]),
    );
  }
}
