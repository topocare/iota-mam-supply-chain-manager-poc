import 'package:path/path.dart';
import 'package:sqflite/sqflite.dart';

/// sqflite Database for permanent Data
/// currently manages owned channels (in form of the "channelDefiningObject" and the "ChannelOwnership"
class DatabaseAdapter {
  Database database;

  Future<void> init() async {
    database = await openDatabase(
      join(await getDatabasesPath(), 'iotaSCM.db'),
      onCreate: (database, version) {
        database.execute(
            "CREATE TABLE ownedChannels(id INTEGER PRIMARY KEY, firstRoot TEXT, nextRoot TEXT, seed TEXT, mamStartIndex INTEGER, data TEXT)");
        database.execute(
            "CREATE TABLE trustedManufacturers(firstRoot TEXT PRIMARY KEY, description TEXT)");
      },
      version: 1,
    );
    return null;
  }

  //ownedChannel
  Future<int> addOwnedChannel(String root, String nextRoot, String seed,
      int mamStartIndex, String messageAsTrytes) async {
    return database.insert('ownedChannels', {
      'firstRoot': root,
      'nextRoot': nextRoot,
      'seed': seed,
      'mamStartIndex': mamStartIndex,
      'data': messageAsTrytes
    });
  }

  Future<void> updateOwnedChannel(int id, int newMamStartIndex) async {
    await database.update('ownedChannels', {'mamStartIndex': newMamStartIndex},
        where: "id = ?", whereArgs: [id]);
    return null;
  }

  Future<void> deleteOwnedChannel(int id) async {
    await database.delete('ownedChannels', where: "id = ?", whereArgs: [id]);
    return null;
  }

  Future<List<Map<String, dynamic>>> ownedChannelsAsList() async {
    return database.query('ownedChannels');
  }

  //trustedManufacturer
  Future<int> addTrustedManufacturer(String root, String description) async {
    return database.insert(
        'trustedManufacturers', {'firstRoot': root, 'description': description},
        conflictAlgorithm: ConflictAlgorithm.ignore);
  }

  Future<void> deleteTrustedManufacturer(String root) async {
    await database.delete('trustedManufacturers',
        where: "firstRoot = ?", whereArgs: [root]);
    return null;
  }

  Future<List<Map<String, dynamic>>> trustedManufacturersAsList() async {
    return database.query('trustedManufacturers');
  }

  Future<void> deleteAll() async{
    await database.delete('ownedChannels');
    await database.delete('trustedManufacturers');
  }
}
