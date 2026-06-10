import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import 'package:mobi_helper/core/constants/server_constants.dart';
import 'package:mobi_helper/data/models/character_data.dart';
import 'package:mobi_helper/data/repositories/app_state_provider.dart';
import 'package:mobi_helper/core/theme/app_colors.dart';

class TaskDetailScreen extends ConsumerStatefulWidget {
  const TaskDetailScreen({super.key, required this.characterId});

  final String characterId;

  @override
  ConsumerState<TaskDetailScreen> createState() => _TaskDetailScreenState();
}

class _TaskDetailScreenState extends ConsumerState<TaskDetailScreen> {
  int selectedMainTabIndex = 0;
  int selectedSubMenuIndex = 0;

  final List<String> weeklyMenus = const [
    '레이드',
    '어비스',
    '불길한 소환결계',
    '검은구멍',
    '필드보스',
  ];

  final List<String> dailyMenus = const ['사냥터', '일반던전', '심층던전'];

  @override
  Widget build(BuildContext context) {
    final appStateAsync = ref.watch(appStateProvider);

    return appStateAsync.when(
      loading: () {
        return const _LoadingView();
      },
      error: (error, stackTrace) {
        return const _ErrorView(message: '데이터를 불러오는 중 오류가 발생했습니다.');
      },
      data: (appState) {
        final character = _findCharacter(
          characters: appState.characters,
          characterId: widget.characterId,
        );

        if (character == null) {
          return const _ErrorView(message: '캐릭터 정보를 찾을 수 없습니다.');
        }

        final server = mabinogiMobileServers.firstWhere(
          (server) => server.id == character.serverId,
          orElse: () => const GameServer(id: 'unknown', name: '알 수 없는 서버'),
        );

        final currentMenus = selectedMainTabIndex == 0
            ? weeklyMenus
            : dailyMenus;

        return Scaffold(
          backgroundColor: const Color(0xFFFAFBFF),
          body: Padding(
            padding: const EdgeInsets.fromLTRB(28, 24, 28, 28),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                _Header(character: character, serverName: server.name),
                const SizedBox(height: 24),
                _MainTabs(
                  selectedIndex: selectedMainTabIndex,
                  onChanged: (index) {
                    setState(() {
                      selectedMainTabIndex = index;
                      selectedSubMenuIndex = 0;
                    });
                  },
                ),
                const SizedBox(height: 18),
                _SubMenuBar(
                  menus: currentMenus,
                  selectedIndex: selectedSubMenuIndex,
                  onChanged: (index) {
                    setState(() {
                      selectedSubMenuIndex = index;
                    });
                  },
                ),
                const SizedBox(height: 24),
                Expanded(
                  child: _TaskContent(
                    character: character,
                    selectedMainTabIndex: selectedMainTabIndex,
                    selectedSubMenuIndex: selectedSubMenuIndex,
                    title: currentMenus[selectedSubMenuIndex],
                  ),
                ),
              ],
            ),
          ),
        );
      },
    );
  }

  CharacterData? _findCharacter({
    required List<CharacterData> characters,
    required String characterId,
  }) {
    for (final character in characters) {
      if (character.id == characterId) {
        return character;
      }
    }

    return null;
  }
}

class _Header extends StatelessWidget {
  const _Header({required this.character, required this.serverName});

  final CharacterData character;
  final String serverName;

