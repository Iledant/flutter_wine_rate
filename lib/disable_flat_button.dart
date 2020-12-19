import 'package:flutter/material.dart';

class DisableFlatButton extends StatelessWidget {
  final bool disabled;
  final String text;
  final void Function() onPressed;

  DisableFlatButton(
      {@required this.disabled,
      @required this.text,
      @required this.onPressed,
      Key key})
      : super(key: key);

  @override
  Widget build(BuildContext context) {
    return IgnorePointer(
      ignoring: disabled,
      child: FlatButton(
        textColor: disabled ? Colors.grey : Theme.of(context).accentColor,
        child: Text(text),
        onPressed: () => disabled ? {} : onPressed,
      ),
    );
  }
}
