import 'package:kiwi/kiwi.dart';
import 'package:sqflite/sqflite.dart';
import 'package:path/path.dart';

class DatabaseProvider {
  final LocalDatabaseFactory _localDatabaseFactory;

  DatabaseProvider._(this._localDatabaseFactory);

  /// Creates a `DatabaseProvider2` from a [localFactory].
  factory DatabaseProvider([LocalDatabaseFactory localFactory]) {
    return DatabaseProvider._(localFactory ?? KiwiContainer().resolve<LocalDatabaseFactory>());
  }

  Future<Database> getLocalDatabase(String name) async {
    return await _localDatabaseFactory.create(name);
  }
}

class LocalDatabaseFactory {
  const LocalDatabaseFactory();

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
	StreetAddress text,
	City text,
	StateOrDistrict text,
	PostalCode text,
	Country text,
	Latitude float,
	Gender text,
	Longitude float,
	LastVisitDate integer,
	FK_Visit_ReturnVisit_LastVisit integer,
	Pinned integer
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
	FK_Visit_Placement_ParentVisit integer
);"""
  ];
}
