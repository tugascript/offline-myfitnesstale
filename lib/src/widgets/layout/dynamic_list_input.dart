import 'package:flutter/material.dart';

class DynamicListInput<T> extends StatelessWidget {
  final ThemeData theme;
  final bool filled;
  final List<T> items;
  final Widget Function(BuildContext context, int index, T item) itemBuilder;
  final ValueChanged<List<T>> onChanged;
  final VoidCallback onAdd;
  final Key Function(T item)? keyBuilder;
  final String addLabel;
  final double fontSize;
  final double padding;
  final double spacing;
  final bool isLoading;

  const DynamicListInput({
    super.key,
    this.filled = false,
    required this.theme,
    required this.items,
    required this.itemBuilder,
    required this.onChanged,
    required this.onAdd,
    required this.keyBuilder,
    required this.addLabel,
    required this.fontSize,
    required this.padding,
    required this.spacing,
    required this.isLoading,
    this.onReorder,
  });

  final void Function(int oldIndex, int newIndex)? onReorder;

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        if (items.isNotEmpty)
          ReorderableListView.builder(
            shrinkWrap: true,
            buildDefaultDragHandles: false,
            physics: const NeverScrollableScrollPhysics(),
            itemCount: items.length,
            onReorder: (oldIndex, newIndex) {
              if (oldIndex < newIndex) {
                newIndex -= 1;
              }
              final List<T> newItems = List.from(items);
              final item = newItems.removeAt(oldIndex);
              newItems.insert(newIndex, item);
              onChanged(newItems);
              onReorder?.call(oldIndex, newIndex);
            },
            itemBuilder: (context, index) {
              final item = items[index];
              final key = keyBuilder?.call(item) ??
                  (item is Object ? ObjectKey(item) : ValueKey(item));

              return Container(
                key: key,
                margin: EdgeInsets.only(bottom: spacing),
                child: Row(
                  children: [
                    ReorderableDragStartListener(
                      index: index,
                      child: Padding(
                        padding: EdgeInsets.only(right: padding / 2),
                        child: Icon(Icons.drag_indicator, size: fontSize),
                      ),
                    ),
                    Expanded(
                      child: itemBuilder(context, index, item),
                    ),
                    IconButton(
                      iconSize: fontSize,
                      icon: Icon(
                        Icons.close,
                        color: Colors.red,
                      ),
                      onPressed: isLoading
                          ? null
                          : () {
                              final List<T> newItems = List.from(items);
                              newItems.removeAt(index);
                              onChanged(newItems);
                            },
                      padding: EdgeInsets.zero,
                    ),
                  ],
                ),
              );
            },
          ),
        FilledButton.icon(
          onPressed: isLoading ? null : onAdd,
          icon: Icon(
            Icons.add,
            size: fontSize,
            color: theme.colorScheme.secondary,
          ),
          label: Text(
            addLabel,
            style: TextStyle(
              fontSize: fontSize,
              color: theme.colorScheme.secondary,
            ),
          ),
          style: FilledButton.styleFrom(
            backgroundColor: !filled
                ? theme.colorScheme.surface
                : theme.scaffoldBackgroundColor,
            padding: EdgeInsets.all(padding),
            side: BorderSide(
              color: theme.colorScheme.secondary,
              width: 0.5,
            ),
            shape: BeveledRectangleBorder(),
          ),
        ),
      ],
    );
  }
}