  @override
  Widget build(BuildContext context) {
    return Row(
      children: [
        Container(
          width: 320,
          padding: const EdgeInsets.all(22),
          decoration: BoxDecoration(
            color: Colors.white,
            borderRadius: BorderRadius.circular(24),
            border: Border.all(color: const Color(0xFFEDEFF3)),
          ),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                character.nickname,
                maxLines: 1,
                overflow: TextOverflow.ellipsis,
                style: Theme.of(context).textTheme.headlineSmall?.copyWith(
                  fontWeight: FontWeight.w800,
                  color: const Color(0xFF202124),
                ),
              ),
              const SizedBox(height: 8),
              Text(
                '$serverName 서버 · ${character.jobName}',
                style: Theme.of(context).textTheme.bodyLarge?.copyWith(
                  color: const Color(0xFF6B7280),
                  fontWeight: FontWeight.w600,
                ),
              ),
            ],
          ),
        ),
        const Spacer(),
        TextButton.icon(
          onPressed: () {
            context.go('/servers/${character.serverId}/characters');
          },
          icon: const Icon(Icons.arrow_back_rounded),
          label: const Text('캐릭터 선택'),
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

class _MainTabs extends StatelessWidget {
  const _MainTabs({required this.selectedIndex, required this.onChanged});

  final int selectedIndex;
  final ValueChanged<int> onChanged;

  @override
  Widget build(BuildContext context) {
    return Row(
      children: [
        _MainTabButton(
          label: '주간숙제',
          selected: selectedIndex == 0,
          onTap: () {
            onChanged(0);
          },
        ),
        const SizedBox(width: 10),
        _MainTabButton(
          label: '일간숙제',
          selected: selectedIndex == 1,
          onTap: () {
            onChanged(1);
          },
        ),
      ],
    );
  }
}

class _MainTabButton extends StatelessWidget {
  const _MainTabButton({
    required this.label,
    required this.selected,
    required this.onTap,
  });

  final String label;
  final bool selected;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    return FilledButton(
      onPressed: onTap,
      style: FilledButton.styleFrom(
        backgroundColor: selected ? const Color(0xFF00A8FF) : Colors.white,
        foregroundColor: selected ? Colors.white : const Color(0xFF374151),
        side: BorderSide(
          color: selected ? const Color(0xFF00A8FF) : const Color(0xFFE5E7EB),
        ),
      ),
      child: Text(label),
    );
  }
}

class _SubMenuBar extends StatelessWidget {
  const _SubMenuBar({
    required this.menus,
    required this.selectedIndex,
    required this.onChanged,
  });

  final List<String> menus;
  final int selectedIndex;
  final ValueChanged<int> onChanged;

  @override
  Widget build(BuildContext context) {
    return Wrap(
      spacing: 10,
      runSpacing: 10,
      children: List.generate(menus.length, (index) {
        final selected = selectedIndex == index;

        return InkWell(
          borderRadius: BorderRadius.circular(999),
          onTap: () {
            onChanged(index);
          },
          child: Container(
            padding: const EdgeInsets.symmetric(horizontal: 18, vertical: 10),
            decoration: BoxDecoration(
              color: selected ? const Color(0xFFEAF7FF) : Colors.white,
              borderRadius: BorderRadius.circular(999),
              border: Border.all(
                color: selected
                    ? const Color(0xFF00A8FF)
                    : const Color(0xFFE5E7EB),
              ),
            ),
            child: Text(
              menus[index],
              style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                color: selected
                    ? const Color(0xFF00A8FF)
                    : const Color(0xFF374151),
                fontWeight: FontWeight.w800,
              ),
            ),
          ),
        );
      }),
    );
  }
}

class _TaskContent extends ConsumerWidget {
  const _TaskContent({
    required this.character,
    required this.selectedMainTabIndex,
    required this.selectedSubMenuIndex,
    required this.title,
  });

  final CharacterData character;
  final int selectedMainTabIndex;
  final int selectedSubMenuIndex;
  final String title;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final isWeekly = selectedMainTabIndex == 0;
    final isRaid = isWeekly && selectedSubMenuIndex == 0;
    final isAbyss = isWeekly && selectedSubMenuIndex == 1;
    final isOminousBarrier = isWeekly && selectedSubMenuIndex == 2;
    final isBlackHole = isWeekly && selectedSubMenuIndex == 3;
    final isFieldBoss = isWeekly && selectedSubMenuIndex == 4;

