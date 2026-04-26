import 'package:flutter/material.dart';
import '../controller/formunda_controller.dart';
import '../models/formunda_field_node.dart';
import '../models/formunda_group_node.dart';
import '../models/formunda_node.dart';
import '../models/formunda_text_node.dart';
import '../condition/formunda_condition_evaluator.dart';
import '../formunda_builder.dart';

/// Otak otomatis di balik rendering widget.
/// Menangani Focus Navigation, Auto-Scroll, dan Event secara otomatis.
class FormundaWidgetFactory {
  final FormundaController controller;
  final FormundaCustomWidgetBuilder? customWidgetBuilder;

  FormundaWidgetFactory(this.controller, {this.customWidgetBuilder});

  Widget buildNode(BuildContext context, FormundaNode node) {
    if (customWidgetBuilder != null) {
      final customWidget = customWidgetBuilder!(context, node, controller);
      if (customWidget != null) return customWidget;
    }

    return ListenableBuilder(
      listenable: controller,
      builder: (context, _) {
        final isHidden = FormundaConditionEvaluator.isHidden(
          node.condition?.hide,
          controller.values,
        );
        if (isHidden) return const SizedBox.shrink();

        if (node is FormundaGroupNode) return buildGroup(context, node);
        if (node is FormundaTextNode) return buildText(context, node);
        if (node is FormundaFieldNode) return buildField(context, node);

        return const SizedBox.shrink();
      },
    );
  }

  Widget buildGroup(BuildContext context, FormundaGroupNode node) {
    return Container(
      key: ValueKey(node.id),
      margin: const EdgeInsets.symmetric(vertical: 8),
      padding: node.showOutline == true ? const EdgeInsets.all(12) : null,
      decoration: node.showOutline == true
          ? BoxDecoration(
              border: Border.all(color: Colors.grey.shade300),
              borderRadius: BorderRadius.circular(8),
            )
          : null,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          if (node.label?.isNotEmpty ?? false)
            Padding(
              padding: const EdgeInsets.only(bottom: 8),
              child: Text(
                node.label!,
                style: const TextStyle(fontWeight: FontWeight.bold),
              ),
            ),
          ...node.children.map((child) => buildNode(context, child)),
        ],
      ),
    );
  }

  Widget buildText(BuildContext context, FormundaTextNode node) {
    return Padding(
      key: ValueKey(node.id),
      padding: const EdgeInsets.symmetric(vertical: 8),
      child: Text(node.text),
    );
  }

  Widget buildField(BuildContext context, FormundaFieldNode node) {
    switch (node.type) {
      case 'textfield':
      case 'textarea':
        return _AutomaticTextField(node: node, factory: this);
      case 'select':
        return _AutomaticSelectField(node: node, factory: this);
      default:
        return Text("Unsupported field: ${node.type}");
    }
  }
}

class _AutomaticTextField extends StatefulWidget {
  final FormundaFieldNode node;
  final FormundaWidgetFactory factory;

  const _AutomaticTextField({required this.node, required this.factory});

  @override
  State<_AutomaticTextField> createState() => _AutomaticTextFieldState();
}

class _AutomaticTextFieldState extends State<_AutomaticTextField> {
  late TextEditingController _textController;
  late FocusNode _focusNode;

  @override
  void initState() {
    super.initState();
    final initialValue = widget.factory.controller.getValue(
      widget.node.key ?? '',
    );
    _textController = TextEditingController(
      text: (initialValue ?? widget.node.defaultValue ?? '').toString(),
    );

    _focusNode = FocusNode();

    // Daftarkan ke controller agar bisa di-scroll dari luar lewat ID
    widget.factory.controller.registerFocusNode(widget.node.id, _focusNode);

    // Inilah cara scrolling yang "Aman" dan "Otomatis"
    _focusNode.addListener(() {
      if (_focusNode.hasFocus) {
        // Flutter akan menghitung posisi widget secara presisi di dalam viewport
        Scrollable.ensureVisible(
          context,
          duration: const Duration(milliseconds: 400),
          alignment: 0.2,
          // Memberikan sedikit ruang di atas field (padding scroll)
          curve: Curves.easeInOut,
        );
      }
    });
  }

  @override
  void dispose() {
    _textController.dispose();
    _focusNode.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 8),
      child: TextFormField(
        controller: _textController,
        focusNode: _focusNode,
        maxLines: widget.node.type == 'textarea' ? 3 : 1,
        textInputAction: TextInputAction.next,
        decoration: InputDecoration(
          labelText: widget.node.label,
          border: const OutlineInputBorder(),
        ),
        onChanged: (val) =>
            widget.factory.controller.setValue(widget.node.key!, val),
        onFieldSubmitted: (_) => FocusScope.of(context).nextFocus(),
      ),
    );
  }
}

class _AutomaticSelectField extends StatefulWidget {
  final FormundaFieldNode node;
  final FormundaWidgetFactory factory;

  const _AutomaticSelectField({required this.node, required this.factory});

  @override
  State<_AutomaticSelectField> createState() => _AutomaticSelectFieldState();
}

class _AutomaticSelectFieldState extends State<_AutomaticSelectField> {
  late FocusNode _focusNode;

  @override
  void initState() {
    super.initState();
    _focusNode = FocusNode();
    widget.factory.controller.registerFocusNode(widget.node.id, _focusNode);

    _focusNode.addListener(() {
      if (_focusNode.hasFocus) {
        Scrollable.ensureVisible(
          context,
          duration: const Duration(milliseconds: 400),
          alignment: 0.2,
        );
      }
    });
  }

  @override
  void dispose() {
    _focusNode.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 8),
      child: Focus(
        focusNode: _focusNode,
        child: DropdownButtonFormField<String>(
          initialValue:
              widget.factory.controller.getValue(widget.node.key!) ??
              widget.node.defaultValue,
          decoration: InputDecoration(
            labelText: widget.node.label,
            border: const OutlineInputBorder(),
          ),
          items: widget.node.values
              ?.map(
                (opt) => DropdownMenuItem(
                  value: opt['value'].toString(),
                  child: Text(opt['label']),
                ),
              )
              .toList(),
          onChanged: (val) {
            widget.factory.controller.setValue(widget.node.key!, val);
            _focusNode.requestFocus(); // Trigger scroll saat terpilih
          },
        ),
      ),
    );
  }
}
