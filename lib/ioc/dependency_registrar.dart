import 'package:jama/data/core/db/database_provider.dart';
import 'package:jama/services/app_settings_service.dart';
import 'package:jama/services/database_service.dart';
import 'package:jama/services/image_service.dart';
import 'package:jama/services/location_service.dart';
import 'package:jama/services/reporting_service.dart';
import 'package:jama/services/return_visit_service.dart';
import 'package:jama/services/time_service.dart';
import 'package:kiwi/kiwi.dart';

class DependencyRegistrar {
  static void register() {
    Container container = Container();
    container.registerSingleton((c) => LocalDatabaseFactory());
    container.registerSingleton((c) => DatabaseProvider());
    container.registerSingleton((c) => DatabaseService());
    container.registerSingleton((c) => TimeService());
    container.registerSingleton((c) => ReturnVisitService());
    container.registerSingleton((c) => AppSettingsService());
    container.registerInstance(LocationService());
    container.registerSingleton((c) => ImageService());
    container.registerSingleton((c) => ReportingService());
  }
}
