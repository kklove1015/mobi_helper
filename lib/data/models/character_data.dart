class CharacterData {
  const CharacterData({
    required this.id,
    required this.serverId,
    required this.slotIndex,
    required this.nickname,
    required this.jobId,
    required this.jobName,
    required this.completedRaidTaskIds,
    required this.completedAbyssTaskIds,
    required this.ominousBarrierCount,
    required this.blackHoleCount,
    required this.completedFieldBossTaskIds,
  });

  final String id;
  final String serverId;
  final int slotIndex;
  final String nickname;
  final String jobId;
  final String jobName;
  final List<String> completedRaidTaskIds;
  final List<String> completedAbyssTaskIds;
  final int ominousBarrierCount;
  final int blackHoleCount;
  final List<String> completedFieldBossTaskIds;

  factory CharacterData.fromJson(Map<String, dynamic> json) {
    final completedRaidTaskIdsJson =
        json['completedRaidTaskIds'] as List<dynamic>? ?? [];

    final completedAbyssTaskIdsJson =
        json['completedAbyssTaskIds'] as List<dynamic>? ?? [];

    final completedFieldBossTaskIdsJson =
        json['completedFieldBossTaskIds'] as List<dynamic>? ?? [];

    return CharacterData(
      id: json['id'] as String,
      serverId: json['serverId'] as String,
      slotIndex: json['slotIndex'] as int,
      nickname: json['nickname'] as String,
      jobId: json['jobId'] as String,
      jobName: json['jobName'] as String,
      completedRaidTaskIds: completedRaidTaskIdsJson
          .map((item) => item as String)
          .toList(),
      completedAbyssTaskIds: completedAbyssTaskIdsJson
          .map((item) => item as String)
          .toList(),
      ominousBarrierCount: json['ominousBarrierCount'] as int? ?? 0,
      blackHoleCount: json['blackHoleCount'] as int? ?? 0,
      completedFieldBossTaskIds: completedFieldBossTaskIdsJson
          .map((item) => item as String)
          .toList(),
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'serverId': serverId,
      'slotIndex': slotIndex,
      'nickname': nickname,
      'jobId': jobId,
      'jobName': jobName,
      'completedRaidTaskIds': completedRaidTaskIds,
      'completedAbyssTaskIds': completedAbyssTaskIds,
      'ominousBarrierCount': ominousBarrierCount,
      'blackHoleCount': blackHoleCount,
      'completedFieldBossTaskIds': completedFieldBossTaskIds,
    };
  }

  CharacterData copyWith({
    String? id,
    String? serverId,
    int? slotIndex,
    String? nickname,
    String? jobId,
    String? jobName,
    List<String>? completedRaidTaskIds,
    List<String>? completedAbyssTaskIds,
    int? ominousBarrierCount,
    int? blackHoleCount,
    List<String>? completedFieldBossTaskIds,
  }) {
    return CharacterData(
      id: id ?? this.id,
      serverId: serverId ?? this.serverId,
      slotIndex: slotIndex ?? this.slotIndex,
      nickname: nickname ?? this.nickname,
      jobId: jobId ?? this.jobId,
      jobName: jobName ?? this.jobName,
      completedRaidTaskIds: completedRaidTaskIds ?? this.completedRaidTaskIds,
      completedAbyssTaskIds:
          completedAbyssTaskIds ?? this.completedAbyssTaskIds,
      ominousBarrierCount: ominousBarrierCount ?? this.ominousBarrierCount,
      blackHoleCount: blackHoleCount ?? this.blackHoleCount,
      completedFieldBossTaskIds:
          completedFieldBossTaskIds ?? this.completedFieldBossTaskIds,
    );
  }
}
