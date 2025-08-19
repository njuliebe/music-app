
  // --- TEMPORARY CODE TO DELETE DATABASE ---
  final dbPath = join(await getDatabasesPath(), 'music_app.db');
  final dbFile = File(dbPath);
  if (await dbFile.exists()) {
    print('Deleting existing database at $dbPath');
    await dbFile.delete();
    print('Database deleted.');
  }
  // --- END OF TEMPORARY CODE ---