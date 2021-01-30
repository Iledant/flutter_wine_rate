import 'package:flutter/material.dart';

import 'models/region.dart';

class ProgressWidget extends StatelessWidget {
  const ProgressWidget({
    Key key,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) =>
      Center(child: CircularProgressIndicator(value: null));
}

class ScreenErrorWidget extends StatelessWidget {
  const ScreenErrorWidget({
    Key key,
    this.error,
  }) : super(key: key);
  final Object error;

  @override
  Widget build(BuildContext context) {
    if (error != null) debugPrint('Erreur : $error');
    return Center(
      child: Container(
        color: Colors.red,
        padding: EdgeInsets.all(8.0),
        child: Text('Erreur de chargement'),
      ),
    );
  }
}

class ItemPicker<T extends EquatableWithName> extends StatefulWidget {
  final T item;
  final String nullItemMessage;
  final String itemHintMessage;
  final List<T> suggestions;
  final void Function(String) fetchItems;
  final void Function(T) onChanged;

  ItemPicker(
      {@required this.item,
      @required this.suggestions,
      @required this.nullItemMessage,
      @required this.itemHintMessage,
      @required this.fetchItems,
      @required this.onChanged,
      Key key})
      : super(key: key);

  @override
  _ItemPickerState createState() => _ItemPickerState();
}

class _ItemPickerState<T extends EquatableWithName>
    extends State<ItemPicker<T>> {
  final itemController = TextEditingController();

  @override
  void dispose() {
    itemController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        Text(
          widget.item == null ? widget.nullItemMessage : widget.itemHintMessage,
          style: TextStyle(
              color: widget.item != null
                  ? Theme.of(context).textTheme.caption.color
                  : Theme.of(context).errorColor,
              fontSize: Theme.of(context).textTheme.caption.fontSize),
        ),
        Text(
          (widget.item != null ? widget.item.displayName() : '-'),
          style:
              TextStyle(color: widget.item != null ? Colors.black : Colors.red),
        ),
        Padding(
          padding: const EdgeInsets.only(left: 8.0, top: 8.0),
          child: Container(
            padding: EdgeInsets.all(8.0),
            color: Colors.deepPurple[50],
            child: Column(children: [
              TextField(
                controller: itemController,
                onChanged: (value) => widget.fetchItems(value),
                decoration: InputDecoration(
                  isDense: true,
                  icon: Icon(Icons.filter_alt_outlined, size: 16.0),
                ),
              ),
              if (widget.suggestions.length == 0)
                const SizedBox.shrink()
              else
                Card(
                  child: Column(
                    children: widget.suggestions
                        .map(
                          (r) => InkWell(
                            onTap: () => setState(() {
                              itemController.text = '';
                              widget.onChanged(r);
                            }),
                            child: Container(
                              alignment: Alignment.centerLeft,
                              padding: EdgeInsets.all(4.0),
                              child: Text(r.displayName()),
                            ),
                          ),
                        )
                        .toList(),
                  ),
                  elevation: 2.0,
                ),
            ]),
          ),
        ),
      ],
    );
  }
}
