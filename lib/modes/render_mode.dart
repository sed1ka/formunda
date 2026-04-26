import 'package:flutter/widgets.dart';
import 'package:formunda/models/formunda_node.dart';

part 'column_mode.dart';
part 'list_view_mode.dart';
part 'sliver_list_mode.dart';

abstract class RenderMode {
  const RenderMode();

  Widget buildBodyWidget(
    BuildContext context,
    List<FormundaNode> nodes,
    Widget Function(BuildContext, int index) itemBuilder,
  );
}
