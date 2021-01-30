import 'package:flutter/material.dart';

class FilteredMenu<T> extends StatelessWidget {
  final void Function(String) fetchHook;
  final Function(T) onChanged;
  final List<T> values;
  final String Function(T) valueDisplay;

  FilteredMenu(
      {@required this.fetchHook,
      @required this.onChanged,
      this.values = const [],
      @required this.valueDisplay});

  final _textController = TextEditingController();

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: EdgeInsets.all(8.0),
      color: Colors.deepPurple[50],
      child: Column(
        children: [
          TextField(
            controller: _textController,
            onChanged: (value) => fetchHook(value),
            decoration: InputDecoration(
              isDense: true,
              icon: Icon(Icons.filter_alt_outlined, size: 16.0),
            ),
          ),
          if (values.isEmpty)
            const SizedBox.shrink()
          else
            Card(
              child: Column(
                children: values
                    .map(
                      (r) => InkWell(
                        onTap: () => onChanged(r),
                        child: Container(
                          alignment: Alignment.centerLeft,
                          padding: EdgeInsets.all(4.0),
                          child: Text(valueDisplay(r)),
                        ),
                      ),
                    )
                    .toList(),
              ),
              elevation: 2.0,
            ),
        ],
      ),
    );
  }
}
