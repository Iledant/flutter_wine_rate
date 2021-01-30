import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_wine_rate/wine_screen.dart';
import 'package:hooks_riverpod/hooks_riverpod.dart';
import 'package:postgres/postgres.dart';
import 'bloc/pick_critics_bloc.dart';
import 'bloc/pick_domains_bloc.dart';
import 'bloc/pick_locations.dart';
import 'bloc/pick_regions.dart';
import 'bloc/pick_wines_bloc.dart';
import 'bloc/wines_bloc.dart';
import 'config.dart';
import 'common_scaffold.dart';
import 'bloc/critics.dart';
import 'bloc/domains.dart';
import 'bloc/regions.dart';
import 'bloc/locations.dart';
import 'critic_screen.dart';
import 'region_screen.dart';
import 'domain_screen.dart';
import 'location_screen.dart';
import 'bloc/rates.dart';
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
    return MultiBlocProvider(
      providers: [
        BlocProvider<CriticsBloc>(create: (context) => CriticsBloc()),
        BlocProvider<DomainsBloc>(create: (context) => DomainsBloc()),
        BlocProvider<RegionsBloc>(create: (context) => RegionsBloc()),
        BlocProvider<LocationsBloc>(create: (context) => LocationsBloc()),
        BlocProvider<WinesBloc>(create: (context) => WinesBloc()),
        BlocProvider<PickRegionsBloc>(create: (context) => PickRegionsBloc()),
        BlocProvider<PickLocationsBloc>(
            create: (context) => PickLocationsBloc()),
        BlocProvider<PickDomainsBloc>(create: (context) => PickDomainsBloc()),
        BlocProvider<PickCriticsBloc>(create: (context) => PickCriticsBloc()),
        BlocProvider<PickWinesBloc>(create: (context) => PickWinesBloc()),
        BlocProvider<RatesBloc>(create: (context) => RatesBloc()),
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
      ),
    );
  }
}
