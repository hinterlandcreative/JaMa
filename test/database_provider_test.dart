import 'package:flutter_test/flutter_test.dart';
import 'package:jama/data/core/db/database_provider.dart';
import 'package:mockito/mockito.dart';
import 'package:path/path.dart';

import 'mocks/app_database_mock.dart';
import 'mocks/local_database_factory_mock.dart';
import 'mocks/remote_database_factory_mock.dart';

void main() {
  group("DatabaseProvider tests:", () {
    test("DatabaseProvider.getRemoteDatabase() normalizes the db name.", () async {
      final dbName = "someDbName";

      final appDbFake = AppDatabaseMock();

      final remoteDatabaseFactoryMock = RemoteDatabaseFactoryMock();
      when(remoteDatabaseFactoryMock.create(any)).thenAnswer((_) async => appDbFake);

      final provider = DatabaseProvider(LocalDatabaseFactoryMock(), remoteDatabaseFactoryMock);

      final db = await provider.getRemoteDatabase(dbName);

      expect(db, isNotNull);
      verify(remoteDatabaseFactoryMock.create(join(dbName.toLowerCase(), ".db"))).called(1);
    });
    test("DatabaseProvider.getRemoteDatabase() returns the same database.", () async {
      final dbName = "someDbName.db";

      final appDbFake = AppDatabaseMock();

      final remoteDatabaseFactoryMock = RemoteDatabaseFactoryMock();
      when(remoteDatabaseFactoryMock.create(any)).thenAnswer((_) async => appDbFake);

      final provider = DatabaseProvider(LocalDatabaseFactoryMock(), remoteDatabaseFactoryMock);

      final db = await provider.getRemoteDatabase(dbName);

      expect(db, isNotNull);
      verify(remoteDatabaseFactoryMock.create(any)).called(1);

      final db2 = await provider.getRemoteDatabase(dbName);
      expect(db2, same(db));
    });
    test("DatabaseProvider.getRemoteDatabase() doesn't recreate the same database twice.", () async {
      final dbName = "someDbName.db";

      final appDbFake = AppDatabaseMock();

      final remoteDatabaseFactoryMock = RemoteDatabaseFactoryMock();
      when(remoteDatabaseFactoryMock.create(any)).thenAnswer((_) async => appDbFake);

      final provider = DatabaseProvider(LocalDatabaseFactoryMock(), remoteDatabaseFactoryMock);

      final db = await provider.getRemoteDatabase(dbName);

      expect(db, isNotNull);

      await provider.getRemoteDatabase(dbName);

      verify(remoteDatabaseFactoryMock.create(any)).called(1);
    });
    test("DatabaseProvider.getRemoteDatabase() creates the remote database.", () async {
      final dbName = "someDbName.db";

      final appDbFake = AppDatabaseMock();

      final remoteDatabaseFactoryMock = RemoteDatabaseFactoryMock();
      when(remoteDatabaseFactoryMock.create(any)).thenAnswer((_) async => appDbFake);

      final provider = DatabaseProvider(LocalDatabaseFactoryMock(), remoteDatabaseFactoryMock);

      final db = await provider.getRemoteDatabase(dbName);

      expect(db, isNotNull);
      verify(remoteDatabaseFactoryMock.create(any)).called(1);
    });
    test("DatabaseProvider.getLocalDatabase() creates the local database.", () async {
      final dbName = "someDbName.db";

      final appDbFake = AppDatabaseMock();

      final localDatabaseFactoryFake = LocalDatabaseFactoryMock();
      when(localDatabaseFactoryFake.create(any)).thenAnswer((_) async => appDbFake);

      final provider = DatabaseProvider(localDatabaseFactoryFake, RemoteDatabaseFactoryMock());

      final db = await provider.getLocalDatabase(dbName);

      expect(db, isNotNull);
      verify(localDatabaseFactoryFake.create(any)).called(1);
    });
    test("DatabaseProvider.getLocalDatabase() doesn't recreate the same database twice.", () async {
      final dbName = "someDbName.db";

      final appDbFake = AppDatabaseMock();

      final localDatabaseFactoryFake = LocalDatabaseFactoryMock();
      when(localDatabaseFactoryFake.create(any)).thenAnswer((_) async => appDbFake);

      final provider = DatabaseProvider(localDatabaseFactoryFake, RemoteDatabaseFactoryMock());

      final db = await provider.getLocalDatabase(dbName);

      expect(db, isNotNull);

      await provider.getLocalDatabase(dbName);

      verify(localDatabaseFactoryFake.create(any)).called(1);
    });
    test("DatabaseProvider.getLocalDatabase() returns the same database.", () async {
      final dbName = "someDbName.db";

      final appDbFake = AppDatabaseMock();

      final localDatabaseFactoryFake = LocalDatabaseFactoryMock();
      when(localDatabaseFactoryFake.create(any)).thenAnswer((_) async => appDbFake);

      final provider = DatabaseProvider(localDatabaseFactoryFake, RemoteDatabaseFactoryMock());

      final db = await provider.getLocalDatabase(dbName);

      expect(db, isNotNull);
      verify(localDatabaseFactoryFake.create(any)).called(1);

      final db2 = await provider.getLocalDatabase(dbName);
      expect(db2, same(db));
    });
    test("DatabaseProvider.getLocalDatabase() normalizes the db name.", () async {
      final dbName = "someDbName";

      final appDbFake = AppDatabaseMock();

      final localDatabaseFactoryMock = LocalDatabaseFactoryMock();
      when(localDatabaseFactoryMock.create(any)).thenAnswer((_) async => appDbFake);

      final provider = DatabaseProvider(localDatabaseFactoryMock, RemoteDatabaseFactoryMock());

      final db = await provider.getLocalDatabase(dbName);

      expect(db, isNotNull);
      verify(localDatabaseFactoryMock.create(join(dbName.toLowerCase(), ".db"))).called(1);
    });
  });
}

