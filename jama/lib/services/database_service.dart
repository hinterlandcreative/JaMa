import 'package:jama/data/core/db/app_database.dart';
import 'package:kiwi/kiwi.dart';
import 'package:jama/data/core/db/database_provider.dart';

class DatabaseService {
  final String _mainStorageDatabaseName = "appstore.db";
  DatabaseProvider _provider;

  DatabaseService([DatabaseProvider provider]) {
    Container container = Container();

    _provider = provider ?? container.resolve<DatabaseProvider>();
  }

  /// Gets the main storage database for the app.
  Future<AppDatabase> getMainStorage() async {
    return await _provider.getLocalDatabase(_mainStorageDatabaseName);
  }
}