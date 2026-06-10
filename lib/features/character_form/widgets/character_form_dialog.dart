import 'package:flutter/material.dart';

class CharacterFormResult {
  const CharacterFormResult({
    required this.nickname,
    required this.jobId,
    required this.jobName,
  });

  final String nickname;
  final String jobId;
  final String jobName;
}

class CharacterFormDialog extends StatefulWidget {
  const CharacterFormDialog({super.key, required this.slotIndex});

  final int slotIndex;

  @override
  State<CharacterFormDialog> createState() => _CharacterFormDialogState();
}

class _CharacterFormDialogState extends State<CharacterFormDialog> {
  final TextEditingController _nicknameController = TextEditingController();

  String? _selectedJobId;

  final List<_JobGroup> _jobGroups = const [
    _JobGroup(
      id: 'warrior_group',
      name: '전사 계열',
      jobs: [
        _JobOption(id: 'knight', name: '기사'),
        _JobOption(id: 'great_sword_warrior', name: '대검전사'),
        _JobOption(id: 'warrior', name: '전사'),
        _JobOption(id: 'swordsman', name: '검술사'),
      ],
    ),
    _JobGroup(
      id: 'archer_group',
      name: '궁수 계열',
      jobs: [
        _JobOption(id: 'archer', name: '궁수'),
        _JobOption(id: 'longbowman', name: '장궁병'),
        _JobOption(id: 'crossbowman', name: '석궁사수'),
      ],
    ),
    _JobGroup(
      id: 'mage_group',
      name: '마법사 계열',
      jobs: [
        _JobOption(id: 'mage', name: '마법사'),
        _JobOption(id: 'ice_mage', name: '빙결술사'),
        _JobOption(id: 'fire_mage', name: '화염술사'),
        _JobOption(id: 'lightning_mage', name: '전격술사'),
      ],
    ),
    _JobGroup(
      id: 'healer_group',
      name: '힐러 계열',
      jobs: [
        _JobOption(id: 'healer', name: '힐러'),
        _JobOption(id: 'priest', name: '사제'),
        _JobOption(id: 'monk', name: '수도사'),
        _JobOption(id: 'dark_mage', name: '암흑술사'),
      ],
    ),
    _JobGroup(
      id: 'rogue_group',
      name: '도적 계열',
      jobs: [
        _JobOption(id: 'rogue', name: '도적'),
        _JobOption(id: 'dual_blade', name: '듀얼블레이드'),
        _JobOption(id: 'fighter', name: '격투가'),
      ],
    ),
    _JobGroup(
      id: 'bard_group',
      name: '음유시인 계열',
      jobs: [
        _JobOption(id: 'bard', name: '음유시인'),
        _JobOption(id: 'musician', name: '악사'),
        _JobOption(id: 'dancer', name: '댄서'),
      ],
    ),
  ];

  List<_JobOption> get _jobOptions {
    return _jobGroups.expand((group) => group.jobs).toList();
  }

  @override
  void dispose() {
    _nicknameController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Dialog(
      backgroundColor: Colors.transparent,
      child: Container(
        width: 420,
        padding: const EdgeInsets.all(28),
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(28),
          border: Border.all(color: const Color(0xFFEDEFF3)),
          boxShadow: [
            BoxShadow(
              color: Colors.black.withValues(alpha: 0.08),
              blurRadius: 32,
              offset: const Offset(0, 16),
            ),
          ],
        ),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              '캐릭터 등록',
              style: Theme.of(context).textTheme.headlineSmall?.copyWith(
                fontWeight: FontWeight.w800,
                color: const Color(0xFF202124),
              ),
            ),
            const SizedBox(height: 6),
            Text(
              '${widget.slotIndex + 1}번 슬롯에 등록할 캐릭터 정보를 입력해주세요.',
              style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                color: const Color(0xFF6B7280),
                fontWeight: FontWeight.w500,
              ),
            ),
            const SizedBox(height: 24),
            TextField(
              controller: _nicknameController,
              decoration: InputDecoration(
                labelText: '닉네임',
                hintText: '캐릭터 닉네임을 입력하세요',
                filled: true,
                fillColor: const Color(0xFFFAFBFF),
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(16),
                ),
              ),
            ),
            const SizedBox(height: 16),
            DropdownButtonFormField<String>(
              initialValue: _selectedJobId,
              decoration: InputDecoration(
                labelText: '직업',
                filled: true,
                fillColor: const Color(0xFFFAFBFF),
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(16),
                ),
              ),
              items: _buildJobDropdownItems(),
              onChanged: (value) {
                setState(() {
                  _selectedJobId = value;
                });
              },
            ),
            const SizedBox(height: 28),
            Row(
              children: [
                Expanded(
                  child: OutlinedButton(
                    onPressed: () {
                      Navigator.of(context).pop();
                    },
                    child: const Text('취소'),
                  ),
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: FilledButton(
                    onPressed: _submit,
                    child: const Text('등록'),
                  ),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }

  List<DropdownMenuItem<String>> _buildJobDropdownItems() {
    return _jobGroups.expand<DropdownMenuItem<String>>((group) {
      return [
        DropdownMenuItem<String>(
          enabled: false,
          value: 'header_${group.id}',
          child: Text(
            group.name,
            style: const TextStyle(
              fontFamily: 'AppFont',
              fontSize: 13,
              fontWeight: FontWeight.w800,
              color: Color(0xFF00A8FF),
            ),
          ),
        ),
        ...group.jobs.map((job) {
          return DropdownMenuItem<String>(
            value: job.id,
            child: Padding(
              padding: const EdgeInsets.only(left: 12),
              child: Text(job.name),
            ),
          );
        }),
      ];
    }).toList();
  }

  void _submit() {
    final nickname = _nicknameController.text.trim();

    if (nickname.isEmpty) {
      _showMessage('닉네임을 입력해주세요.');
      return;
    }

    final selectedJobId = _selectedJobId;
    if (selectedJobId == null) {
      _showMessage('직업을 선택해주세요.');
      return;
    }

    final selectedJob = _jobOptions.firstWhere(
      (job) => job.id == selectedJobId,
    );

    Navigator.of(context).pop(
      CharacterFormResult(
        nickname: nickname,
        jobId: selectedJob.id,
        jobName: selectedJob.name,
      ),
    );
  }

  void _showMessage(String message) {
    ScaffoldMessenger.of(
      context,
    ).showSnackBar(SnackBar(content: Text(message)));
  }
}

class _JobGroup {
  const _JobGroup({required this.id, required this.name, required this.jobs});

  final String id;
  final String name;
  final List<_JobOption> jobs;
}

class _JobOption {
  const _JobOption({required this.id, required this.name});

  final String id;
  final String name;
}
