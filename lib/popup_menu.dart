import 'package:flutter/material.dart';

class PopupMenu<T> extends StatelessWidget {
  final List<T> lines;
  final void Function(T) onTap;
  final String Function(T) getText;

  PopupMenu({
    @required this.lines,
    @required this.onTap,
    @required this.getText,
    Key key,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Card(
      child: Column(
        children: lines
            .map(
              (r) => InkWell(
                onTap: () => onTap(r),
                child: Container(
                  alignment: Alignment.centerLeft,
                  padding: const EdgeInsets.all(4.0),
                  child: Text(getText(r)),
                ),
              ),
            )
            .toList(),
      ),
      elevation: 2.0,
    );
  }
}

class PopupMenuScaffold<T> extends StatelessWidget {
  final T item;
  final String missingItem;
  final String hintItem;
  final String Function(T) itemName;
  final Widget displayWidget;
  final TextEditingController textController;
  final void Function(String) onChanged;

  PopupMenuScaffold({
    @required this.item,
    @required this.missingItem,
    @required this.hintItem,
    @required this.itemName,
    @required this.displayWidget,
    @required this.textController,
    @required this.onChanged,
    Key key,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        Text(
          item == null ? missingItem : hintItem,
          style: TextStyle(
              color: item != null
                  ? Theme.of(context).textTheme.caption.color
                  : Theme.of(context).errorColor,
              fontSize: Theme.of(context).textTheme.caption.fontSize),
        ),
        Text(
          item != null ? itemName(item) : '-',
          style: TextStyle(color: item != null ? Colors.black : Colors.red),
        ),
        Padding(
          padding: const EdgeInsets.only(left: 8.0, top: 8.0),
          child: Container(
            padding: const EdgeInsets.all(8.0),
            color: Colors.deepPurple[50],
            child: Column(
              children: [
                TextField(
                  controller: textController,
                  onChanged: onChanged,
                  decoration: const InputDecoration(
                    isDense: true,
                    icon: const Icon(Icons.filter_alt_outlined, size: 16.0),
                  ),
                ),
                displayWidget
              ],
            ),
          ),
        ),
      ],
    );
  }
}
