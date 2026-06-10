import 'package:flutter/material.dart';

import 'package:mobi_helper/core/theme/app_colors.dart';

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
      borderRadius: BorderRadius.circular(24),
      onTap: onTap,
      child: Container(
        width: 230,
        height: 142,
        padding: const EdgeInsets.all(24),
        decoration: BoxDecoration(
          color: AppColors.surface,
          borderRadius: BorderRadius.circular(24),
          border: Border.all(
            color: hasCharacter ? AppColors.primaryHover : AppColors.border,
            width: hasCharacter ? 1.4 : 1,
          ),
          boxShadow: [
            BoxShadow(
              color: Colors.black.withValues(alpha: 0.025),
              blurRadius: 18,
              offset: const Offset(0, 10),
            ),
          ],
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            _ServerStatusBadge(
              hasCharacter: hasCharacter,
              characterCount: characterCount,
            ),
            const Spacer(),
            Text(
              serverName,
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
              hasCharacter ? '캐릭터가 등록된 서버' : '등록된 캐릭터 없음',
              style: Theme.of(context).textTheme.bodySmall?.copyWith(
                color: AppColors.textSecondary,
                fontWeight: FontWeight.w700,
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _ServerStatusBadge extends StatelessWidget {
  const _ServerStatusBadge({
    required this.hasCharacter,
    required this.characterCount,
  });

  final bool hasCharacter;
  final int characterCount;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
      decoration: BoxDecoration(
        color: hasCharacter ? AppColors.primarySoft : AppColors.surfaceSoft,
        borderRadius: BorderRadius.circular(999),
      ),
      child: Text(
        hasCharacter ? '$characterCount명 보유' : '빈 서버',
        style: Theme.of(context).textTheme.bodySmall?.copyWith(
          color: hasCharacter ? AppColors.primary : AppColors.textTertiary,
          fontWeight: FontWeight.w900,
        ),
      ),
    );
  }
}
