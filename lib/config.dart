import 'package:postgres/postgres.dart';
import "package:yaml/yaml.dart";
import 'dart:io';

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
  static Config _config;
  Config._internal();

  factory Config() {
    if (_config == null) {
      _config = Config._internal();
    }
    return _config;
  }
  static Config get config => _config;

  final Log _log = new Log('flutter-wine-rate.log');

  static PostgreSQLConnection _db;

  Future<PostgreSQLConnection> get db async {
    if (_db != null) return _db;
    try {
      File cfgFile = new File('./config.yml');
      final configText = await cfgFile.readAsString();
      final cfgMap = loadYaml(configText);
      final dbConfig = cfgMap['db_config'];
      String host = dbConfig['host'];
      int port = dbConfig['port'];
      String user = dbConfig['user'];
      String dbName = dbConfig['db_name'];
      String password = dbConfig['password'];
      _db = new PostgreSQLConnection(host, port, dbName,
          username: user, password: password);
      await _db.open();
      return _db;
    } catch (e) {
      this._log.log('erreur de configuration $e');
      exit(1);
    }
  }

  void log(String msg) {
    _log.log(msg);
  }
}
