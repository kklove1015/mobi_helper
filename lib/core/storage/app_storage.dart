import 'dart:convert';
import 'dart:io';

import 'package:path_provider/path_provider.dart';

import 'package:mobi_helper/data/models/app_data.dart';

class AppStorage {
  const AppStorage();

  static const String _fileName = 'data.json';

  Future<File> _getDataFile() async {
    final directory = await getApplicationSupportDirectory();

    if (!await directory.exists()) {
      await directory.create(recursive: true);
    }

    return File('${directory.path}/$_fileName');
  }

  Future<AppData> load() async {
    try {
      final file = await _getDataFile();

      if (!await file.exists()) {
        return AppData.initial();
      }

      final jsonText = await file.readAsString();

      if (jsonText.trim().isEmpty) {
        return AppData.initial();
      }

      final jsonMap = jsonDecode(jsonText) as Map<String, dynamic>;

      return AppData.fromJson(jsonMap);
    } catch (_) {
      return AppData.initial();
    }
  }

  Future<void> save(AppData data) async {
    final file = await _getDataFile();

    final jsonText = const JsonEncoder.withIndent('  ').convert(data.toJson());

    await file.writeAsString(jsonText);
  }
}
