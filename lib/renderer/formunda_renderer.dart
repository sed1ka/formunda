// lib/formunda_widget.dart
import 'package:flutter/material.dart';
import 'package:formunda/controller/formunda_controller.dart';
import 'package:formunda/models/formunda_node.dart';
import 'package:formunda/models/formunda_group_node.dart';
import 'package:formunda/models/formunda_text_node.dart';
import 'package:formunda/models/formunda_field_node.dart';
import 'package:formunda/condition/formunda_condition_evaluator.dart';

typedef FormundaCustomBuilder = Widget? Function(
    BuildContext context,
    FormundaNode node,
    FormundaController controller
    );

class FormundaRenderer extends StatelessWidget {
  final List<FormundaNode> nodes;
  final FormundaController controller;
  final FormundaCustomBuilder? customBuilder;

  const FormundaRenderer({
    super.key,
    required this.nodes,
    required this.controller,
    this.customBuilder,
  });

  @override
  Widget build(BuildContext context) {
    return ListenableBuilder(
      listenable: controller,
      builder: (context, _) {
        return Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: nodes.map((node) => _buildNode(context, node)).toList(),
        );
      },
    );
  }

  Widget _buildNode(BuildContext context, FormundaNode node) {
    // Cek kondisi hide
    if (FormundaConditionEvaluator.isHidden(node.condition?.hide, controller.values)) {
      return const SizedBox.shrink();
    }

    // Cek apakah ada custom widget untuk tipe ini
    final customWidget = customBuilder?.call(context, node, controller);
    if (customWidget != null) return customWidget;

    // Default Rendering
    if (node is FormundaGroupNode) {
      return _buildGroup(context, node);
    } else if (node is FormundaTextNode) {
      return _buildText(node);
    } else if (node is FormundaFieldNode) {
      return _buildField(node);
    }

    return Text("Unknown type: ${node.type}");
  }

  Widget _buildGroup(BuildContext context, FormundaGroupNode node) {
    return Container(
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
          if (node?.label != null && node.label!.isNotEmpty)
            Padding(
              padding: const EdgeInsets.only(bottom: 8),
              child: Text(node.label!, style: const TextStyle(fontWeight: FontWeight.bold)),
            ),
          ...node.children.map((child) => _buildNode(context, child)),
        ],
      ),
    );
  }

  Widget _buildText(FormundaTextNode node) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 8.0),
      child: Text(
        node.text.replaceAll(RegExp(r'[#*]'), ''),
        style: TextStyle(
          fontWeight: node.text.startsWith('#') ? FontWeight.bold : FontWeight.normal,
          fontSize: node.text.startsWith('#') ? 18 : 14,
          color: node.text.contains('STOP WORK') ? Colors.red : Colors.black,
        ),
      ),
    );
  }

  Widget _buildField(FormundaFieldNode node) {
    switch (node.type) {
      case 'textfield':
        return Padding(
          padding: const EdgeInsets.symmetric(vertical: 8),
          child: TextFormField(
            initialValue: controller.getValue(node.key!) ?? node.defaultValue,
            decoration: InputDecoration(labelText: node.label, border: const OutlineInputBorder()),
            onChanged: (val) => controller.setValue(node.key!, val),
          ),
        );
      case 'textarea':
        return Padding(
          padding: const EdgeInsets.symmetric(vertical: 8),
          child: TextFormField(
            maxLines: 3,
            decoration: InputDecoration(labelText: node.label, border: const OutlineInputBorder()),
            onChanged: (val) => controller.setValue(node.key!, val),
          ),
        );
      case 'select':
        final options = node.values as List?;
        return Padding(
          padding: const EdgeInsets.symmetric(vertical: 8),
            child: DropdownButtonFormField<String>(
            initialValue: controller.getValue(node.key!),
            decoration: InputDecoration(labelText: node.label, border: const OutlineInputBorder()),
            items: options?.map((opt) {
              return DropdownMenuItem<String>(
                value: opt['value'],
                child: Text(opt['label']),
              );
            }).toList(),
            onChanged: (val) => controller.setValue(node.key!, val),
          ),
        );
      default:
        return Text("Field type ${node.type} not implemented");
    }
  }
}