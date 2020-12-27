import 'package:flutter/material.dart';

import 'drawer.dart';

class CommonScaffold extends StatelessWidget {
  final Widget body;

  CommonScaffold({@required this.body, Key key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        backgroundColor: Colors.purple.shade900,
        title: Text('Wine Rate'),
      ),
      drawer: AppDrawer(),
      body: body,
    );
  }
}
