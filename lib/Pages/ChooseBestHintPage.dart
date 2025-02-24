import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:bias_profile/commons/ResponsiveLayout.dart';
import 'package:bias_profile/util/util.dart';
import 'package:bias_profile/util/RoomStatusMonitor.dart';
import 'package:bias_profile/components/ChooseBestHintForm.dart';
import 'dart:math';

class ChooseBestHintPage extends StatefulWidget {
  final String roomId;
  final String playerId;

  const ChooseBestHintPage({
    super.key,
    required this.roomId,
    required this.playerId,
  });

  @override
  State<ChooseBestHintPage> createState() => _ChooseBestHintPageState();
}

class _ChooseBestHintPageState extends State<ChooseBestHintPage>
    with RoomStatusMonitor {
  DocumentSnapshot? _documentSnapshot;
  List<Map<String, dynamic>> _profiles = [];
  List<Map<String, dynamic>> _randomizedCardsList = [];
  String? _parentPlayerId;

  @override
  void initState() {
    super.initState();
    _loadRoomSnapshot();
    startRoomStatusMonitoring(
      widget.roomId,
      widget.playerId,
      skipProfileNavigation: true,
    );
  }

  // ターン数を考慮したシャッフル関数
  List<Map<String, dynamic>> _seededShuffle(
      List<Map<String, dynamic>> list, int turnCount) {
    // roomIdとターン数を組み合わせてシード値を生成
    final seed = widget.roomId.hashCode ^ turnCount;
    final random = Random(seed);

    // 元のindexを追加したリストを作成
    final indexedList = list
        .asMap()
        .entries
        .map((entry) => {...entry.value, 'original_index': entry.key})
        .toList();

    // シャッフル
    for (var i = indexedList.length - 1; i > 0; i--) {
      final j = random.nextInt(i + 1);
      final temp = indexedList[i];
      indexedList[i] = indexedList[j];
      indexedList[j] = temp;
    }
    return indexedList;
  }

  Future<void> _loadRoomSnapshot() async {
    _documentSnapshot = await getRoomSnapshot(widget.roomId);
    if (_documentSnapshot != null) {
      final roomData = _documentSnapshot!.data() as Map<String, dynamic>;
      final currentTurn = roomData['current_turn'] as Map<String, dynamic>;
      final players = roomData['players'] as List<dynamic>;
      final turnCount = currentTurn['turn_count'] as int;

      // プロフィールリストを取得
      final profiles = List<Map<String, dynamic>>.from(currentTurn['profiles']);

      // 各プロフィールにプレイヤーのニックネームを追加
      _profiles = profiles.map((profile) {
        final playerData = players.firstWhere(
          (player) => player['player_id'] == profile['assigned_player_id'],
          orElse: () => {'nickname': '不明なプレイヤー'},
        );

        return {
          ...profile,
          'player_nickname': playerData['nickname'] ?? '不明なプレイヤー',
        };
      }).toList();

      // 親プレイヤーIDを取得
      _parentPlayerId = currentTurn['parent_player_id'] as String;

      // カードリストを取得してシャッフル
      _randomizedCardsList = _seededShuffle(
          List<Map<String, dynamic>>.from(currentTurn['character_cards']),
          turnCount);

      setState(() {});
    }
  }

  @override
  Widget build(BuildContext context) {
    if (_documentSnapshot == null) {
      return const Scaffold(
        body: Center(child: CircularProgressIndicator()),
      );
    }

    return Scaffold(
      appBar: AppBar(
        title: const Text('ベストヒントを選ぼう'),
        automaticallyImplyLeading: false,
      ),
      body: ResponsiveLayout(
        breakPoints: [
          BreakPoint(minWidth: 1024, containerWidth: 500),
          BreakPoint(minWidth: 600, containerWidth: 500),
          BreakPoint(minWidth: 0, containerWidth: 300),
        ],
        builder: (context, containerWidth) {
          return ChooseBestHintForm(
            containerWidth: containerWidth,
            roomId: widget.roomId,
            playerId: widget.playerId,
            roomData: _documentSnapshot!,
            randomizedCardsList: _randomizedCardsList,
            profiles: _profiles,
            parentPlayerId: _parentPlayerId!,
          );
        },
      ),
    );
  }
}
