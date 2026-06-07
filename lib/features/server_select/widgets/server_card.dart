import 'package:flutter/material.dart';

class ServerCard extends StatelessWidget {
  const ServerCard({
    super.key,
    required this.serverName,
    required this.characterCount,
    required this.onTap,
  });

  final String serverName;
  final int characterCount;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    final hasCharacter = characterCount > 0;

    return InkWell(
      borderRadius: BorderRadius.circular(22),
      onTap: onTap,
      child: Container(
        width: 220,
        height: 136,
        padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 22),
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(22),
          border: Border.all(color: const Color(0xFFEDEFF3)),
          boxShadow: [
            BoxShadow(
              color: Colors.black.withValues(alpha: 0.04),
              blurRadius: 18,
              offset: const Offset(0, 8),
            ),
          ],
        ),
        child: Align(
          alignment: Alignment.centerLeft,
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                serverName,
                style: Theme.of(context).textTheme.titleLarge?.copyWith(
                  fontWeight: FontWeight.w800,
                  color: const Color(0xFF202124),
                ),
              ),
              const SizedBox(height: 10),
              Text(
                hasCharacter ? '캐릭터 $characterCount명' : '등록된 캐릭터 없음',
                style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                  color: hasCharacter
                      ? Theme.of(context).colorScheme.primary
                      : const Color(0xFF6B7280),
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
