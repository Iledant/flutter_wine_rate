import 'package:postgres/postgres.dart';
import "package:yaml/yaml.dart";
import 'dart:io';
import 'region.dart';

class Log {
  static File _logFile;

  Log(String fileName) {
    Log._logFile = new File(fileName);
  }

  void log(String msg) {
    if (_logFile != null) {
      return;
    }
    var now = new DateTime.now().toLocal().toString();
    _logFile.writeAsStringSync('$now : msg');
  }
}

class Config {
  PostgreSQLConnection _db;
  Log _log;

  Config() {
    this._log = new Log('flutter-wine-rate.log');
    try {
      File cfgFile = new File('./config.yml');
      final configText = cfgFile.readAsStringSync();
      dynamic cfgMap = loadYaml(configText);
      connect(cfgMap);
    } catch (e) {
      this._log.log('erreur de configuration $e');
      exit(1);
    }
  }

  connect(dynamic config) async {
    String host = config['db_config']['host'];
    int port = config['db_config']['port'];
    String user = config['db_config']['user'];
    String dbName = config['db_config']['db_name'];
    String password = config['db_config']['password'];
    this._db = new PostgreSQLConnection(host, port, dbName,
        username: user, password: password);
    await this._db.open();
  }

  void log(String msg) {
    _log.log(msg);
  }

  Future<PostgreSQLResult> query(String qry,
      {Map<String, dynamic> values}) async {
    return this._db.query(qry, substitutionValues: values);
  }

  Future<int> execute(String qry, {Map<String, dynamic> values}) async {
    return this._db.execute(qry, substitutionValues: values);
  }

  Future<List<Region>> getRegions() {
    return query("SELECT name,id FROM region").then(
        (results) => results.map((e) => new Region(e[0], id: e[1])).toList());
  }

  void insertRegion(Region reg) {
    query("INSERT INTO region (name) VALUES (@name) RETURNING id",
        values: {"name": reg.name});
  }

  void updateRegion(Region reg) {
    query("UPDATE region SET name=@name WHERE id=@id",
        values: {"name": reg.name, "id": reg.id});
  }

  void removeRegion(Region reg) {
    query("DELETE FROM region WHERE id=@id", values: {"id": reg.id});
  }
}
