import 'dart:typed_data';

import 'package:sqflite_common/sqlite_api.dart';
import 'package:sqflite_common_ffi_web/sqflite_ffi_web.dart';

Future<Uint8List> readDatabaseExport(String path) =>
    databaseFactoryFfiWeb.readDatabaseBytes(path);
Future<void> deleteDatabaseExport(String path) =>
    databaseFactoryFfiWeb.deleteDatabase(path);

Future<Database> openLocalDatabase(OpenDatabaseOptions options) =>
    databaseFactoryFfiWeb.openDatabase('umit.db', options: options);
