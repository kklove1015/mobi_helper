import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import 'package:mobi_helper/core/constants/server_constants.dart';
import 'package:mobi_helper/core/theme/app_colors.dart';
import 'package:mobi_helper/data/models/character_data.dart';
import 'package:mobi_helper/data/repositories/app_state_provider.dart';
import '../widgets/server_card.dart';

class ServerSelectScreen extends ConsumerWidget {
  const ServerSelectScreen({super.key});

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
        final visibleServers = mabinogiMobileServers.where((server) {
          if (!appState.showOnlyServersWithCharacters) {
            return true;
          }

          final characterCount = _getCharacterCountByServer(
            characters: appState.characters,
            serverId: server.id,
          );

          return characterCount > 0;
        }).toList();

        final totalCharacterCount = appState.characters.length;

        return Scaffold(
          backgroundColor: AppColors.background,
          body: Padding(
            padding: const EdgeInsets.fromLTRB(32, 28, 32, 32),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                _Header(
                  totalCharacterCount: totalCharacterCount,
                  showOnlyServersWithCharacters:
                      appState.showOnlyServersWithCharacters,
                  onToggleChanged: (value) {
                    ref
                        .read(appStateProvider.notifier)
                        .setShowOnlyServersWithCharacters(value);
                  },
                ),
                const SizedBox(height: 28),
                Expanded(
                  child: visibleServers.isEmpty
                      ? const _EmptyFilteredServerView()
                      : SingleChildScrollView(
                          child: Wrap(
                            spacing: 18,
                            runSpacing: 18,
                            children: visibleServers.map((server) {
                              final characterCount = _getCharacterCountByServer(
                                characters: appState.characters,
                                serverId: server.id,
                              );

                              return ServerCard(
                                serverName: server.name,
                                characterCount: characterCount,
                                onTap: () {
                                  context.go(
                                    '/servers/${server.id}/characters',
                                  );
                                },
                              );
                            }).toList(),
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

  int _getCharacterCountByServer({
    required List<CharacterData> characters,
    required String serverId,
  }) {
    return characters
        .where((character) => character.serverId == serverId)
        .length;
  }
}

class _Header extends StatelessWidget {
  const _Header({
    required this.totalCharacterCount,
    required this.showOnlyServersWithCharacters,
    required this.onToggleChanged,
  });

  final int totalCharacterCount;
  final bool showOnlyServersWithCharacters;
  final ValueChanged<bool> onToggleChanged;

  @override
  Widget build(BuildContext context) {
    return Row(
      children: [
        Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              '서버 선택',
              style: Theme.of(context).textTheme.headlineMedium?.copyWith(
                fontWeight: FontWeight.w900,
                letterSpacing: -0.8,
                color: AppColors.textPrimary,
              ),
            ),
            const SizedBox(height: 6),
            Text(
              totalCharacterCount == 0
                  ? '캐릭터를 등록할 서버를 선택해주세요.'
                  : '총 $totalCharacterCount명의 캐릭터가 등록되어 있어요.',
              style: Theme.of(context).textTheme.bodyLarge?.copyWith(
                color: AppColors.textSecondary,
                fontWeight: FontWeight.w600,
              ),
            ),
          ],
        ),
        const Spacer(),
        TextButton.icon(
          onPressed: () {
            context.go('/');
          },
          icon: const Icon(Icons.arrow_back_rounded),
          label: const Text('대시보드'),
        ),
        const SizedBox(width: 18),
        _ServerFilterToggle(
          value: showOnlyServersWithCharacters,
          onChanged: onToggleChanged,
        ),
      ],
    );
  }
}

class _ServerFilterToggle extends StatelessWidget {
  const _ServerFilterToggle({required this.value, required this.onChanged});

  final bool value;
  final ValueChanged<bool> onChanged;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.only(left: 16, right: 8, top: 8, bottom: 8),
      decoration: BoxDecoration(
        color: AppColors.surface,
        borderRadius: BorderRadius.circular(999),
        border: Border.all(color: AppColors.border),
      ),
      child: Row(
        children: [
          Text(
            '캐릭터 보유 서버만',
            style: Theme.of(context).textTheme.bodyMedium?.copyWith(
              fontWeight: FontWeight.w800,
              color: AppColors.textSecondary,
            ),
          ),
          const SizedBox(width: 8),
          Switch(value: value, onChanged: onChanged),
        ],
      ),
    );
  }
}

class _EmptyFilteredServerView extends StatelessWidget {
  const _EmptyFilteredServerView();

  @override
  Widget build(BuildContext context) {
    return Center(
      child: Transform.translate(
        offset: const Offset(0, -28),
        child: Container(
          width: 420,
          padding: const EdgeInsets.all(34),
          decoration: BoxDecoration(
            color: AppColors.surface,
            borderRadius: BorderRadius.circular(28),
            border: Border.all(color: AppColors.border),
          ),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Container(
                width: 58,
                height: 58,
                decoration: BoxDecoration(
                  color: AppColors.surfaceSoft,
                  borderRadius: BorderRadius.circular(20),
                ),
                child: const Icon(
                  Icons.search_off_rounded,
                  color: AppColors.textTertiary,
                  size: 34,
                ),
              ),
              const SizedBox(height: 20),
              Text(
                '표시할 서버가 없습니다',
                style: Theme.of(context).textTheme.titleLarge?.copyWith(
                  fontWeight: FontWeight.w900,
                  color: AppColors.textPrimary,
                ),
              ),
              const SizedBox(height: 8),
              Text(
                '캐릭터가 등록된 서버만 보기 옵션이 켜져 있어요.',
                textAlign: TextAlign.center,
                style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                  color: AppColors.textSecondary,
                  fontWeight: FontWeight.w600,
                ),
              ),
            ],
          ),
        ),
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