    final Widget content = isRaid
        ? _RaidTaskContent(character: character)
        : isAbyss
        ? _AbyssTaskContent(character: character)
        : isOminousBarrier
        ? _CounterTaskContent(
            character: character,
            title: '불길한 소환결계',
            description: '이번 주 불길한 소환결계 진행 횟수를 기록하세요.',
            count: character.ominousBarrierCount,
            maxCount: 14,
            onChanged: (nextCount) {
              ref
                  .read(appStateProvider.notifier)
                  .updateOminousBarrierCount(
                    characterId: character.id,
                    count: nextCount,
                  );
            },
          )
        : isBlackHole
        ? _CounterTaskContent(
            character: character,
            title: '검은구멍',
            description: '이번 주 검은구멍 진행 횟수를 기록하세요.',
            count: character.blackHoleCount,
            maxCount: 14,
            onChanged: (nextCount) {
              ref
                  .read(appStateProvider.notifier)
                  .updateBlackHoleCount(
                    characterId: character.id,
                    count: nextCount,
                  );
            },
          )
        : isFieldBoss
        ? _FieldBossTaskContent(character: character)
        : _ComingSoonContent(title: title, isWeekly: isWeekly);

    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(28),
      decoration: BoxDecoration(
        color: AppColors.surface,
        borderRadius: BorderRadius.circular(28),
        border: Border.all(color: AppColors.border),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.025),
            blurRadius: 22,
            offset: const Offset(0, 10),
          ),
        ],
      ),
      child: SingleChildScrollView(child: content),
    );
  }
}

class _RaidTaskContent extends ConsumerWidget {
  const _RaidTaskContent({required this.character});

  final CharacterData character;

  static const List<_RaidTaskItem> raidTasks = [
    _RaidTaskItem(id: 'glass_gibnen', name: '글라스기브넨'),
    _RaidTaskItem(id: 'airel', name: '에이렐'),
    _RaidTaskItem(id: 'white_succubus', name: '화이트서큐버스'),
    _RaidTaskItem(id: 'tabarta', name: '타바르타스'),
  ];

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final completedCount = character.completedRaidTaskIds.length;
    final progress = completedCount / raidTasks.length;

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        _TaskSectionHeader(
          title: '레이드',
          description: '이번 주 레이드 진행상황을 체크하세요.',
          completedCount: completedCount,
          totalCount: raidTasks.length,
          progress: progress,
        ),
        const SizedBox(height: 26),
        Wrap(
          spacing: 14,
          runSpacing: 14,
          children: raidTasks.map((task) {
            final isCompleted = character.completedRaidTaskIds.contains(
              task.id,
            );

            return _TaskCheckCard(
              title: task.name,
              isCompleted: isCompleted,
              onTap: () {
                ref
                    .read(appStateProvider.notifier)
                    .toggleRaidTask(characterId: character.id, taskId: task.id);
              },
            );
          }).toList(),
        ),
      ],
    );
  }
}

class _AbyssTaskContent extends ConsumerWidget {
  const _AbyssTaskContent({required this.character});

  final CharacterData character;

  static const List<_AbyssTaskItem> abyssTasks = [
    _AbyssTaskItem(id: 'underground_cavity', name: '지하 대공동'),
    _AbyssTaskItem(id: 'chaos_temple', name: '혼돈의 신전'),
    _AbyssTaskItem(id: 'revival_altar', name: '부활의 신단'),
    _AbyssTaskItem(id: 'polluted_dump', name: '오염된 폐기장'),
  ];

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final completedCount = character.completedAbyssTaskIds.length;
    final progress = completedCount / abyssTasks.length;

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        _TaskSectionHeader(
          title: '어비스',
          description: '이번 주 어비스 진행상황을 체크하세요.',
          completedCount: completedCount,
          totalCount: abyssTasks.length,
          progress: progress,
        ),
        const SizedBox(height: 26),
        Wrap(
          spacing: 14,
          runSpacing: 14,
          children: abyssTasks.map((task) {
            final isCompleted = character.completedAbyssTaskIds.contains(
              task.id,
            );

            return _TaskCheckCard(
              title: task.name,
              isCompleted: isCompleted,
              onTap: () {
                ref
                    .read(appStateProvider.notifier)
                    .toggleAbyssTask(
                      characterId: character.id,
                      taskId: task.id,
                    );
              },
            );
          }).toList(),
        ),
      ],
    );
  }
}

class _CounterTaskContent extends StatelessWidget {
  const _CounterTaskContent({
    required this.character,
    required this.title,
    required this.description,
    required this.count,
    required this.maxCount,
    required this.onChanged,
  });

  final CharacterData character;
  final String title;
  final String description;
  final int count;
  final int maxCount;
  final ValueChanged<int> onChanged;

