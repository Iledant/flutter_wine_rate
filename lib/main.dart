import 'package:flutter/material.dart';
import 'package:flutter_redux/flutter_redux.dart';
import 'package:flutter_wine_rate/redux/store.dart';
import 'package:flutter_wine_rate/region_screen.dart';
import 'config.dart';
import 'drawer.dart';

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
    return MaterialApp(
      title: 'Wine Rate',
      initialRoute: '/',
      routes: {
        '/': (context) => HomeScreen(),
        '/regions': (context) => StoreProvider<AppState>(
              store: Redux.store,
              child: RegionScreen(config),
            )
      },
      theme: ThemeData(
        primarySwatch: Colors.deepPurple,
      ),
    );
  }
}

class HomeScreen extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Wine Rate'),
      ),
      drawer: AppDrawer(),
      body: Center(
        child: Text(
          'Wine Rate',
          style: TextStyle(
            fontSize: 32.0,
          ),
        ),
      ),
    );
  }
}
