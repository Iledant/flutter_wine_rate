import 'package:flutter/material.dart';

class AppDrawer extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Drawer(
        child: ListView(
      children: [
        Container(
            height: 64.0,
            child: DrawerHeader(
              child: Text('Menu', style: TextStyle(color: Colors.white)),
              decoration: BoxDecoration(color: Colors.purple.shade900),
            )),
        ListTile(
          dense: true,
          title: Text('Régions'),
          leading: Icon(Icons.map),
          onTap: () => Navigator.pushNamed(context, '/regions'),
        ),
        ListTile(
          dense: true,
          title: Text('Appellations'),
          leading: Icon(Icons.location_on),
          onTap: () => Navigator.pushNamed(context, '/locations'),
        ),
        ListTile(
          dense: true,
          title: Text('Domaines'),
          leading: Icon(Icons.home_outlined),
          onTap: () => Navigator.pushNamed(context, '/domains'),
        ),
        ListTile(
          dense: true,
          title: Text('Vins'),
          leading: Icon(Icons.wine_bar_outlined),
        ),
        ListTile(
          dense: true,
          title: Text('Notations'),
          leading: Icon(Icons.stars),
        ),
        ListTile(
          dense: true,
          title: Text('Critiques'),
          leading: Icon(Icons.account_circle),
          onTap: () => Navigator.pushNamed(context, '/critics'),
        ),
      ],
    ));
  }
}
