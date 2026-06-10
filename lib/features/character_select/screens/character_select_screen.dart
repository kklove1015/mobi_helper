import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import 'package:mobi_helper/core/constants/server_constants.dart';
import 'package:mobi_helper/core/theme/app_colors.dart';
import 'package:mobi_helper/data/models/character_data.dart';
import 'package:mobi_helper/data/repositories/app_state_provider.dart';
import 'package:mobi_helper/features/character_form/widgets/character_form_dialog.dart';
import '../widgets/character_slot_card.dart';

class CharacterSelectScreen extends ConsumerWidget {
  const CharacterSelectScreen({super.key, required this.serverId});

  final String serverId;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final appStateAsync = ref.watch(appStateProvider);

    return appStateAsync.when(
      loading: () {
        return const _LoadingView();
      },
      error: (error, stackTrace) {
        return const _ErrorView(message: '데이터를 불러오는 중 오류가 발생했습니다.');
      },
      data: (appState) {
        final server = mabinogiMobileServers.firstWhere(
          (server) => server.id == serverId,
          orElse: () => const GameServer(id: 'unknown', name: '알 수 없는 서버'),
        );

        final charactersInServer = appState.characters
            .where((character) => character.serverId == serverId)
            .toList();

        return Scaffold(
          backgroundColor: AppColors.background,
          body: Padding(
            padding: const EdgeInsets.fromLTRB(32, 28, 32, 32),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                _Header(
                  serverName: server.name,
                  characterCount: charactersInServer.length,
                ),
                const SizedBox(height: 28),
                Expanded(
                  child: SingleChildScrollView(
                    child: Wrap(
                      spacing: 18,
                      runSpacing: 18,
                      children: List.generate(6, (index) {
                        final character = _getCharacterBySlot(
                          characters: appState.characters,
                          serverId: serverId,
                          slotIndex: index,
                        );

                        return CharacterSlotCard(
                          slotIndex: index,
                          nickname: character?.nickname,
                          jobName: character?.jobName,
                          onTap: () async {
                            if (character == null) {
                              await _openCharacterForm(
                                context: context,
                                ref: ref,
                                slotIndex: index,
                              );
                              return;
                            }

                            context.go('/characters/${character.id}/tasks');
                          },
                        );
                      }),
                    ),
                  ),
                ),
              ],
            ),
          ),
        );
      },
    );
  }

  CharacterData? _getCharacterBySlot({
    required List<CharacterData> characters,
    required String serverId,
    required int slotIndex,
  }) {
    for (final character in characters) {
      if (character.serverId == serverId && character.slotIndex == slotIndex) {
        return character;
      }
    }

    return null;
  }

  Future<void> _openCharacterForm({
    required BuildContext context,
    required WidgetRef ref,
    required int slotIndex,
  }) async {
    final result = await showDialog<CharacterFormResult>(
      context: context,
      builder: (context) {
        return CharacterFormDialog(slotIndex: slotIndex);
      },
    );

    if (result == null) {
      return;
    }

    await ref
        .read(appStateProvider.notifier)
        .addCharacter(
          serverId: serverId,
          slotIndex: slotIndex,
          nickname: result.nickname,
          jobId: result.jobId,
          jobName: result.jobName,
        );

    if (!context.mounted) {
      return;
    }

    ScaffoldMessenger.of(
      context,
    ).showSnackBar(SnackBar(content: Text('${result.nickname} 캐릭터가 등록되었습니다.')));
  }
}

class _Header extends StatelessWidget {
  const _Header({required this.serverName, required this.characterCount});

  final String serverName;
  final int characterCount;

  @override
  Widget build(BuildContext context) {
    return Row(
      children: [
        _ServerSummaryCard(
          serverName: serverName,
          characterCount: characterCount,
        ),
        const Spacer(),
        TextButton.icon(
          onPressed: () {
            context.go('/servers');
          },
          icon: const Icon(Icons.arrow_back_rounded),
          label: const Text('서버 선택'),
        ),
        const SizedBox(width: 8),
        TextButton.icon(
          onPressed: () {
            context.go('/');
          },
          icon: const Icon(Icons.home_rounded),
          label: const Text('대시보드'),
        ),
      ],
    );
  }
}

class _ServerSummaryCard extends StatelessWidget {
  const _ServerSummaryCard({
    required this.serverName,
    required this.characterCount,
  });

  final String serverName;
  final int characterCount;

  @override
  Widget build(BuildContext context) {
    return Container(
      width: 360,
      padding: const EdgeInsets.all(24),
      decoration: BoxDecoration(
        color: AppColors.surface,
        borderRadius: BorderRadius.circular(28),
        border: Border.all(color: AppColors.border),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.025),
            blurRadius: 18,
            offset: const Offset(0, 10),
          ),
        ],
      ),
      child: Row(
        children: [
          Container(
            width: 52,
            height: 52,
            decoration: BoxDecoration(
              color: AppColors.primarySoft,
              borderRadius: BorderRadius.circular(18),
            ),
            child: const Icon(
              Icons.storage_rounded,
              color: AppColors.primary,
              size: 30,
            ),
          ),
          const SizedBox(width: 18),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  '$serverName 서버',
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                  style: Theme.of(context).textTheme.headlineSmall?.copyWith(
                    fontWeight: FontWeight.w900,
                    letterSpacing: -0.7,
                    color: AppColors.textPrimary,
                  ),
                ),
                const SizedBox(height: 6),
                Text(
                  characterCount == 0
                      ? '등록된 캐릭터가 없습니다.'
                      : '$characterCount / 6 캐릭터 등록됨',
                  style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                    color: AppColors.textSecondary,
                    fontWeight: FontWeight.w700,
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}

class _LoadingView extends StatelessWidget {
  const _LoadingView();

  @override
  Widget build(BuildContext context) {
    return const Scaffold(
      backgroundColor: AppColors.background,
      body: Center(child: CircularProgressIndicator()),
    );
  }
}

class _ErrorView extends StatelessWidget {
  const _ErrorView({required this.message});

  final String message;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.background,
      body: Center(child: Text(message)),
    );
  }
}
