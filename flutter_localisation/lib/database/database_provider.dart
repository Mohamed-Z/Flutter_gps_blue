import 'package:flutterlocalisation/models/localisation.dart';
import 'package:path/path.dart';
import 'package:sqflite/sqflite.dart';

class DatabaseProvider{
  static const TABLE_LOCALISATION = "localisation";
  static const COLUMN_ID = "id";
  static const COLUMN_LATITUDE = "latitude";
  static const COLUMN_LONGITUDE = "longitude";
  static const COLUMN_TIME = "time";

  DatabaseProvider._();
  static final DatabaseProvider db = DatabaseProvider._();

  Database _database;

  Future<Database> get database async {
    print("database getter called");

    if(_database != null){
      return _database;
    }
    
    _database = await createDatabase();
    return _database;
  }

  Future<Database> createDatabase() async {
    String dbPath = await getDatabasesPath();

    return await openDatabase(
      join(dbPath, 'localisationDB.db'),
      version: 1, //incrementer la version pour modifier la bd
      onCreate: (Database database, int version) async {
        print("creating localisation table");
        await database.execute(
          "CREATE TABLE $TABLE_LOCALISATION ("
              "$COLUMN_ID INTEGER PRIMARY KEY,"
              "$COLUMN_LATITUDE TEXT,"
              "$COLUMN_LONGITUDE TEXT,"
              "$COLUMN_TIME TEXT"
              ")",
        );
      }
    );
  }

  Future<List<Localisation>> getLocalisations() async {
    final db = await database;
    var localisations = await db.query(
      TABLE_LOCALISATION,
      columns: [COLUMN_ID,COLUMN_LATITUDE,COLUMN_LONGITUDE,COLUMN_TIME]
    );

    List<Localisation> localisationList = List<Localisation>();

    localisations.forEach((currentLocalisation) {
      Localisation localisation = Localisation.fromMap(currentLocalisation);
      localisationList.add(localisation);
    });

    return localisationList;
  }

  Future<Localisation> insert(Localisation localisation) async {
    final db = await database;
    localisation.id = await db.insert(TABLE_LOCALISATION, localisation.toMap());

    return localisation;
  }

  Future<int> delete() async {
    final db = await database;

    return await db.delete(
      TABLE_LOCALISATION,
      where: "1",
      whereArgs: null
    );
  }

  Future<int> update(Localisation localisation) async {
    final db = await database;

    return await db.update(TABLE_LOCALISATION,
    localisation.toMap(),
      where: "id = ?",
      whereArgs: [localisation.id]
    );
  }
}