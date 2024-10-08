import 'package:cloud_firestore/cloud_firestore.dart';

//ドキュメント情報を取得する

DocumentReference getRoomRef(String roomId) {
  return FirebaseFirestore.instance.collection('rooms').doc(roomId);
}

Future<DocumentSnapshot<Object?>> getRoomSnapshot(String roomId) async {
  DocumentSnapshot roomSnapshot = await getRoomRef(roomId).get();

  if (!roomSnapshot.exists) {
    throw Exception('Room not found');
  }
  return roomSnapshot;
}

Future<Map<String, dynamic>> getRoomSnapshotAsMap(String roomId) async {
  DocumentSnapshot roomSnapshot = await getRoomRef(roomId).get();

  if (!roomSnapshot.exists) {
    throw Exception('Room not found');
  }
  return roomSnapshot.data() as Map<String, dynamic>;
}

//ドキュメント内の情報を処理する

Future<int> getPlayerCount(String roomId) async {
  Map<String, dynamic> roomData = await getRoomSnapshotAsMap(roomId);

  // プレイヤーリストが 'players' フィールドとして存在する前提
  List<dynamic> players = roomData['players'] as List<dynamic>;

  // プレイヤーの数を返す
  return players.length;
}

Future<Map<String, dynamic>?> findPlayerByUUID(
    String roomId, String playerId) async {
  Map<String, dynamic> roomData = await getRoomSnapshotAsMap(roomId);

  // プレイヤーリストを取得
  List<dynamic> players = roomData['players'];

  // UUIDで特定のプレイヤーを見つける
  return players.firstWhere((player) => player['player_id'] == playerId,
      orElse: () => null);
}
