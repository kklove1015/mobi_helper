import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import 'package:mobi_helper/core/constants/server_constants.dart';
import 'package:mobi_helper/core/theme/app_colors.dart';
import 'package:mobi_helper/data/models/character_data.dart';
import 'package:mobi_helper/data/repositories/app_state_provider.dart';

class DashboardScreen extends ConsumerWidget {
  const DashboardScreen({super.key});

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
        final characters = appState.characters;

        return Scaffold(
          backgroundColor: AppColors.background,
          body: Padding(
            padding: const EdgeInsets.fromLTRB(32, 28, 32, 32),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                _DashboardHeader(characterCount: characters.length),
                const SizedBox(height: 28),
                Expanded(
                  child: characters.isEmpty
                      ? Center(
                          child: Transform.translate(
                            offset: const Offset(0, -28),
                            child: const _EmptyCharacterCard(),
                          ),
                        )
                      : _CharacterDashboardGrid(characters: characters),
                ),
              ],
            ),
          ),
        );
      },
    );
  }
}

class _DashboardHeader extends StatelessWidget {
  const _DashboardHeader({required this.characterCount});

  final int characterCount;

  @override
  Widget build(BuildContext context) {
    return Row(
      children: [
        Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              'Mobi Helper',
              style: Theme.of(context).textTheme.headlineMedium?.copyWith(
                fontWeight: FontWeight.w900,
                letterSpacing: -0.8,
                color: AppColors.textPrimary,
              ),
            ),
            const SizedBox(height: 6),
            Text(
              characterCount == 0
                  ? '마비노기 모바일 숙제체크를 시작해보세요.'
                  : '등록된 캐릭터 $characterCount명의 숙제 진행상황을 확인하세요.',
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
            context.go('/servers');
          },
          icon: const Icon(Icons.dns_rounded),
          label: const Text('서버 선택'),
        ),
      ],
    );
  }
}

class _EmptyCharacterCard extends StatelessWidget {
  const _EmptyCharacterCard();

  @override
  Widget build(BuildContext context) {
    return Container(
      width: 480,
      padding: const EdgeInsets.symmetric(horizontal: 40, vertical: 40),
      decoration: BoxDecoration(
        color: AppColors.surface,
        borderRadius: BorderRadius.circular(30),
        border: Border.all(color: AppColors.border),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.035),
            blurRadius: 28,
            offset: const Offset(0, 16),
          ),
        ],
      ),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          Container(
            width: 64,
            height: 64,
            decoration: BoxDecoration(
              color: AppColors.primarySoft,
              borderRadius: BorderRadius.circular(22),
            ),
            child: const Icon(
              Icons.checklist_rounded,
              size: 36,
              color: AppColors.primary,
            ),
          ),
          const SizedBox(height: 24),
          Text(
            '아직 등록된 캐릭터가 없습니다',
            style: Theme.of(context).textTheme.titleLarge?.copyWith(
              fontWeight: FontWeight.w900,
              letterSpacing: -0.3,
              color: AppColors.textPrimary,
            ),
          ),
          const SizedBox(height: 10),
          Text(
            '서버와 캐릭터를 등록하면\n일간/주간 숙제 진행상황을 한눈에 볼 수 있어요.',
            textAlign: TextAlign.center,
            style: Theme.of(context).textTheme.bodyMedium?.copyWith(
              height: 1.55,
              color: AppColors.textSecondary,
              fontWeight: FontWeight.w600,
            ),
          ),
          const SizedBox(height: 28),
          FilledButton.icon(
            onPressed: () {
              context.go('/servers');
            },
            icon: const Icon(Icons.add_rounded),
            label: const Text('캐릭터 등록 시작하기'),
          ),
        ],
      ),
    );
  }
}

class _CharacterDashboardGrid extends StatelessWidget {
  const _CharacterDashboardGrid({required this.characters});

  final List<CharacterData> characters;

  @override
  Widget build(BuildContext context) {
    return SingleChildScrollView(
      child: Wrap(
        spacing: 18,
        runSpacing: 18,
        children: characters.map((character) {
          final server = mabinogiMobileServers.firstWhere(
            (server) => server.id == character.serverId,
            orElse: () => const GameServer(id: 'unknown', name: '알 수 없는 서버'),
          );

          return _CharacterSummaryCard(
            serverName: server.name,
            character: character,
          );
        }).toList(),
      ),
    );
  }
}

class _CharacterSummaryCard extends StatelessWidget {
  const _CharacterSummaryCard({
    required this.serverName,
    required this.character,
  });

  final String serverName;
  final CharacterData character;

  @override
  Widget build(BuildContext context) {
    final raidCompletedCount = character.completedRaidTaskIds.length;

    return InkWell(
      borderRadius: BorderRadius.circular(26),
      onTap: () {
        context.go('/characters/${character.id}/tasks');
      },
      child: Container(
        width: 280,
        height: 188,
        padding: const EdgeInsets.all(24),
        decoration: BoxDecoration(
          color: AppColors.surface,
          borderRadius: BorderRadius.circular(26),
          border: Border.all(color: AppColors.border),
          boxShadow: [
            BoxShadow(
              color: Colors.black.withValues(alpha: 0.03),
              blurRadius: 18,
              offset: const Offset(0, 10),
            ),
          ],
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            _ServerBadge(serverName: serverName),
            const SizedBox(height: 18),
            Text(
              character.nickname,
              maxLines: 1,
              overflow: TextOverflow.ellipsis,
              style: Theme.of(context).textTheme.titleLarge?.copyWith(
                fontWeight: FontWeight.w900,
                letterSpacing: -0.4,
                color: AppColors.textPrimary,
              ),
            ),
            const SizedBox(height: 6),
            Text(
              character.jobName,
              style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                color: AppColors.textSecondary,
                fontWeight: FontWeight.w700,
              ),
            ),
            const Spacer(),
            _ProgressText(label: '레이드', value: '$raidCompletedCount / 4'),
          ],
        ),
      ),
    );
  }
}

class _ServerBadge extends StatelessWidget {
  const _ServerBadge({required this.serverName});

  final String serverName;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 11, vertical: 6),
      decoration: BoxDecoration(
        color: AppColors.primarySoft,
        borderRadius: BorderRadius.circular(999),
      ),
      child: Text(
        serverName,
        style: Theme.of(context).textTheme.bodySmall?.copyWith(
          color: AppColors.primary,
          fontWeight: FontWeight.w900,
        ),
      ),
    );
  }
}

class _ProgressText extends StatelessWidget {
  const _ProgressText({required this.label, required this.value});

  final String label;
  final String value;

  @override
  Widget build(BuildContext context) {
    return Row(
      children: [
        Text(
          label,
          style: Theme.of(context).textTheme.bodySmall?.copyWith(
            color: AppColors.textTertiary,
            fontWeight: FontWeight.w800,
          ),
        ),
        const Spacer(),
        Text(
          value,
          style: Theme.of(context).textTheme.bodySmall?.copyWith(
            color: AppColors.textSecondary,
            fontWeight: FontWeight.w900,
          ),
        ),
      ],
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
