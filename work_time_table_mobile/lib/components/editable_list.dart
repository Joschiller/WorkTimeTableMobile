import 'package:flutter/material.dart';
import 'package:work_time_table_mobile/components/managable_list.dart';
import 'package:work_time_table_mobile/components/page_template.dart';
import 'package:work_time_table_mobile/stream_helpers/identifiable.dart';

class EditableList<T extends Identifiable> extends StatefulWidget {
  const EditableList({
    super.key,
    required this.title,
    required this.items,
    required this.templateItem,
    required this.emptyText,
    required this.addFirstText,
    required this.buildItem,
    required this.onAdd,
    required this.onRemove,
    this.onTapItem,
    this.detailInformation,
  });

  final String title;

  final List<T> items;
  final T templateItem;
  final String emptyText;
  final String addFirstText;

  final Widget Function(T item, bool selected) buildItem;

  final void Function() onAdd;
  final Future<void> Function(List<T> items) onRemove;

  final void Function(int index)? onTapItem;

  final Widget? detailInformation;

  @override
  State<EditableList<T>> createState() => _EditableListState<T>();
}

class _EditableListState<T extends Identifiable>
    extends State<EditableList<T>> {
  final _selectedItems = <dynamic>[];

  void _toggleSelection(int index) => setState(() {
        final item = widget.items[index].identity;
        if (_selectedItems.contains(item)) {
          _selectedItems.remove(item);
        } else {
          _selectedItems.add(item);
        }
      });

  @override
  Widget build(BuildContext context) => PageTemplate(
        title: widget.title,
        content: Row(
          children: [
            Expanded(
              child: widget.items.isNotEmpty
                  ? ManagableList(
                      items: widget.items,
                      templateItem: widget.templateItem,
                      buildItem: (item) => widget.buildItem(
                        item,
                        _selectedItems.contains(item.identity),
                      ),
                      onTapItem: _selectedItems.isEmpty
                          ? widget.onTapItem
                          : _toggleSelection,
                      onLongPressItem: _toggleSelection,
                    )
                  : Column(
                      children: [
                        Card(
                          child: Padding(
                            padding: const EdgeInsets.all(8),
                            child: Column(
                              mainAxisSize: MainAxisSize.min,
                              children: [
                                Text(widget.emptyText),
                                GestureDetector(
                                  onTap: widget.onAdd,
                                  child: Text(
                                    widget.addFirstText,
                                    style: TextStyle(
                                      color:
                                          Theme.of(context).colorScheme.primary,
                                      fontWeight: FontWeight.bold,
                                    ),
                                  ),
                                ),
                              ],
                            ),
                          ),
                        ),
                      ],
                    ),
            ),
            if (widget.detailInformation != null)
              Expanded(
                child: widget.detailInformation!,
              ),
          ],
        ),
        floatingButton: _selectedItems.isEmpty
            ? (
                icon: Icon(
                  Icons.add,
                  color: Theme.of(context).colorScheme.primary,
                ),
                onPressed: widget.onAdd,
              )
            : (
                icon: Icon(
                  Icons.delete,
                  color: Theme.of(context).colorScheme.error,
                ),
                onPressed: () async {
                  await widget.onRemove(widget.items
                      .where((item) => _selectedItems.contains(item.identity))
                      .toList());
                  setState(() => _selectedItems.clear());
                },
              ),
      );
}