  @override
  Widget build(BuildContext context) {
    final progress = count / maxCount;
    final isCompleted = count >= maxCount;

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        _TaskSectionHeader(
          title: title,
          description: description,
          completedCount: count,
          totalCount: maxCount,
          progress: progress,
        ),
        const SizedBox(height: 26),
        Container(
          width: 520,
          padding: const EdgeInsets.all(24),
          decoration: BoxDecoration(
            color: const Color(0xFFF6FAFF),
            borderRadius: BorderRadius.circular(24),
            border: Border.all(
              color: isCompleted ? AppColors.primary : AppColors.border,
              width: isCompleted ? 1.4 : 1,
            ),
          ),
          child: Row(
            children: [
              _CounterButton(
                icon: Icons.remove_rounded,
                enabled: count > 0,
                onTap: () {
                  onChanged(count - 1);
                },
              ),
              const SizedBox(width: 22),
              Expanded(
                child: Column(
                  children: [
                    Text(
                      '$count',
                      style: Theme.of(context).textTheme.displaySmall?.copyWith(
                        fontWeight: FontWeight.w900,
                        letterSpacing: -1,
                        color: isCompleted
                            ? AppColors.primary
                            : AppColors.textPrimary,
                      ),
                    ),
                    const SizedBox(height: 4),
                    Text(
                      '/ $maxCount 완료',
                      style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                        color: AppColors.textSecondary,
                        fontWeight: FontWeight.w800,
                      ),
                    ),
                  ],
                ),
              ),
              const SizedBox(width: 22),
              _CounterButton(
                icon: Icons.add_rounded,
                enabled: count < maxCount,
                onTap: () {
                  onChanged(count + 1);
                },
              ),
              const SizedBox(width: 18),
              OutlinedButton(
                onPressed: count == 0
                    ? null
                    : () {
                        onChanged(0);
                      },
                child: const Text('초기화'),
              ),
            ],
          ),
        ),
      ],
    );
  }
}

class _FieldBossTaskContent extends ConsumerWidget {
  const _FieldBossTaskContent({required this.character});

  final CharacterData character;

  static const int requiredCount = 3;

  static const List<_FieldBossTaskItem> fieldBossTasks = [
    _FieldBossTaskItem(id: 'peri', name: '페리'),
    _FieldBossTaskItem(id: 'crab_bach', name: '크라브바흐'),
    _FieldBossTaskItem(id: 'crama', name: '크라마'),
    _FieldBossTaskItem(id: 'droch_enem', name: '드로흐에넴'),
    _FieldBossTaskItem(id: 'tormog', name: '토르모그'),
  ];

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final completedCount = character.completedFieldBossTaskIds.length;
    final progress = completedCount / requiredCount;
    final isCompleted = completedCount >= requiredCount;

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        _TaskSectionHeader(
          title: '필드보스',
          description: '이번 주 필드보스 5마리 중 3마리를 선택하세요.',
          completedCount: completedCount,
          totalCount: requiredCount,
          progress: progress.clamp(0, 1),
        ),
        const SizedBox(height: 12),
        Text(
          isCompleted ? '필드보스 주간 숙제가 완료되었습니다.' : '최대 3마리까지만 체크할 수 있습니다.',
          style: Theme.of(context).textTheme.bodyMedium?.copyWith(
            color: isCompleted ? AppColors.success : AppColors.textSecondary,
            fontWeight: FontWeight.w800,
          ),
        ),
        const SizedBox(height: 22),
        Wrap(
          spacing: 14,
          runSpacing: 14,
          children: fieldBossTasks.map((task) {
            final isTaskCompleted = character.completedFieldBossTaskIds
                .contains(task.id);

            final canSelectMore = completedCount < requiredCount;
            final isDisabled = !isTaskCompleted && !canSelectMore;

            return _FieldBossCheckCard(
              title: task.name,
              isCompleted: isTaskCompleted,
              isDisabled: isDisabled,
              onTap: () {
                ref
                    .read(appStateProvider.notifier)
                    .toggleFieldBossTask(
                      characterId: character.id,
                      taskId: task.id,
                    );
              },
            );
          }).toList(),
        ),
      ],
    );
  }
}

class _FieldBossCheckCard extends StatelessWidget {
  const _FieldBossCheckCard({
    required this.title,
    required this.isCompleted,
    required this.isDisabled,
    required this.onTap,
  });

