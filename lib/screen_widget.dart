import 'package:flutter/material.dart';

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
