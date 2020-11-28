import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'config.dart';
import 'region.dart';

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
    return MultiProvider(
      providers: [ChangeNotifierProvider.value(value: RegionsProvider(config))],
      child: MaterialApp(
        title: 'Wine Rate',
        initialRoute: '/',
        routes: {
          '/': (context) => HomeScreen(),
          '/regions': (context) => RegionScreen(),
        },
        theme: ThemeData(
          primarySwatch: Colors.deepPurple,
        ),
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
        drawer: MyDrawer(),
        body: Center(child: Text('Wine Rate')));
  }
}

class RegionScreen extends StatelessWidget {
  DataTable table(RegionsProvider r) {
    return DataTable(
      columns: [
        DataColumn(label: Text('Nom')),
        DataColumn(label: Text('Action'))
      ],
      rows: List<DataRow>.generate(
          r.allRegions.length,
          (i) => DataRow(cells: [
                DataCell(Text(r.allRegions[i].name)),
                DataCell(Row(
                  children: [
                    IconButton(
                        onPressed: () =>
                            r.insert(new Region("nouvelle région")),
                        icon: Icon(Icons.add)),
                    IconButton(
                        onPressed: () => r.remove(r.allRegions[i]),
                        icon: Icon(Icons.delete)),
                  ],
                ))
              ])),
    );
  }

  @override
  Widget build(BuildContext context) {
    Provider.of<RegionsProvider>(context).getAll();
    return Scaffold(
      appBar: AppBar(
        title: Text('Wine Rate'),
      ),
      drawer: MyDrawer(),
      body: Consumer<RegionsProvider>(builder: (context, provider, child) {
        return table(provider);
      }),
    );
  }
}

class MyDrawer extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Drawer(
        child: ListView(
      children: [
        Container(
            height: 64.0,
            child: DrawerHeader(
              child: Text('Menu', style: TextStyle(color: Colors.white)),
              decoration: BoxDecoration(color: Colors.deepPurple),
            )),
        ListTile(
          dense: true,
          title: Text('Régions'),
          leading: Icon(Icons.map),
          onTap: () {
            Navigator.pushNamed(context, '/regions');
          },
        ),
        ListTile(
          dense: true,
          title: Text('Appellation'),
          leading: Icon(Icons.location_on),
        ),
        ListTile(
          dense: true,
          title: Text('Domaines'),
          leading: Icon(Icons.home_outlined),
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
        ),
      ],
    ));
  }
}
