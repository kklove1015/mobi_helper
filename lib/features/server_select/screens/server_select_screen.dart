import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';

import '../../../core/constants/server_constants.dart';
import '../widgets/server_card.dart';

class ServerSelectScreen extends StatefulWidget {
  const ServerSelectScreen({super.key});

  @override
  State<ServerSelectScreen> createState() => _ServerSelectScreenState();
}

class _ServerSelectScreenState extends State<ServerSelectScreen> {
  bool showOnlyServersWithCharacters = false;

  final Map<String, int> temporaryCharacterCounts = const {
    'molly': 0,
    'alissa': 0,
    'maven': 0,
    'lasa': 0,
    'calix': 0,
    'deian': 0,
    'aira': 0,
    'duncan': 0,
  };

  @override
  Widget build(BuildContext context) {
    final visibleServers = mabinogiMobileServers.where((server) {
      if (!showOnlyServersWithCharacters) {
        return true;
      }

      return (temporaryCharacterCounts[server.id] ?? 0) > 0;
    }).toList();

    return Scaffold(
      body: Padding(
        padding: const EdgeInsets.fromLTRB(28, 24, 28, 28),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            _Header(
              showOnlyServersWithCharacters: showOnlyServersWithCharacters,
              onToggleChanged: (value) {
                setState(() {
                  showOnlyServersWithCharacters = value;
                });
              },
            ),
            const SizedBox(height: 28),
            Expanded(
              child: Wrap(
                spacing: 18,
                runSpacing: 18,
                children: visibleServers.map((server) {
                  return ServerCard(
                    serverName: server.name,
                    characterCount: temporaryCharacterCounts[server.id] ?? 0,
                    onTap: () {
                      // 다음 단계에서 캐릭터 선택 화면으로 이동시킬 예정입니다.
                    },
                  );
                }).toList(),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _Header extends StatelessWidget {
  const _Header({
    required this.showOnlyServersWithCharacters,
    required this.onToggleChanged,
  });

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
                fontWeight: FontWeight.w800,
                letterSpacing: -0.4,
                color: const Color(0xFF202124),
              ),
            ),
            const SizedBox(height: 6),
            Text(
              '캐릭터를 등록할 서버를 선택해주세요.',
              style: Theme.of(context).textTheme.bodyLarge?.copyWith(
                color: const Color(0xFF6B7280),
                fontWeight: FontWeight.w500,
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
        const SizedBox(width: 16),
        Row(
          children: [
            Text(
              '캐릭터 보유 서버만 보기',
              style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                fontWeight: FontWeight.w600,
                color: const Color(0xFF374151),
              ),
            ),
            const SizedBox(width: 8),
            Switch(
              value: showOnlyServersWithCharacters,
              onChanged: onToggleChanged,
            ),
          ],
        ),
      ],
    );
  }
}
