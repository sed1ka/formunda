import 'package:flutter/material.dart';
import '../controller/formunda_controller.dart';
import '../models/formunda_field_node.dart';
import '../models/formunda_group_node.dart';
import '../models/formunda_node.dart';
import '../models/formunda_text_node.dart';
import '../models/formunda_image_node.dart';
import '../models/formunda_spacer_node.dart';
import '../models/formunda_separator_node.dart';
import '../models/formunda_table_node.dart';
import '../models/formunda_button_node.dart';
import '../models/formunda_html_node.dart';
import '../models/formunda_iframe_node.dart';
import '../condition/formunda_condition_evaluator.dart';
import '../formunda_builder.dart';

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
        if (node is FormundaImageNode) return buildImage(context, node);
        if (node is FormundaHtmlNode) return buildHtml(context, node);
        if (node is FormundaIFrameNode) return buildIFrame(context, node);
        if (node is FormundaSpacerNode) return buildSpacer(context, node);
        if (node is FormundaSeparatorNode) return buildSeparator(context, node);
        if (node is FormundaTableNode) return buildTable(context, node);
        if (node is FormundaButtonNode) return buildButton(context, node);
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
              border: Border.all(color: Theme.of(context).dividerColor),
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
                style: Theme.of(context).textTheme.titleMedium?.copyWith(
                      fontWeight: FontWeight.bold,
                    ),
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
      child: Text(
        node.text,
        style: Theme.of(context).textTheme.bodyMedium,
      ),
    );
  }

  Widget buildImage(BuildContext context, FormundaImageNode node) {
    if (node.source == null) return const SizedBox.shrink();
    return Padding(
      key: ValueKey(node.id),
      padding: const EdgeInsets.symmetric(vertical: 8),
      child: Image.network(
        node.source!,
        errorBuilder: (context, error, stackTrace) =>
            const Icon(Icons.broken_image),
      ),
    );
  }

  Widget buildHtml(BuildContext context, FormundaHtmlNode node) {
    return Padding(
      key: ValueKey(node.id),
      padding: const EdgeInsets.symmetric(vertical: 8),
      child: Text(
        node.content ?? '',
        style: Theme.of(context).textTheme.bodyMedium,
      ),
    );
  }

  Widget buildIFrame(BuildContext context, FormundaIFrameNode node) {
    return Container(
      key: ValueKey(node.id),
      height: node.height ?? 200,
      width: double.infinity,
      decoration: BoxDecoration(
        border: Border.all(color: Theme.of(context).dividerColor),
        color: Theme.of(context).colorScheme.surfaceContainerHighest.withValues(alpha: 0.3),
      ),
      child: Center(
        child: Text("IFrame URL: ${node.url ?? ''}"),
      ),
    );
  }

  Widget buildSpacer(BuildContext context, FormundaSpacerNode node) {
    return SizedBox(
      key: ValueKey(node.id),
      height: node.height ?? 16,
    );
  }

  Widget buildSeparator(BuildContext context, FormundaSeparatorNode node) {
    return Divider(
      key: ValueKey(node.id),
      height: 24,
      thickness: 1,
    );
  }

  Widget buildTable(BuildContext context, FormundaTableNode node) {
    final data = controller.getValue(node.dataSource ?? '') as List? ?? [];

    return Padding(
      key: ValueKey(node.id),
      padding: const EdgeInsets.symmetric(vertical: 8),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          if (node.label?.isNotEmpty ?? false)
            Padding(
              padding: const EdgeInsets.only(bottom: 4),
              child: Text(node.label!,
                  style: Theme.of(context).textTheme.titleSmall),
            ),
          SingleChildScrollView(
            scrollDirection: Axis.horizontal,
            child: DataTable(
              columns: node.columns
                  .map((c) => DataColumn(label: Text(c.label)))
                  .toList(),
              rows: data
                  .map((row) => DataRow(
                        cells: node.columns
                            .map((c) => DataCell(Text("${row[c.key] ?? ''}")))
                            .toList(),
                      ))
                  .toList(),
            ),
          ),
        ],
      ),
    );
  }

  Widget buildButton(BuildContext context, FormundaButtonNode node) {
    return Padding(
      key: ValueKey(node.id),
      padding: const EdgeInsets.symmetric(vertical: 8),
      child: ElevatedButton(
        onPressed: () {
          if (node.action == 'submit') {
            controller.submit();
          } else if (node.action == 'reset') {
            // reset logic
          }
        },
        child: Text(node.label ?? 'Button'),
      ),
    );
  }

  Widget buildField(BuildContext context, FormundaFieldNode node) {
    switch (node.type) {
      case 'textfield':
      case 'textarea':
        return _FormundaTextField(node: node, factory: this);
      case 'number':
        return _FormundaNumberField(node: node, factory: this);
      case 'datetime':
        return _FormundaDateTimeField(node: node, factory: this);
      case 'checkbox':
        return _FormundaCheckboxField(node: node, factory: this);
      case 'checklist':
        return _FormundaChecklistField(node: node, factory: this);
      case 'radio':
        return _FormundaRadioField(node: node, factory: this);
      case 'select':
        return _FormundaSelectField(node: node, factory: this);
      case 'taglist':
        return _FormundaTaglistField(node: node, factory: this);
      default:
        return const SizedBox.shrink();
    }
  }
}

