part of 'render_mode.dart';

class ListViewMode extends RenderMode {
  final bool shrinkWrap;
  final ScrollPhysics? physics;
  final EdgeInsetsGeometry? padding;

  const ListViewMode({
    this.shrinkWrap = false,
    this.physics,
    this.padding,
  });

  @override
  Widget buildBodyWidget(
    BuildContext context,
    List<FormundaNode> nodes,
    Widget Function(BuildContext, int index) itemBuilder,
  ) {
    return ListView.builder(
      shrinkWrap: shrinkWrap,
      physics: physics,
      padding: padding,
      itemCount: nodes.length,
      itemBuilder: itemBuilder,
    );
  }
}
