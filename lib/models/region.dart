import '../config.dart';

class Region {
  String name;
  int id;

  Region(this.id, this.name);

  Region copy() => Region(id, name);

  static Future<List<Region>> getAll(Config config) {
    return config
        .query("SELECT id,name FROM region")
        .then((results) => results.map((e) => Region(e[0], e[1])).toList());
  }

  Future<void> add(Config config) async {
    final results = await config.query(
        "INSERT INTO region (name) VALUES (@name) RETURNING id",
        values: {"name": name});
    id = results[0][0];
  }

  Future<void> update(Config config) async {
    await config.query("UPDATE region SET name=@name WHERE id=@id",
        values: {"name": name, "id": id});
  }

  Future<void> remove(Config config) async {
    await config.query("DELETE FROM region WHERE id=@id", values: {"id": id});
  }
}
