import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'config.dart';
import 'common_scaffold.dart';
import 'redux/store.dart';
import 'bloc/critics.dart';
import 'repo/critic_repo.dart';
import 'critic_screen.dart';
import 'region_screen.dart';
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
    return MultiBlocProvider(
      providers: [
        BlocProvider<CriticsBloc>(
          create: (context) =>
              CriticsBloc(criticRepository: CriticRepository(db: config.db)),
        )
      ],
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
          '/critics': (context) => CriticScreen(),
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
