import 'package:sqflite/sqflite.dart';
import 'package:kiwi/kiwi.dart';

import 'package:jama/data/core/db/database_provider.dart';

class DatabaseService {
  static const String _localDatabaseName = "app_storage.db";
  final DatabaseProvider _databaseProvider;

  const DatabaseService._(this._databaseProvider);

  /// Creates an instance of the `DatabaseService`.
  /// For unit testing provide a [dbProvider] otherwise
  /// the `DatabaseProvider` will be provided by the [context].
  factory DatabaseService([DatabaseProvider dbProvider]) {
    return DatabaseService._(dbProvider ?? Container().resolve<DatabaseProvider>());
  }

  /// Gets the local SQLite `Database` for the main app storage.
  Future<Database> getLocalMainStorage() async {
    return await _databaseProvider.getLocalDatabase(_localDatabaseName);
  }
}
