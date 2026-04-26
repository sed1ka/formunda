import 'package:flutter/material.dart';
import '../controller/formunda_controller.dart';
import '../models/formunda_field_node.dart';
import '../models/formunda_group_node.dart';
import '../models/formunda_node.dart';
import '../models/formunda_text_node.dart';
import '../condition/formunda_condition_evaluator.dart';
import '../formunda_builder.dart';

class FormundaRenderer extends StatelessWidget {
  final List<FormundaNode> data;
  final FormundaController controller;
  final Map<String, FormundaCustomBuilder>? customWidgetBuilder;

  const FormundaRenderer({
    super.key,
    required this.data,
    required this.controller,
    this.customWidgetBuilder,
  });

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: data.map((node) => _renderNodeWrapper(context, node)).toList(),
    );
  }

  Widget _renderNodeWrapper(BuildContext context, FormundaNode node) {
    // Membungkus setiap node dengan logika visibilitas kondisional
    // Ini memastikan hanya bagian yang perlu saja yang di-rebuild/re-evaluate
    return ListenableBuilder(
      listenable: controller,
      builder: (context, _) {
        final isHidden = FormundaConditionEvaluator.isHidden(
          node.condition?.hide,
          controller.values,
        );

        if (isHidden) return const SizedBox.shrink();

        return _renderNode(context, node);
      },
    );
  }

  Widget _renderNode(BuildContext context, FormundaNode node) {
    if (node is FormundaGroupNode) {
      return _buildGroup(context, node);
    } else if (node is FormundaTextNode) {
      return _buildText(node);
    } else if (node is FormundaFieldNode) {
      return _buildField(context, node);
    }
    return const SizedBox.shrink();
  }

  Widget _buildGroup(BuildContext context, FormundaGroupNode node) {
    return Container(
      key: ValueKey(node.id),
      margin: const EdgeInsets.symmetric(vertical: 8),
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        border: Border.all(color: Colors.grey.shade300),
        borderRadius: BorderRadius.circular(8),
      ),
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
          ...node.children.map((child) => _renderNodeWrapper(context, child)),
        ],
      ),
    );
  }

  Widget _buildText(FormundaTextNode node) {
    return Padding(
      key: ValueKey(node.id),
      padding: const EdgeInsets.symmetric(vertical: 8.0),
      child: Text(node.text), // Bisa ditingkatkan dengan Markdown jika perlu
    );
  }

  Widget _buildField(BuildContext context, FormundaFieldNode node) {
    // Cek apakah ada builder custom dari user
    if (customWidgetBuilder != null && customWidgetBuilder!.containsKey(node.type)) {
      return customWidgetBuilder![node.type]!(context, node, controller);
    }

    // Default Rendering yang efisien
    switch (node.type) {
      case 'textfield':
      case 'textarea':
        return FormundaTextField(node: node, controller: controller);
      case 'select':
        return FormundaSelectField(node: node, controller: controller);
      default:
        return Text("Field type ${node.type} not implemented");
    }
  }
}

/// Widget khusus untuk TextField agar performa input mulus
class FormundaTextField extends StatefulWidget {
  final FormundaFieldNode node;
  final FormundaController controller;

  const FormundaTextField({super.key, required this.node, required this.controller});

  @override
  State<FormundaTextField> createState() => _FormundaTextFieldState();
}

class _FormundaTextFieldState extends State<FormundaTextField> {
  late TextEditingController _textController;

  @override
  void initState() {
    super.initState();
    final initialValue = widget.controller.getValue(widget.node.key ?? '') ?? widget.node.defaultValue ?? '';
    _textController = TextEditingController(text: initialValue.toString());
  }

  @override
  void dispose() {
    _textController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 8),
      child: TextFormField(
        controller: _textController,
        maxLines: widget.node.type == 'textarea' ? 3 : 1,
        decoration: InputDecoration(
          labelText: widget.node.label,
          border: const OutlineInputBorder(),
        ),
        onChanged: (val) {
          // setValue sekarang lebih cerdas dan tidak selalu trigger global rebuild
          widget.controller.setValue(widget.node.key!, val);
        },
      ),
    );
  }
}

/// Widget khusus untuk Select/Dropdown
class FormundaSelectField extends StatelessWidget {
  final FormundaFieldNode node;
  final FormundaController controller;

  const FormundaSelectField({super.key, required this.node, required this.controller});

  @override
  Widget build(BuildContext context) {
    final fieldKey = node.key!;
    final options = node.values;

    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 8),
      child: ListenableBuilder(
        listenable: controller,
        builder: (context, _) {
          return DropdownButtonFormField<String>(
            value: controller.getValue(fieldKey) ?? node.defaultValue,
            decoration: InputDecoration(
              labelText: node.label,
              border: const OutlineInputBorder(),
            ),
            items: options?.map((opt) {
              return DropdownMenuItem<String>(
                value: opt['value'],
                child: Text(opt['label']),
              );
            }).toList(),
            onChanged: (val) => controller.setValue(fieldKey, val),
          );
        },
      ),
    );
  }
}
