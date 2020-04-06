import 'dart:io';
import 'package:path/path.dart';
import 'package:sqflite/sqflite.dart';
import 'package:path_provider/path_provider.dart';
import 'package:woocommerceadmin/src/db/models/Connection.dart';

class ConnectionDBProvider {
  static final _databaseName = "WoocommerceAdmin.db";
  static final _databaseVersion = 1;
  final String tableName = 'Connections';
  final String columnId = 'id';
  final String columnBaseurl = 'baseurl';
  final String columnUsername = 'username';
  final String columnPassword = 'password';

  // Make this a singleton class.
  ConnectionDBProvider._privateConstructor();
  static final ConnectionDBProvider db =
      ConnectionDBProvider._privateConstructor();

  // Only allow a single open connection to the database.
  static Database _database;

  Future<Database> get database async {
    if (_database != null) return _database;
    _database = await initDB();
    return _database;
  }

  // open the database
  initDB() async {
    Directory documentsDirectory = await getApplicationDocumentsDirectory();
    String path = join(documentsDirectory.path, _databaseName);
    return await openDatabase(path, version: _databaseVersion,
        onCreate: (Database db, int version) async {
      await db.execute(
          "CREATE TABLE $tableName ($columnId INTEGER PRIMARY KEY, $columnBaseurl TEXT, $columnUsername TEXT, $columnPassword TEXT)");
    });
  }

  // Database helper methods

  Future<int> getLastId() async {
    Database db = await database;
    var table =
        await db.rawQuery("SELECT MAX($columnId) as id FROM $tableName");
    int id = table.first["id"];
    if (id == null) {
      return 0;
    }
    return id;
  }

  Future<int> insertConnection(Connection connection) async {
    Database db = await database;
    int id = await db.insert(tableName, connection.toMap());
    return id;
  }

  Future<Connection> getConnection(int id) async {
    Database db = await database;
    List<Map> res = await db.query(tableName,
        columns: [columnId, columnBaseurl, columnUsername, columnPassword],
        where: '$columnId = ?',
        whereArgs: [id]);
    return res.isNotEmpty ? Connection.fromMap(res.first) : null;
  }

  Future<List<Connection>> getAllConnections() async {
    final db = await database;
    var res = await db.query(tableName);
    List<Connection> connectionList =
        res.isNotEmpty ? res.map((c) => Connection.fromMap(c)).toList() : [];
    return connectionList;
  }

  Future<int> updateConnection(Connection connection) async {
    final db = await database;
    var res = await db.update(tableName, connection.toMap(),
        where: "$columnId = ?", whereArgs: [connection.id]);
    return res;
  }

  deleteConnection(int id) async {
    final db = await database;
    db.delete(tableName, where: "$columnId = ?", whereArgs: [id]);
  }

  deleteAll() async {
    final db = await database;
    db.rawDelete("Delete * from $tableName");
  }
}
