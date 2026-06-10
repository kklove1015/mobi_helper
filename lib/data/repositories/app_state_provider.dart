import 'package:flutter_riverpod/flutter_riverpod.dart';

import 'package:mobi_helper/core/storage/app_storage.dart';
import 'package:mobi_helper/data/models/app_data.dart';
import '../models/character_data.dart';

final appStorageProvider = Provider<AppStorage>((ref) {
  return const AppStorage();
});

final appStateProvider = AsyncNotifierProvider<AppStateNotifier, AppState>(
  AppStateNotifier.new,
);

class AppState {
  const AppState({
    required this.characters,
    required this.showOnlyServersWithCharacters,
  });

  final List<CharacterData> characters;
  final bool showOnlyServersWithCharacters;

  factory AppState.initial() {
    return const AppState(characters: [], showOnlyServersWithCharacters: false);
  }

  factory AppState.fromAppData(AppData data) {
    return AppState(
      characters: data.characters,
      showOnlyServersWithCharacters: data.showOnlyServersWithCharacters,
    );
  }

  AppData toAppData() {
    return AppData(
      version: 1,
      characters: characters,
      showOnlyServersWithCharacters: showOnlyServersWithCharacters,
    );
  }

  AppState copyWith({
    List<CharacterData>? characters,
    bool? showOnlyServersWithCharacters,
  }) {
    return AppState(
      characters: characters ?? this.characters,
      showOnlyServersWithCharacters:
          showOnlyServersWithCharacters ?? this.showOnlyServersWithCharacters,
    );
  }
}

class AppStateNotifier extends AsyncNotifier<AppState> {
  @override
  Future<AppState> build() async {
    final storage = ref.read(appStorageProvider);
    final data = await storage.load();

    return AppState.fromAppData(data);
  }

  Future<void> setShowOnlyServersWithCharacters(bool value) async {
    final currentState = state.value ?? AppState.initial();

    final nextState = currentState.copyWith(
      showOnlyServersWithCharacters: value,
    );

    state = AsyncData(nextState);

    await _save(nextState);
  }

  Future<void> addCharacter({
    required String serverId,
    required int slotIndex,
    required String nickname,
    required String jobId,
    required String jobName,
  }) async {
    final currentState = state.value ?? AppState.initial();

    final newCharacter = CharacterData(
      id: DateTime.now().microsecondsSinceEpoch.toString(),
      serverId: serverId,
      slotIndex: slotIndex,
      nickname: nickname,
      jobId: jobId,
      jobName: jobName,
      completedRaidTaskIds: [],
      completedAbyssTaskIds: [],
      ominousBarrierCount: 0,
      blackHoleCount: 0,
      completedFieldBossTaskIds: [],
    );

    final filteredCharacters = currentState.characters.where((character) {
      final isSameSlot =
          character.serverId == serverId && character.slotIndex == slotIndex;

      return !isSameSlot;
    }).toList();

    final nextState = currentState.copyWith(
      characters: [...filteredCharacters, newCharacter],
    );

    state = AsyncData(nextState);

    await _save(nextState);
  }

  Future<void> _save(AppState appState) async {
    final storage = ref.read(appStorageProvider);
    await storage.save(appState.toAppData());
  }

  Future<void> toggleRaidTask({
    required String characterId,
    required String taskId,
  }) async {
    final currentState = state.value ?? AppState.initial();

    final nextCharacters = currentState.characters.map((character) {
      if (character.id != characterId) {
        return character;
      }

      final completedIds = [...character.completedRaidTaskIds];

      if (completedIds.contains(taskId)) {
        completedIds.remove(taskId);
      } else {
        completedIds.add(taskId);
      }

      return character.copyWith(completedRaidTaskIds: completedIds);
    }).toList();

    final nextState = currentState.copyWith(characters: nextCharacters);

    state = AsyncData(nextState);

    await _save(nextState);
  }

  Future<void> toggleAbyssTask({
    required String characterId,
    required String taskId,
  }) async {
    final currentState = state.value ?? AppState.initial();

    final nextCharacters = currentState.characters.map((character) {
      if (character.id != characterId) {
        return character;
      }

      final completedIds = [...character.completedAbyssTaskIds];

      if (completedIds.contains(taskId)) {
        completedIds.remove(taskId);
      } else {
        completedIds.add(taskId);
      }

      return character.copyWith(completedAbyssTaskIds: completedIds);
    }).toList();

    final nextState = currentState.copyWith(characters: nextCharacters);

    state = AsyncData(nextState);

    await _save(nextState);
  }

  Future<void> toggleFieldBossTask({
    required String characterId,
    required String taskId,
  }) async {
    final currentState = state.value ?? AppState.initial();

    final nextCharacters = currentState.characters.map((character) {
      if (character.id != characterId) {
        return character;
      }

      final completedIds = [...character.completedFieldBossTaskIds];

      if (completedIds.contains(taskId)) {
        completedIds.remove(taskId);
      } else {
        if (completedIds.length >= 3) {
          return character;
        }

        completedIds.add(taskId);
      }

      return character.copyWith(completedFieldBossTaskIds: completedIds);
    }).toList();

    final nextState = currentState.copyWith(characters: nextCharacters);

    state = AsyncData(nextState);

    await _save(nextState);
  }

  Future<void> updateOminousBarrierCount({
    required String characterId,
    required int count,
  }) async {
    final safeCount = count.clamp(0, 14);
    await _updateCounter(
      characterId: characterId,
      ominousBarrierCount: safeCount,
    );
  }

  Future<void> updateBlackHoleCount({
    required String characterId,
    required int count,
  }) async {
    final safeCount = count.clamp(0, 14);
    await _updateCounter(characterId: characterId, blackHoleCount: safeCount);
  }

  Future<void> _updateCounter({
    required String characterId,
    int? ominousBarrierCount,
    int? blackHoleCount,
  }) async {
    final currentState = state.value ?? AppState.initial();

    final nextCharacters = currentState.characters.map((character) {
      if (character.id != characterId) {
        return character;
      }

      return character.copyWith(
        ominousBarrierCount:
            ominousBarrierCount ?? character.ominousBarrierCount,
        blackHoleCount: blackHoleCount ?? character.blackHoleCount,
      );
    }).toList();

    final nextState = currentState.copyWith(characters: nextCharacters);

    state = AsyncData(nextState);

    await _save(nextState);
  }
}
