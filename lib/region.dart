import 'config.dart';
import 'package:flutter/material.dart';

class Region {
  String name;
  int id;

  Region(this.name, {this.id = 0});
}

class RegionsProvider extends ChangeNotifier {
  List<Region> _regions = [];
  Config config;

  RegionsProvider(this.config);

  List<Region> get allRegions => _regions;

  void getAll() async {
    var results = await config.query("SELECT id,name FROM region");
    this._regions = List.generate(
        results.length, (i) => new Region(results[i][1], id: results[i][0]));
    notifyListeners();
  }

  void insert(Region reg) async {
    await config.query("INSERT INTO region (name) VALUES (@name) RETURNING id",
        values: {"name": reg.name});
    notifyListeners();
  }

  void update(Region reg) async {
    await config.query("UPDATE region SET name=@name WHERE id=@id",
        values: {"name": reg.name, "id": reg.id});
    notifyListeners();
  }

  void remove(Region reg) async {
    print('Region ${reg.id}  ${reg.name}');
    await config
        .query("DELETE FROM region WHERE id=@id", values: {"id": reg.id});
    notifyListeners();
  }
}
