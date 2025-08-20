enum PlaylistType { created, collected }

class Playlist {
  final int?
  pkId; // Nullable because it's not present on creation before DB insert
  final String sourceId; // Renamed from 'id'
  final String name;
  final String? description;
  final String? coverUrl;
  final String? creator;
  final PlaylistType type;
  final DateTime importTime; // Using DateTime for type safety

  Playlist({
    this.pkId,
    required this.sourceId,
    required this.name,
    this.description,
    this.coverUrl,
    this.creator,
    required this.type,
    required this.importTime,
  });

  factory Playlist.fromMap(Map<String, dynamic> map) {
    return Playlist(
      pkId: map['pk_id'] as int?,
      sourceId: map['source_id'] as String,
      name: map['name'] as String,
      description: map['description'] as String?,
      coverUrl: map['coverUrl'] as String?,
      creator: map['creator'] as String?,
      type: PlaylistType.values.firstWhere((e) => e.name == map['type']),
      importTime: DateTime.fromMillisecondsSinceEpoch(
        map['import_time'] as int,
      ),
    );
  }

  Map<String, dynamic> toMap() {
    return {
      'pk_id': pkId,
      'source_id': sourceId,
      'name': name,
      'description': description,
      'coverUrl': coverUrl,
      'creator': creator,
      'type': type.name,
      'import_time': importTime.millisecondsSinceEpoch,
    };
  }
}
