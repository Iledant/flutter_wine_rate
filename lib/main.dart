import 'package:flutter/material.dart';
import 'package:flutter_redux/flutter_redux.dart';
import 'package:flutter_wine_rate/common_scaffold.dart';
import 'package:flutter_wine_rate/redux/store.dart';
import 'package:flutter_wine_rate/region_screen.dart';
import 'package:flutter_wine_rate/critic_screen.dart';
import 'config.dart';
import 'domain_screen.dart';
import 'location_screen.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  final config = new Config();
  await Redux.init();
  runApp(MyApp(config));
}

class MyApp extends StatelessWidget {
  final Config config;

  MyApp(this.config);

  @override
  Widget build(BuildContext context) {
    return StoreProvider<AppState>(
      store: Redux.store,
      child: MaterialApp(
        title: 'Wine Rate',
        initialRoute: '/',
        routes: {
          '/': (context) => CommonScaffold(
                  body: Center(
                child: Text('Wine Rate',
                    style: Theme.of(context).textTheme.headline1),
              )),
          '/regions': (context) => RegionScreen(config),
          '/critics': (context) => CriticScreen(config),
          '/domains': (context) => DomainScreen(config),
          '/locations': (context) => LocationScreen(config: config),
        },
        theme: ThemeData(
          primarySwatch: Colors.purple,
        ),
      ),
    );
  }
}
