enum PlaylistType { created, collected }

class Playlist {
  final String id; // Changed to String and not nullable
  final String name;
  final String? description;
  final String? coverUrl;
  final String? creator;
  final PlaylistType type;

  Playlist({
    required this.id, // Now required
    required this.name,
    this.description,
    this.coverUrl,
    this.creator,
    required this.type,
  });

  factory Playlist.fromMap(Map<String, dynamic> map) {
    return Playlist(
      id: map['id'] as String, // Cast to String
      name: map['name'],
      description: map['description'],
      coverUrl: map['coverUrl'],
      creator: map['creator'],
      type: PlaylistType.values.firstWhere((e) => e.name == map['type']),
    );
  }

  Map<String, dynamic> toMap() {
    return {
      'id': id,
      'name': name,
      'description': description,
      'coverUrl': coverUrl,
      'creator': creator,
      'type': type.name,
    };
  }
}
