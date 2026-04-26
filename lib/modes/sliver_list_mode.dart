part of 'render_mode.dart';

class SliverListMode extends RenderMode {
  const SliverListMode();

  @override
  Widget buildBodyWidget(
    BuildContext context,
    List<FormundaNode> nodes,
    Widget Function(BuildContext, int index) itemBuilder,
  ) {
    return SliverList(
      delegate: SliverChildBuilderDelegate(
        itemBuilder,
        childCount: nodes.length,
      ),
    );
  }
}
