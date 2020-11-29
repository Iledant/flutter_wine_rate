import 'dart:math';

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
    return MaterialApp(
      title: 'Wine Rate',
      initialRoute: '/',
      routes: {
        '/': (context) => HomeScreen(),
        '/regions': (context) => RegionScreen(config),
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
        drawer: MyDrawer(),
        body: Center(child: Text('Wine Rate')));
  }
}

class RegionScreen extends StatefulWidget {
  final Config _config;

  RegionScreen(this._config);

  @override
  _RegionScreenState createState() => _RegionScreenState(this._config);
}

class _RegionScreenState extends State<RegionScreen> {
  final _controller = TextEditingController();
  String _searchText = '';
  Config _config;
  Future<List<Region>> _regions;

  _RegionScreenState(this._config);

  void initState() {
    super.initState();
    _regions = _config.getRegions();
    _controller.addListener(() {
      setState(() {
        _searchText = _controller.text.toLowerCase();
      });
    });
  }

  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  void addRegion() async {
    _config.insertRegion(new Region("nouvelle région"));
    setState(() {
      _regions = _config.getRegions();
    });
  }

  void removeRegion(Region reg) async {
    _config.removeRegion(reg);
    setState(() {
      _regions = _config.getRegions();
    });
  }

  Widget regionTable(List<Region> regions) {
    final lines = regions
        .where((r) => r.name.toLowerCase().contains(_searchText))
        .toList();

    return Card(
        child: DataTable(
          headingRowColor: MaterialStateProperty.resolveWith<Color>(
              (Set<MaterialState> states) {
            return Colors.deepPurple.shade50;
          }),
          headingTextStyle:
              TextStyle(fontWeight: FontWeight.w600, color: Colors.black),
          columns: [
            DataColumn(label: Text('Nom')),
            DataColumn(label: Text('Action'))
          ],
          rows: List<DataRow>.generate(
              lines.length,
              (i) => DataRow(cells: [
                    DataCell(Text(lines[i].name)),
                    DataCell(Row(
                      children: [
                        IconButton(
                            iconSize: 16.0,
                            splashRadius: 16.0,
                            onPressed: addRegion,
                            icon: Icon(Icons.edit)),
                        IconButton(
                            splashRadius: 16.0,
                            iconSize: 16.0,
                            onPressed: () => removeRegion(lines[i]),
                            icon: Icon(Icons.delete)),
                      ],
                    ))
                  ])),
        ),
        elevation: 3.0);
  }

  @override
  Widget build(BuildContext context) {
    final screenWidth = MediaQuery.of(context).size.width;
    return Scaffold(
        appBar: AppBar(
          title: Text('Wine Rate'),
        ),
        drawer: MyDrawer(),
        body: Padding(
            padding: EdgeInsets.all(8),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(crossAxisAlignment: CrossAxisAlignment.end, children: [
                  Icon(Icons.map),
                  Text(' Régions', style: TextStyle(fontSize: 24.0))
                ]),
                Center(
                    child: Container(
                        alignment: Alignment.center,
                        width: min(max(300, screenWidth * 0.5), screenWidth),
                        child: TextFormField(
                          controller: _controller,
                          decoration: InputDecoration(
                              icon: Icon(Icons.search), hintText: 'Recherche'),
                        ))),
                Padding(
                    padding: EdgeInsets.only(top: 8.0),
                    child: Center(
                        child: FutureBuilder<List<Region>>(
                            future: _regions,
                            builder: (BuildContext context,
                                AsyncSnapshot<List<Region>> snapshot) {
                              if (snapshot.hasData) {
                                return regionTable(snapshot.data);
                              } else if (snapshot.hasError) {
                                return Card(
                                    color: Colors.red,
                                    child: Text(
                                        'Impossible de récupérer la liste des régions'));
                              } else {
                                return SizedBox(
                                    child: CircularProgressIndicator(),
                                    width: 60,
                                    height: 60);
                              }
                            })))
              ],
            )));
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
