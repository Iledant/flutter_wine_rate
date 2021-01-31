import 'package:flutter/material.dart';

class _DrawerItem {
  final String title;
  final IconData icon;
  final String route;

  const _DrawerItem(
      {@required this.title, @required this.icon, @required this.route});
}

final _drawerItems = [
  _DrawerItem(title: 'Régions', icon: Icons.map, route: '/regions'),
  _DrawerItem(
      title: 'Appellations', icon: Icons.location_on, route: '/locations'),
  _DrawerItem(title: 'Domaines', icon: Icons.home_outlined, route: '/domains'),
  _DrawerItem(title: 'Vins', icon: Icons.wine_bar_outlined, route: '/wines'),
  _DrawerItem(title: 'Notations', icon: Icons.stars, route: '/rates'),
  _DrawerItem(
      title: 'Critiques', icon: Icons.account_circle, route: '/critics'),
];

class AppDrawer extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Drawer(
        child: ListView(
      children: [
        Container(
          height: 64.0,
          child: DrawerHeader(
            child:
                const Text('Menu', style: const TextStyle(color: Colors.white)),
            decoration: BoxDecoration(color: Colors.purple.shade900),
          ),
        ),
        ..._drawerItems
            .map(
              (item) => ListTile(
                dense: true,
                title: Text(item.title),
                leading: Icon(item.icon),
                onTap: () => Navigator.pushNamed(context, item.route),
              ),
            )
            .toList(),
      ],
    ));
  }
}
