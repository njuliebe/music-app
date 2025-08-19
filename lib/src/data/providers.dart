import 'package:dio/dio.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import 'package:music_app/src/data/models/playlist.dart';
import 'package:music_app/src/data/repositories/music_repository.dart';
import 'package:music_app/src/data/repositories/playlist_repository.dart';
import 'package:music_app/src/data/sources/api_service.dart';
import 'package:music_app/src/data/services/playlist_import_service.dart'; // Import the new service
import 'package:sqflite/sqflite.dart';

/// A provider that creates an instance of [Dio].
final dioProvider = Provider<Dio>((ref) => Dio());

/// A provider that creates an instance of [ApiService].
final apiServiceProvider = Provider<ApiService>((ref) {
  final dio = ref.watch(dioProvider);
  return ApiService(dio);
});

/// A provider that creates and exposes an instance of [MusicRepository].
///
/// By default, it provides the [ApiMusicRepository] for real network calls.
final musicRepositoryProvider = Provider<MusicRepository>((ref) {
  final apiService = ref.watch(apiServiceProvider);
  return ApiMusicRepository(apiService);
});

/// A provider that creates an instance of [PlaylistImportService].
final playlistImportServiceProvider = Provider<PlaylistImportService>((ref) {
  final dio = ref.watch(dioProvider);
  return PlaylistImportService(dio);
});
