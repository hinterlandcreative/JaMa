import 'package:kiwi/kiwi.dart';
import 'package:sqflite/sqflite.dart';
import 'package:path/path.dart';

class DatabaseProvider2 {
  final LocalDatabaseFactory2 _localDatabaseFactory;

  DatabaseProvider2._(this._localDatabaseFactory);

  /// Creates a `DatabaseProvider2` from a [localFactory].
  factory DatabaseProvider2([LocalDatabaseFactory2 localFactory]) {
    return DatabaseProvider2._(localFactory ?? Container().resolve<LocalDatabaseFactory2>());
  }

  Future<Database> getLocalDatabase(String name) async {
    return await _localDatabaseFactory.create(name);
  }
}

class LocalDatabaseFactory2 {
  Future<Database> create(String name) async {
    if (name == null || name.isEmpty) {
      throw ArgumentError.notNull("name");
    }

    if (!name.endsWith(".db")) {
      name = "$name.db";
    }

    var databasesPath = await getDatabasesPath();
    var path = join(databasesPath, name);

    return await openDatabase(path, version: 1, onCreate: (Database db, int version) async {
      for (var exec in _version1Create) {
        await db.execute(exec);
      }
    });
  }

  static const List<String> _version1Create = [
    """CREATE TABLE TimeEntries (
	TimeEntryId integer PRIMARY KEY AUTOINCREMENT,
	Date integer,
	TotalMinutes integer,
	Placements integer,
	Videos integer,
	FK_TimeCategory_Time integer,
  TimeNotes text
);""",
    """CREATE TABLE TimeCategory (
	TimeCategoryId integer PRIMARY KEY AUTOINCREMENT,
	Name text,
	Color text,
	Description text
);""",
    """CREATE TABLE ReturnVisit (
	ReturnVisitId integer PRIMARY KEY AUTOINCREMENT,
	Name text,
	RvNotes text,
	ImagePath text,
	Address text,
	Gender text,
	LastVisitDate integer,
	Pinned integer,
	FK_Visit_ReturnVisit_LastVisit integer
);""",
    """CREATE TABLE Visit (
	VisitId integer PRIMARY KEY AUTOINCREMENT,
	Date integer,
	VisitNotes text,
	VisitType text,
	NextTopic text,
	FK_ReturnVisit_Visit_ParentRv integer
);""",
    """CREATE TABLE Placements (
	PlacementId integer PRIMARY KEY AUTOINCREMENT,
	Count integer,
	PlacementNotes text,
	PlacementType text,
	FK_Visit_Placement_ParentVisit text
);
"""
  ];
}
