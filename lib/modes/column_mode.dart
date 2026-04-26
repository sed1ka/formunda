part of 'render_mode.dart';

class ColumnMode extends RenderMode {
  final MainAxisSize mainAxisSize;
  final CrossAxisAlignment crossAxisAlignment;

  const ColumnMode({
    this.mainAxisSize = MainAxisSize.min,
    this.crossAxisAlignment = CrossAxisAlignment.start,
  });

  @override
  Widget buildBodyWidget(
    BuildContext context,
    List<FormundaNode> nodes,
    Widget Function(BuildContext, int index) itemBuilder,
  ) {
    return Column(
      mainAxisSize: mainAxisSize,
      crossAxisAlignment: crossAxisAlignment,
      children: [
        for (var i = 0; i < nodes.length; i++) itemBuilder(context, i),
      ],
    );
  }
}
