import 'package:flutter/material.dart';
import 'package:logging/logging.dart';

import 'my_app.dart';
import 'src/models/db.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();

  // Initialize logging
  Logger.root.level = Level.ALL;
  Logger.root.onRecord.listen((record) {
    debugPrint('${record.level.name}: ${record.time}: ${record.loggerName}: ${record.message}');
  });

  try {
    // Initialize the SQLite database
    Logger('Database').info('Initializing database...');
    await DatabaseHelper().initialize();
    Logger('Database').info('Database initialized successfully');
  } catch (e) {
    Logger('Database').severe('Failed to initialize database: $e');
    rethrow;
  }

  runApp(const MyApp());
}