abstract class _FormundaFieldWidget extends StatefulWidget {
  final FormundaFieldNode node;
  final FormundaWidgetFactory factory;

  const _FormundaFieldWidget({
    required this.node,
    required this.factory,
  });
}

abstract class _FormundaFieldState<T extends _FormundaFieldWidget>
    extends State<T> {
  late FocusNode focusNode;

  @override
  void initState() {
    super.initState();
    focusNode = FocusNode();
    widget.factory.controller.registerFocusNode(widget.node.id, focusNode);
    focusNode.addListener(_onFocusChange);
  }

  void _onFocusChange() {
    if (focusNode.hasFocus) {
      Scrollable.ensureVisible(
        context,
        duration: const Duration(milliseconds: 400),
        alignment: 0.2,
        curve: Curves.easeInOut,
      );
    }
  }

  @override
  void dispose() {
    focusNode.removeListener(_onFocusChange);
    focusNode.dispose();
    super.dispose();
  }

  Widget buildLabel(BuildContext context) {
    if (widget.node.label == null) return const SizedBox.shrink();
    return Padding(
      padding: const EdgeInsets.only(bottom: 4),
      child: Text(
        widget.node.label!,
        style: Theme.of(context).textTheme.labelLarge,
      ),
    );
  }

  Widget buildDescription(BuildContext context) {
    if (widget.node.description == null) return const SizedBox.shrink();
    return Padding(
      padding: const EdgeInsets.only(top: 2, bottom: 4),
      child: Text(
        widget.node.description!,
        style: Theme.of(context).textTheme.bodySmall,
      ),
    );
  }
}

class _FormundaTextField extends _FormundaFieldWidget {
  const _FormundaTextField({required super.node, required super.factory});

  @override
  State<_FormundaTextField> createState() => _FormundaTextFieldState();
}

class _FormundaTextFieldState extends _FormundaFieldState<_FormundaTextField> {
  late TextEditingController _textController;

  @override
  void initState() {
    super.initState();
    final initialValue = widget.factory.controller.getValue(widget.node.key ?? '') ??
        widget.node.defaultValue ??
        '';
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
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          buildLabel(context),
          TextFormField(
            controller: _textController,
            focusNode: focusNode,
            maxLines: widget.node.type == 'textarea' ? 3 : 1,
            textInputAction: TextInputAction.next,
            decoration: InputDecoration(
              border: const OutlineInputBorder(),
              hintText: widget.node.description,
            ),
            onChanged: (val) =>
                widget.factory.controller.setValue(widget.node.key!, val),
            onFieldSubmitted: (_) => FocusScope.of(context).nextFocus(),
          ),
          buildDescription(context),
        ],
      ),
    );
  }
}

class _FormundaNumberField extends _FormundaFieldWidget {
  const _FormundaNumberField({required super.node, required super.factory});

  @override
  State<_FormundaNumberField> createState() => _FormundaNumberFieldState();
}

