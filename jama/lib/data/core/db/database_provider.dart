import 'package:kiwi/kiwi.dart';
import 'app_database.dart';
import 'database_factory.dart';
import 'package:path/path.dart';

class DatabaseProvider {
  LocalDatabaseFactory _localDbFactory;
  RemoteDatabaseFactory _remoteDbFactory;
  Map<String, AppDatabase> _localDatabases = Map<String, AppDatabase>();
  Map<String, AppDatabase> _remoteDatabases = Map<String, AppDatabase>();

  /// Creates an instance of the database provider.
  DatabaseProvider([LocalDatabaseFactory local, RemoteDatabaseFactory remote]) {
    Container container = Container();

    _localDbFactory = local ?? container.resolve<LocalDatabaseFactory>();
    _remoteDbFactory = remote ?? container.resolve<RemoteDatabaseFactory>();
  }

/// Gets a local database with the given [dbName].
 Future<AppDatabase> getLocalDatabase(String dbName) async {
   final name = _normalizeName(dbName);
   if(_localDatabases.containsKey(name)) {
     return _localDatabases[name];
   }

    return _localDatabases[name] = await _localDbFactory.create(name);  
  }

  Future<AppDatabase> getRemoteDatabase(String dbName) async {
    final name = _normalizeName(dbName);
    if(_remoteDatabases.containsKey(name)) {
      return _remoteDatabases[name];
    }

    return _remoteDatabases[name] = await _remoteDbFactory.create(name);
  }

  String _normalizeName(String dbName) {
    if(!dbName.endsWith(".db")) {
      dbName = join(dbName, ".db");
    }
    
   return dbName.toLowerCase();
  }
}






  