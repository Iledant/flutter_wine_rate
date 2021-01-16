import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_wine_rate/wine_screen.dart';
import 'bloc/pick_critics_bloc.dart';
import 'bloc/pick_domains_bloc.dart';
import 'bloc/pick_locations.dart';
import 'bloc/pick_regions.dart';
import 'bloc/pick_wines_bloc.dart';
import 'bloc/wines_bloc.dart';
import 'config.dart';
import 'common_scaffold.dart';
import 'bloc/critics.dart';
import 'repo/critic_repo.dart';
import 'bloc/domains.dart';
import 'repo/domain_repo.dart';
import 'bloc/regions.dart';
import 'repo/region_repo.dart';
import 'bloc/locations.dart';
import 'repo/location_repo.dart';
import 'critic_screen.dart';
import 'region_screen.dart';
import 'domain_screen.dart';
import 'location_screen.dart';
import 'repo/wine_repo.dart';
import 'repo/rate_repo.dart';
import 'bloc/rates.dart';
import 'rate_screen.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  final config = new Config();
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
        ),
        BlocProvider<DomainsBloc>(
          create: (context) =>
              DomainsBloc(domainRepository: DomainRepository(db: config.db)),
        ),
        BlocProvider<RegionsBloc>(
          create: (context) =>
              RegionsBloc(regionRepository: RegionRepository(db: config.db)),
        ),
        BlocProvider<LocationsBloc>(
          create: (context) => LocationsBloc(
              locationRepository: LocationRepository(db: config.db)),
        ),
        BlocProvider<WinesBloc>(
          create: (context) =>
              WinesBloc(wineRepository: WineRepository(db: config.db)),
        ),
        BlocProvider<PickRegionsBloc>(
          create: (context) => PickRegionsBloc(
              regionRepository: RegionRepository(db: config.db)),
        ),
        BlocProvider<PickLocationsBloc>(
          create: (context) => PickLocationsBloc(
              locationRepository: LocationRepository(db: config.db)),
        ),
        BlocProvider<PickDomainsBloc>(
          create: (context) => PickDomainsBloc(
              domainRepository: DomainRepository(db: config.db)),
        ),
        BlocProvider<PickCriticsBloc>(
          create: (context) => PickCriticsBloc(
              criticRepository: CriticRepository(db: config.db)),
        ),
        BlocProvider<PickWinesBloc>(
          create: (context) =>
              PickWinesBloc(wineRepository: WineRepository(db: config.db)),
        ),
        BlocProvider<RatesBloc>(
          create: (context) =>
              RatesBloc(rateRepository: RateRepository(db: config.db)),
        ),
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