class _FormundaNumberFieldState
    extends _FormundaFieldState<_FormundaNumberField> {
  late TextEditingController _textController;

  @override
  void initState() {
    super.initState();
    final initialValue = widget.factory.controller.getValue(widget.node.key ?? '') ??
        widget.node.defaultValue ??
        '';
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
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          buildLabel(context),
          TextFormField(
            controller: _textController,
            focusNode: focusNode,
            keyboardType: TextInputType.number,
            decoration: const InputDecoration(
              border: OutlineInputBorder(),
            ),
            onChanged: (val) {
              final numValue = num.tryParse(val);
              widget.factory.controller.setValue(widget.node.key!, numValue);
            },
          ),
          buildDescription(context),
        ],
      ),
    );
  }
}

class _FormundaDateTimeField extends _FormundaFieldWidget {
  const _FormundaDateTimeField({required super.node, required super.factory});

  @override
  State<_FormundaDateTimeField> createState() => _FormundaDateTimeFieldState();
}

class _FormundaDateTimeFieldState
    extends _FormundaFieldState<_FormundaDateTimeField> {
  @override
  Widget build(BuildContext context) {
    final value = widget.factory.controller.getValue(widget.node.key!) ??
        widget.node.defaultValue;

    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 8),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          buildLabel(context),
          InkWell(
            focusNode: focusNode,
            onTap: () async {
              focusNode.requestFocus();
              if (widget.node.subtype == 'time') {
                final time = await showTimePicker(
                  context: context,
                  initialTime: TimeOfDay.now(),
                );
                if (time != null) {
                  widget.factory.controller.setValue(
                    widget.node.key!,
                    "${time.hour.toString().padLeft(2, '0')}:${time.minute.toString().padLeft(2, '0')}",
                  );
                }
              } else {
                final date = await showDatePicker(
                  context: context,
                  initialDate: DateTime.now(),
                  firstDate: DateTime(1900),
                  lastDate: DateTime(2100),
                );
                if (date != null) {
                  widget.factory.controller.setValue(
                    widget.node.key!,
                    date.toIso8601String().split('T')[0],
                  );
                }
              }
            },
            child: Container(
              padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 15),
              decoration: BoxDecoration(
                border: Border.all(color: Theme.of(context).dividerColor),
                borderRadius: BorderRadius.circular(4),
              ),
              child: Row(
                children: [
                  Expanded(
                    child: Text(
                      value?.toString() ??
                          (widget.node.subtype == 'time'
                              ? "Select Time"
                              : "Select Date"),
                    ),
                  ),
                  Icon(widget.node.subtype == 'time'
                      ? Icons.access_time
                      : Icons.calendar_today),
                ],
              ),
            ),
          ),
          buildDescription(context),
        ],
      ),
    );
  }
}

class _FormundaCheckboxField extends _FormundaFieldWidget {
  const _FormundaCheckboxField({required super.node, required super.factory});

  @override
  State<_FormundaCheckboxField> createState() => _FormundaCheckboxFieldState();
}

class _FormundaCheckboxFieldState
    extends _FormundaFieldState<_FormundaCheckboxField> {
  @override
  Widget build(BuildContext context) {
    final bool value = widget.factory.controller.getValue(widget.node.key!) ??
        widget.node.defaultValue ??
        false;

    return CheckboxListTile(
      focusNode: focusNode,
      title: Text(widget.node.label ?? ''),
      subtitle: widget.node.description != null
          ? Text(widget.node.description!)
          : null,
      value: value,
      onChanged: (val) {
        widget.factory.controller.setValue(widget.node.key!, val);
        focusNode.requestFocus();
      },
      controlAffinity: ListTileControlAffinity.leading,
    );
  }
}

class _FormundaChecklistField extends _FormundaFieldWidget {
  const _FormundaChecklistField({required super.node, required super.factory});

  @override
  State<_FormundaChecklistField> createState() => _FormundaChecklistFieldState();
}

