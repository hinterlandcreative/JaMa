import 'package:flutter_test/flutter_test.dart';
import 'package:jama/services/database_service.dart';
import 'package:mockito/mockito.dart';

import 'mocks/app_database_mock.dart';
import 'mocks/database_provider_mock.dart';

void main() {
  group("DatabaseService tests:", () {
    test("DatabaseService.getMainStorage() always returns a local database", () async {
      var appDb = AppDatabaseMock();

      var dpProviderMock = DatabaseProviderMock();
      when(dpProviderMock.getLocalDatabase(any)).thenAnswer((_) async => appDb);

      var dbService = DatabaseService(dpProviderMock);

      var db = await dbService.getMainStorage();

      expect(db, same(appDb));
      verify(dpProviderMock.getLocalDatabase(any)).called(1);
    });
  });
}