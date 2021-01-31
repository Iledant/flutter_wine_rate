import 'package:flutter/material.dart';
import 'package:flutter_wine_rate/wine_screen.dart';
import 'package:hooks_riverpod/hooks_riverpod.dart';
import 'package:postgres/postgres.dart';
import 'config.dart';
import 'common_scaffold.dart';
import 'critic_screen.dart';
import 'region_screen.dart';
import 'domain_screen.dart';
import 'location_screen.dart';
import 'rate_screen.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  final config = Config();
  final db = await config.db;
  runApp(ProviderScope(child: MyApp(db)));
}

class MyApp extends StatelessWidget {
  final PostgreSQLConnection db;

  MyApp(this.db);

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Wine Rate',
      initialRoute: '/',
      routes: {
        '/': (context) => CommonScaffold(
                body: Center(
              child: Text('Wine Rate',
                  style: Theme.of(context).textTheme.headline1),
            )),
        '/regions': (context) => RegionScreen(),
        '/critics': (context) => CriticScreen(),
        '/domains': (context) => DomainScreen(),
        '/locations': (context) => LocationScreen(),
        '/wines': (context) => WineScreen(),
        '/rates': (context) => RateScreen(),
      },
      theme: ThemeData(
        primarySwatch: Colors.purple,
      ),
    );
  }
}
