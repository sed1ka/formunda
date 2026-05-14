import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:formunda/controller/formunda_controller.dart';
import 'package:formunda/models/formunda_node.dart';
import 'package:formunda/parser/formunda_parser.dart';
import 'package:formunda/renderer/formunda_renderer.dart';
import 'package:formunda/modes/render_mode.dart';

typedef FormundaCustomWidgetBuilder = Widget? Function(
  BuildContext context,
  FormundaNode node,
  FormundaController controller,
);

class FormundaWidget extends StatefulWidget {
  final Map<String, dynamic> data;
  final FormundaController controller;
  final RenderMode renderMode;
  final FormundaCustomWidgetBuilder? customWidgetBuilder;
  final WidgetBuilder? onLoadingBuilder;

  FormundaWidget({
    super.key,
    required this.data,
    FormundaController? controller,
    this.renderMode = const ColumnMode(),
    this.customWidgetBuilder,
    this.onLoadingBuilder,
  }) : controller = controller ?? FormundaController();

  @override
  State<FormundaWidget> createState() => _FormundaWidgetState();
}

class _FormundaWidgetState extends State<FormundaWidget> {
  Future<List<FormundaNode>>? _parserFuture;
  List<FormundaNode>? _cachedNodes;
  Map<String, dynamic>? _lastData;

  @override
  void initState() {
    super.initState();
    _startParsingIfNeeded();
  }

  @override
  void didUpdateWidget(FormundaWidget oldWidget) {
    super.didUpdateWidget(oldWidget);
    _startParsingIfNeeded();
  }

  void _startParsingIfNeeded() {
    // Sync Check: Hanya parse jika data JSON benar-benar berbeda
    if (_lastData != null && mapEquals(widget.data, _lastData)) {
      return;
    }
    
    _lastData = widget.data;
    _parserFuture = compute(_parseInBackground, widget.data);
  }

  static List<FormundaNode> _parseInBackground(Map<String, dynamic> data) {
    return FormundaParser.parse(data['components'] ?? []);
  }

  @override
  Widget build(BuildContext context) {
    return FutureBuilder<List<FormundaNode>>(
      future: _parserFuture,
      builder: (context, snapshot) {
        if (snapshot.connectionState == ConnectionState.waiting && _cachedNodes == null) {
          return widget.onLoadingBuilder?.call(context) ?? 
                 const Center(child: CircularProgressIndicator());
        }

        if (snapshot.hasData) {
          _cachedNodes = snapshot.data;
        }

        final nodes = _cachedNodes ?? [];

        return FormundaRenderer(
          data: nodes,
          controller: widget.controller,
          customWidgetBuilder: widget.customWidgetBuilder,
          renderMode: widget.renderMode,
        );
      },
    );
  }
}
