import 'package:flutter/foundation.dart';
import 'package:flutter/widgets.dart';
import 'package:formunda/controller/formunda_controller.dart';
import 'package:formunda/models/formunda_node.dart';
import 'package:formunda/parser/formunda_parser.dart' show FormundaParser;
import 'package:formunda/renderer/formunda_renderer.dart' show FormundaRenderer;
import 'package:formunda/modes/render_mode.dart';

/// Signature untuk custom builder. 
/// Jika mengembalikan null, maka sistem akan menggunakan widget default.
typedef FormundaCustomWidgetBuilder = Widget? Function(
  BuildContext context,
  FormundaNode node,
  FormundaController controller,
);

class FormundaWidget extends StatefulWidget {
  final Map<String, dynamic> data;
  final FormundaController controller;
  final RenderMode renderMode;
  
  /// Custom builder persis seperti di flutter_widget_from_html
  final FormundaCustomWidgetBuilder? customWidgetBuilder;

  /// Builder yang ditampilkan saat proses parsing JSON (Isolate)
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

  @override
  void initState() {
    super.initState();
    _startParsing();
  }

  @override
  void didUpdateWidget(FormundaWidget oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (widget.data != oldWidget.data) {
      _startParsing();
    }
  }

  void _startParsing() {
    _parserFuture = compute((Map<String, dynamic> json) {
      return FormundaParser.parse(json['components'] ?? []);
    }, widget.data);
  }

  @override
  Widget build(BuildContext context) {
    return FutureBuilder<List<FormundaNode>>(
      future: _parserFuture,
      builder: (context, snapshot) {
        if (snapshot.connectionState == ConnectionState.waiting) {
          return widget.onLoadingBuilder?.call(context) ?? 
                 const Center(child: Text('Loading Form...'));
        }

        if (snapshot.hasError) {
          return Center(child: Text('Error: ${snapshot.error}'));
        }

        return FormundaRenderer(
          data: snapshot.data ?? [],
          controller: widget.controller,
          customWidgetBuilder: widget.customWidgetBuilder,
          renderMode: widget.renderMode,
        );
      },
    );
  }
}
