import 'dart:async';

import 'package:flutter/material.dart';
import 'package:flutter_redux/flutter_redux.dart';
import 'package:redux/redux.dart';

import 'redux/store.dart';

class FilteredMenu<T> extends StatefulWidget {
  final void Function(String) fetchHook;
  final List<T> Function(Store<AppState>) converter;
  final Function(T) onChanged;
  final String Function(T) valueDisplay;

  FilteredMenu(
      {@required this.fetchHook,
      @required this.converter,
      @required this.onChanged,
      @required this.valueDisplay});

  @override
  _FilteredMenuState createState() => _FilteredMenuState();
}

class _FilteredMenuState<T> extends State<FilteredMenu<T>> {
  bool _showSuggestions;
  Timer _debounce;
  final _textController = TextEditingController();

  @override
  void initState() {
    super.initState();
    _showSuggestions = false;
  }

  void _debounceSearch(String pattern) {
    if (_debounce?.isActive ?? false) _debounce.cancel();
    _debounce = Timer(const Duration(milliseconds: 500), () {
      setState(() {
        _showSuggestions = true;
        widget.fetchHook(pattern);
      });
    });
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: EdgeInsets.all(8.0),
      color: Colors.deepPurple[50],
      child: Column(
        children: [
          TextField(
            controller: _textController,
            onChanged: (value) => _debounceSearch(value),
            decoration: InputDecoration(
              isDense: true,
              icon: Icon(Icons.filter_alt_outlined, size: 16.0),
            ),
          ),
          StoreConnector<AppState, List<T>>(
            distinct: true,
            converter: widget.converter,
            builder: (context, values) {
              if (values.length == 0 || !_showSuggestions)
                return SizedBox.shrink();
              return Card(
                child: Column(
                  children: values
                      .map(
                        (r) => InkWell(
                          onTap: () => setState(() {
                            widget.onChanged(r);
                            _textController.clear();
                            _showSuggestions = false;
                          }),
                          child: Container(
                            alignment: Alignment.centerLeft,
                            padding: EdgeInsets.all(4.0),
                            child: Text(widget.valueDisplay(r)),
                          ),
                        ),
                      )
                      .toList(),
                ),
                elevation: 2.0,
              );
            },
          ),
        ],
      ),
    );
  }
}
