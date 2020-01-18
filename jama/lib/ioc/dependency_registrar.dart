import 'package:jama/data/core/db/database_factory.dart';
import 'package:jama/data/core/db/database_provider.dart';
import 'package:jama/data/core/db/local_database_factory.dart';
import 'package:jama/data/core/db/remote_database_factory.dart';
import 'package:jama/services/database_service.dart';
import 'package:jama/services/time_service.dart';
import 'package:kiwi/kiwi.dart';

class DependencyRegistrar {
  static void register() {
    Container container = Container();

    container.registerSingleton<LocalDatabaseFactory, SembastDatabaseFactory>((c) => SembastDatabaseFactory());
    container.registerSingleton<RemoteDatabaseFactory, FirebaseDatabaseFactory>((c) => FirebaseDatabaseFactory());
    container.registerSingleton((c) => DatabaseProvider());
    container.registerSingleton((c) => DatabaseService());
    container.registerSingleton((c) => TimeService());
  }
}