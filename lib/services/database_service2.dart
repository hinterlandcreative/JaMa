import 'package:sqflite/sqflite.dart';
import 'package:kiwi/kiwi.dart';

import 'package:jama/data/core/db/database_provider2.dart';

class DatabaseService2 {
  static const String _localDatabaseName = "app_storage.db";
  final DatabaseProvider2 _databaseProvider;

  const DatabaseService2._(this._databaseProvider);

  /// Creates an instance of the `DatabaseService`.
  /// For unit testing provide a [dbProvider] otherwise
  /// the `DatabaseProvider` will be provided by the [context].
  factory DatabaseService2([DatabaseProvider2 dbProvider]) {
    return DatabaseService2._(dbProvider ?? Container().resolve<DatabaseProvider2>());
  }

  /// Gets the local SQLite `Database` for the main app storage.
  Future<Database> getLocalMainStorage() async {
    return await _databaseProvider.getLocalDatabase(_localDatabaseName);
  }
}
