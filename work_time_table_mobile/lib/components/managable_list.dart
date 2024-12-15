import 'package:flutter/widgets.dart';
import 'package:work_time_table_mobile/stream_helpers/identifiable.dart';

class ManagableList<T extends Identifiable> extends StatelessWidget {
  const ManagableList({
    super.key,
    required this.items,
    required this.templateItem,
    required this.buildItem,
    this.onTapItem,
    this.onLongPressItem,
  });

  final List<T> items;
  final T templateItem;

  final Widget Function(T item) buildItem;

  final void Function(int index)? onTapItem;
  final void Function(int index)? onLongPressItem;

  @override
  Widget build(BuildContext context) => ListView.builder(
        itemCount: items.length,
        prototypeItem: buildItem(templateItem),
        itemBuilder: (context, index) => GestureDetector(
          behavior: HitTestBehavior.opaque,
          key: Key('${items[index].identity}'),
          onTap: onTapItem != null ? () => onTapItem!(index) : null,
          onLongPress:
              onLongPressItem != null ? () => onLongPressItem!(index) : null,
          child: buildItem(items[index]),
        ),
      );
}