class _FormundaChecklistFieldState
    extends _FormundaFieldState<_FormundaChecklistField> {
  @override
  Widget build(BuildContext context) {
    final List selectedValues =
        widget.factory.controller.getValue(widget.node.key!) ?? [];

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        buildLabel(context),
        Focus(
          focusNode: focusNode,
          child: Column(
            children: (widget.node.values ?? []).map((opt) {
              final val = opt['value'].toString();
              return CheckboxListTile(
                title: Text(opt['label'] ?? ''),
                value: selectedValues.contains(val),
                onChanged: (checked) {
                  final newValues = List.from(selectedValues);
                  if (checked == true) {
                    newValues.add(val);
                  } else {
                    newValues.remove(val);
                  }
                  widget.factory.controller.setValue(widget.node.key!, newValues);
                  focusNode.requestFocus();
                },
                controlAffinity: ListTileControlAffinity.leading,
                dense: true,
              );
            }).toList(),
          ),
        ),
        buildDescription(context),
      ],
    );
  }
}

class _FormundaRadioField extends _FormundaFieldWidget {
  const _FormundaRadioField({required super.node, required super.factory});

  @override
  State<_FormundaRadioField> createState() => _FormundaRadioFieldState();
}

class _FormundaRadioFieldState extends _FormundaFieldState<_FormundaRadioField> {
  @override
  Widget build(BuildContext context) {
    final value = widget.factory.controller.getValue(widget.node.key!);

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        buildLabel(context),
        Focus(
          focusNode: focusNode,
          child: RadioGroup<String>(
            groupValue: value?.toString(),
            onChanged: (newVal) {
              widget.factory.controller.setValue(widget.node.key!, newVal);
              focusNode.requestFocus();
            },
            child: Column(
              children: (widget.node.values ?? []).map((opt) {
                return RadioListTile<String>(
                  title: Text(opt['label'] ?? ''),
                  value: opt['value'].toString(),
                  dense: true,
                );
              }).toList(),
            ),
          ),
        ),
        buildDescription(context),
      ],
    );
  }
}

class _FormundaSelectField extends _FormundaFieldWidget {
  const _FormundaSelectField({required super.node, required super.factory});

  @override
  State<_FormundaSelectField> createState() => _FormundaSelectFieldState();
}

class _FormundaSelectFieldState
    extends _FormundaFieldState<_FormundaSelectField> {
  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 8),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          buildLabel(context),
          DropdownButtonFormField<String>(
            focusNode: focusNode,
            initialValue: widget.factory.controller.getValue(widget.node.key!) ??
                widget.node.defaultValue,
            decoration: const InputDecoration(
              border: OutlineInputBorder(),
            ),
            items: widget.node.values?.map((opt) {
              return DropdownMenuItem(
                value: opt['value'].toString(),
                child: Text(opt['label'] ?? ''),
              );
            }).toList(),
            onChanged: (val) {
              widget.factory.controller.setValue(widget.node.key!, val);
              focusNode.requestFocus();
            },
          ),
          buildDescription(context),
        ],
      ),
    );
  }
}

class _FormundaTaglistField extends _FormundaFieldWidget {
  const _FormundaTaglistField({required super.node, required super.factory});

  @override
  State<_FormundaTaglistField> createState() => _FormundaTaglistFieldState();
}

class _FormundaTaglistFieldState
    extends _FormundaFieldState<_FormundaTaglistField> {
  @override
  Widget build(BuildContext context) {
    final List selectedValues =
        widget.factory.controller.getValue(widget.node.key!) ?? [];

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        buildLabel(context),
        Focus(
          focusNode: focusNode,
          child: Wrap(
            spacing: 8,
            children: (widget.node.values ?? []).map((opt) {
              final val = opt['value'].toString();
              final isSelected = selectedValues.contains(val);
              return FilterChip(
                label: Text(opt['label'] ?? ''),
                selected: isSelected,
                onSelected: (selected) {
                  final newValues = List.from(selectedValues);
                  if (selected) {
                    newValues.add(val);
                  } else {
                    newValues.remove(val);
                  }
                  widget.factory.controller.setValue(widget.node.key!, newValues);
                  focusNode.requestFocus();
                },
              );
            }).toList(),
          ),
        ),
        buildDescription(context),
      ],
    );
  }
}
