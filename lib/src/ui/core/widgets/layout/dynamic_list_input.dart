// Copyright (C) 2026 Afonso Barracha
//
// This file is part of My Fitness Tale.
//
// My Fitness Tale is free software: you can redistribute it and/or modify
// it under the terms of the GNU General Public License as published by
// the Free Software Foundation, either version 3 of the License, or
// (at your option) any later version.
//
// My Fitness Tale is distributed in the hope that it will be useful,
// but WITHOUT ANY WARRANTY; without even the implied warranty of
// MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.  See the
// GNU General Public License for more details.
//
// You should have received a copy of the GNU General Public License
// along with My Fitness Tale.  If not, see <https://www.gnu.org/licenses/>.

import 'package:material_ui/material_ui.dart';

class DynamicListInput<T> extends StatelessWidget {
  final ThemeData theme;
  final bool filled;
  final List<T> items;
  final Widget Function(BuildContext context, int index, T item) itemBuilder;
  final ValueChanged<List<T>> onChanged;
  final VoidCallback onAdd;
  final Key Function(T item)? keyBuilder;
  final String addLabel;
  final bool addEnabled;
  final double fontSize;
  final double padding;
  final double spacing;
  final double handlesPadding;
  final bool isLoading;
  final double? addButtonHeight;
  final void Function(int oldIndex, int newIndex)? onReorder;

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
    required this.handlesPadding,
    required this.isLoading,
    this.addButtonHeight,
    this.onReorder,
    this.addEnabled = true,
  });

  @override
  Widget build(BuildContext context) {
    final disabledColor = theme.colorScheme.brightness == Brightness.dark
        ? Colors.grey[400]!
        : Colors.grey[600]!;
    final addBtnColor = addEnabled
        ? theme.colorScheme.secondary
        : disabledColor;

    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        if (items.isNotEmpty)
          ReorderableListView.builder(
            shrinkWrap: true,
            buildDefaultDragHandles: false,
            physics: const NeverScrollableScrollPhysics(),
            itemCount: items.length,
            onReorderItem: (oldIndex, newIndex) {
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
              final key =
                  keyBuilder?.call(item) ??
                  (item is Object ? ObjectKey(item) : ValueKey(item));

              return Container(
                key: key,
                margin: EdgeInsets.only(bottom: spacing),
                child: Row(
                  children: [
                    ReorderableDragStartListener(
                      index: index,
                      child: Padding(
                        padding: EdgeInsets.symmetric(
                          horizontal: handlesPadding,
                        ),
                        child: Icon(Icons.drag_indicator, size: fontSize * 1.2),
                      ),
                    ),
                    Expanded(child: itemBuilder(context, index, item)),
                    InkWell(
                      customBorder: const CircleBorder(),
                      onTap: isLoading
                          ? null
                          : () {
                              final List<T> newItems = List.from(items);
                              newItems.removeAt(index);
                              onChanged(newItems);
                            },
                      child: Padding(
                        padding: EdgeInsets.symmetric(
                          horizontal: handlesPadding,
                        ),
                        child: Icon(
                          Icons.close,
                          color: Colors.red,
                          size: fontSize * 1.2,
                        ),
                      ),
                    ),
                  ],
                ),
              );
            },
          ),
        SizedBox(
          height: addButtonHeight,
          child: FilledButton.icon(
            onPressed: isLoading || !addEnabled ? null : onAdd,
            icon: Icon(Icons.add, size: fontSize, color: addBtnColor),
            label: Text(
              addLabel,
              style: TextStyle(fontSize: fontSize, color: addBtnColor),
            ),
            style: FilledButton.styleFrom(
              backgroundColor: !filled
                  ? theme.colorScheme.surface
                  : theme.scaffoldBackgroundColor,
              side: BorderSide(color: addBtnColor, width: 0.5),
              shape: BeveledRectangleBorder(),
            ),
          ),
        ),
      ],
    );
  }
}
