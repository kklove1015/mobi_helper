import 'character_data.dart';

class AppData {
  const AppData({
    required this.version,
    required this.characters,
    required this.showOnlyServersWithCharacters,
  });

  final int version;
  final List<CharacterData> characters;
  final bool showOnlyServersWithCharacters;

  factory AppData.initial() {
    return const AppData(
      version: 1,
      characters: [],
      showOnlyServersWithCharacters: false,
    );
  }

  factory AppData.fromJson(Map<String, dynamic> json) {
    final charactersJson = json['characters'] as List<dynamic>? ?? [];

    return AppData(
      version: json['version'] as int? ?? 1,
      characters: charactersJson
          .map((item) => CharacterData.fromJson(item as Map<String, dynamic>))
          .toList(),
      showOnlyServersWithCharacters:
          json['showOnlyServersWithCharacters'] as bool? ?? false,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'version': version,
      'characters': characters.map((character) => character.toJson()).toList(),
      'showOnlyServersWithCharacters': showOnlyServersWithCharacters,
    };
  }
}
