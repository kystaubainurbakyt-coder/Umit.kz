import 'dart:io';
import 'dart:typed_data';

import 'package:path/path.dart' as p;
import 'package:path_provider/path_provider.dart';

Future<String> saveDatabaseFile(Uint8List bytes) async {
  final directory = await getApplicationDocumentsDirectory();
  final file = File(p.join(directory.path, 'umit.db'));
  await file.writeAsBytes(bytes, flush: true);
  return 'Файл сақталды: ${file.path}';
}
