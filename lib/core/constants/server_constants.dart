class GameServer {
  const GameServer({required this.id, required this.name});

  final String id;
  final String name;
}

const List<GameServer> mabinogiMobileServers = [
  GameServer(id: 'molly', name: '몰리'),
  GameServer(id: 'alissa', name: '알리사'),
  GameServer(id: 'maven', name: '메이븐'),
  GameServer(id: 'lasa', name: '라사'),
  GameServer(id: 'calix', name: '칼릭스'),
  GameServer(id: 'deian', name: '데이안'),
  GameServer(id: 'aira', name: '아이라'),
  GameServer(id: 'duncan', name: '던컨'),
];
