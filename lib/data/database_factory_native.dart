import 'dart:io';
import 'dart:typed_data';

import 'package:path/path.dart' as p;
import 'package:path_provider/path_provider.dart';
import 'package:sqflite/sqflite.dart';
import 'package:sqflite_common_ffi/sqflite_ffi.dart' as ffi;

Future<Uint8List> readDatabaseExport(String path) => File(path).readAsBytes();
Future<void> deleteDatabaseExport(String path) async {
  final file = File(path);
  if (await file.exists()) await file.delete();
}

Future<Database> openLocalDatabase(OpenDatabaseOptions options) async {
  if (Platform.isWindows || Platform.isLinux) {
    ffi.sqfliteFfiInit();
    final directory = await getApplicationSupportDirectory();
    await directory.create(recursive: true);
    return ffi.databaseFactoryFfi.openDatabase(
      p.join(directory.path, 'umit.db'),
      options: options,
    );
  }
  return databaseFactory.openDatabase(
    p.join(await getDatabasesPath(), 'umit.db'),
    options: options,
  );
}