  final String title;
  final bool isCompleted;
  final bool isDisabled;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    final backgroundColor = isCompleted
        ? AppColors.primarySoft
        : isDisabled
        ? AppColors.surfaceSoft
        : const Color(0xFFF6FAFF);

    final borderColor = isCompleted
        ? AppColors.primary
        : isDisabled
        ? AppColors.border
        : AppColors.border;

    final textColor = isDisabled
        ? AppColors.textTertiary
        : isCompleted
        ? AppColors.textPrimary
        : AppColors.textSecondary;

    return InkWell(
      borderRadius: BorderRadius.circular(18),
      onTap: isDisabled ? null : onTap,
      child: Container(
        width: 240,
        height: 78,
        padding: const EdgeInsets.symmetric(horizontal: 18, vertical: 14),
        decoration: BoxDecoration(
          color: backgroundColor,
          borderRadius: BorderRadius.circular(18),
          border: Border.all(color: borderColor, width: isCompleted ? 1.4 : 1),
        ),
        child: Row(
          children: [
            Container(
              width: 28,
              height: 28,
              decoration: BoxDecoration(
                color: isCompleted ? AppColors.primary : Colors.transparent,
                shape: BoxShape.circle,
                border: Border.all(
                  color: isCompleted
                      ? AppColors.primary
                      : isDisabled
                      ? AppColors.borderStrong
                      : AppColors.textTertiary,
                  width: 2,
                ),
              ),
              child: isCompleted
                  ? const Icon(
                      Icons.check_rounded,
                      size: 19,
                      color: Colors.white,
                    )
                  : isDisabled
                  ? const Icon(
                      Icons.lock_rounded,
                      size: 16,
                      color: AppColors.textTertiary,
                    )
                  : null,
            ),
            const SizedBox(width: 14),
            Expanded(
              child: Text(
                title,
                maxLines: 1,
                overflow: TextOverflow.ellipsis,
                style: Theme.of(context).textTheme.titleMedium?.copyWith(
                  fontWeight: FontWeight.w800,
                  letterSpacing: -0.2,
                  color: textColor,
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _FieldBossTaskItem {
  const _FieldBossTaskItem({required this.id, required this.name});

  final String id;
  final String name;
}

class _CounterButton extends StatelessWidget {
  const _CounterButton({
    required this.icon,
    required this.enabled,
    required this.onTap,
  });

  final IconData icon;
  final bool enabled;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    return InkWell(
      borderRadius: BorderRadius.circular(18),
      onTap: enabled ? onTap : null,
      child: Container(
        width: 54,
        height: 54,
        decoration: BoxDecoration(
          color: enabled ? AppColors.primarySoft : AppColors.surfaceSoft,
          borderRadius: BorderRadius.circular(18),
          border: Border.all(
            color: enabled ? AppColors.primaryHover : AppColors.border,
          ),
        ),
        child: Icon(
          icon,
          size: 28,
          color: enabled ? AppColors.primary : AppColors.textTertiary,
        ),
      ),
    );
  }
}

class _AbyssTaskItem {
  const _AbyssTaskItem({required this.id, required this.name});

  final String id;
  final String name;
}

class _TaskCheckCard extends StatelessWidget {
  const _TaskCheckCard({
    required this.title,
    required this.isCompleted,
    required this.onTap,
  });

  final String title;
  final bool isCompleted;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    return InkWell(
      borderRadius: BorderRadius.circular(18),
      onTap: onTap,
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 120),
        curve: Curves.easeOut,
        width: 250,
        height: 86,
        padding: const EdgeInsets.symmetric(horizontal: 18, vertical: 16),
        decoration: BoxDecoration(
          color: isCompleted ? AppColors.primarySoft : const Color(0xFFF6FAFF),
          borderRadius: BorderRadius.circular(18),
          border: Border.all(
            color: isCompleted ? AppColors.primary : AppColors.border,
            width: isCompleted ? 1.4 : 1,
          ),
        ),
        child: Row(
          children: [
            AnimatedContainer(
              duration: const Duration(milliseconds: 120),
              width: 28,
              height: 28,
              decoration: BoxDecoration(
                color: isCompleted ? AppColors.primary : Colors.transparent,
                shape: BoxShape.circle,
                border: Border.all(
                  color: isCompleted
                      ? AppColors.primary
                      : AppColors.textTertiary,
                  width: 2,
                ),
              ),
              child: isCompleted
                  ? const Icon(
                      Icons.check_rounded,
                      size: 19,
                      color: Colors.white,
                    )
                  : null,
            ),
            const SizedBox(width: 14),
            Expanded(
              child: Text(
                title,
                maxLines: 1,
                overflow: TextOverflow.ellipsis,
                style: Theme.of(context).textTheme.titleMedium?.copyWith(
                  fontWeight: FontWeight.w800,
                  letterSpacing: -0.2,
                  color: isCompleted
                      ? AppColors.textPrimary
                      : AppColors.textSecondary,
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _TaskSectionHeader extends StatelessWidget {
  const _TaskSectionHeader({
    required this.title,
    required this.description,
    required this.completedCount,
    required this.totalCount,
    required this.progress,
  });

  final String title;
  final String description;
  final int completedCount;
  final int totalCount;
  final double progress;

  @override
  Widget build(BuildContext context) {
    final isCompleted = completedCount >= totalCount;

    return Container(
      padding: const EdgeInsets.all(22),
      decoration: BoxDecoration(
        color: const Color(0xFFF2F8FF),
        borderRadius: BorderRadius.circular(22),
        border: Border.all(color: AppColors.border),
      ),
      child: Row(
        children: [
          Container(
            width: 54,
            height: 54,
            decoration: BoxDecoration(
              color: isCompleted
                  ? AppColors.successSoft
                  : AppColors.primarySoft,
              borderRadius: BorderRadius.circular(18),
            ),
            child: Icon(
              isCompleted ? Icons.check_circle_rounded : Icons.flag_rounded,
              color: isCompleted ? AppColors.success : AppColors.primary,
              size: 30,
            ),
          ),
          const SizedBox(width: 18),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  title,
                  style: Theme.of(context).textTheme.titleLarge?.copyWith(
                    fontWeight: FontWeight.w900,
                    letterSpacing: -0.4,
                    color: AppColors.textPrimary,
                  ),
                ),
                const SizedBox(height: 5),
                Text(
                  description,
                  style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                    fontWeight: FontWeight.w600,
                    color: AppColors.textSecondary,
                  ),
                ),
              ],
            ),
          ),
          const SizedBox(width: 24),
          SizedBox(
            width: 180,
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.end,
              children: [
                Text(
                  '$completedCount / $totalCount 완료',
                  style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                    fontWeight: FontWeight.w900,
                    color: isCompleted
                        ? AppColors.success
                        : AppColors.textPrimary,
                  ),
                ),
                const SizedBox(height: 10),
                ClipRRect(
                  borderRadius: BorderRadius.circular(999),
                  child: LinearProgressIndicator(
                    value: progress,
                    minHeight: 8,
                    backgroundColor: AppColors.border,
                    valueColor: AlwaysStoppedAnimation<Color>(
                      isCompleted ? AppColors.success : AppColors.primary,
                    ),
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

class _ComingSoonContent extends StatelessWidget {
  const _ComingSoonContent({required this.title, required this.isWeekly});

  final String title;
  final bool isWeekly;

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          title,
          style: Theme.of(context).textTheme.headlineSmall?.copyWith(
            fontWeight: FontWeight.w800,
            color: const Color(0xFF202124),
          ),
        ),
        const SizedBox(height: 8),
        Text(
          isWeekly
              ? '주간 숙제 체크 UI를 여기에 구성할 예정입니다.'
              : '일간 숙제 체크 UI를 여기에 구성할 예정입니다.',
          style: Theme.of(context).textTheme.bodyLarge?.copyWith(
            color: const Color(0xFF6B7280),
            fontWeight: FontWeight.w500,
          ),
        ),
      ],
    );
  }
}

class _RaidTaskItem {
  const _RaidTaskItem({required this.id, required this.name});

  final String id;
  final String name;
}

class _LoadingView extends StatelessWidget {
  const _LoadingView();

  @override
  Widget build(BuildContext context) {
    return const Scaffold(
      backgroundColor: Color(0xFFFAFBFF),
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
      backgroundColor: const Color(0xFFFAFBFF),
      body: Center(child: Text(message)),
    );
  }
}
