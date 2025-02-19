import 'package:bias_profile/components/ProfileAnswerForm.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:bias_profile/components/components.dart';
import 'package:bias_profile/commons/ResponsiveLayout.dart';
import 'package:bias_profile/util/util.dart';
import 'dart:math';

class ProfileAnswerPage extends StatefulWidget {
  final String roomId;
  final String playerId;
  final Stream<DocumentSnapshot<Map<String, dynamic>>> stream;

  const ProfileAnswerPage({
    super.key,
    required this.roomId,
    required this.playerId,
    required this.stream,
  });

  @override
  State<ProfileAnswerPage> createState() => _ProfileAnswerPageState();
}

class _ProfileAnswerPageState extends State<ProfileAnswerPage> {
  DocumentSnapshot? _documentSnapshot;
  List<Map<String, dynamic>> _randomizedCardsList = [];
  List<Map<String, dynamic>> _answers = [];
  List<Map<String, dynamic>> _characterCards = [];
  String? _parentPlayerId;


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

  @override
  void initState() {
    super.initState();
    _loadRoomSnapshot();
  }

  Future<void> _loadRoomSnapshot() async {
    _documentSnapshot = await getRoomSnapshot(widget.roomId);
    if (_documentSnapshot != null) {
      final roomData = _documentSnapshot!.data() as Map<String, dynamic>;

      // playersフィールドを取得
      final players = roomData['players'] as List<dynamic>;

      // current_turnフィールドを取得
      final currentTurn = roomData['current_turn'] as Map<String, dynamic>;

      // profilesフィールドを取得
      final profiles = List<Map<String, dynamic>>.from(currentTurn['profiles']);

      // ターン数を取得
      final turnCount = currentTurn['turn_count'] as int;

      // ターン数を考慮したシャッフルを実行
      _randomizedCardsList = _seededShuffle(
          List<Map<String, dynamic>>.from(currentTurn['character_cards']),
          turnCount);

      // profilesがある子プレイヤーのデータのみを_answersに追加
      _answers = profiles.where((profile) {
        // 親プレイヤー以外のプロフィールを取得
        return profile['assigned_player_id'] != currentTurn['parent_player_id'];
      }).map((profile) {
        // 対応するプレイヤーを探す
        final player = players.firstWhere(
          (player) => player['player_id'] == profile['assigned_player_id'],
          orElse: () => {'nickname': 'Unknown'},
        );

        return {
          'theme': profile['profile_theme'] as String? ?? '',
          'nickname': player['nickname'] as String? ?? '',
          'answer': profile['input_profile'] as String? ?? '',
        };
      }).toList();

      // 正誤判定用のデータを取得
      _characterCards =
          List<Map<String, dynamic>>.from(currentTurn['character_cards']);
      _parentPlayerId = currentTurn['parent_player_id'] as String;

    }
    setState(() {});
  }

  bool _checkIsCorrect(int originalIndex) {
    return _characterCards[originalIndex]['is_correct'] == true;
  }

  bool _isParentPlayer() {
    return widget.playerId == _parentPlayerId;
  }

  @override
  Widget build(BuildContext context) {
    if (_documentSnapshot == null) {
      return const Center(child: CircularProgressIndicator());
    }

    return Scaffold(
      appBar: AppBar(
        title: Text('親のターン'),
        automaticallyImplyLeading: false,
      ),
      body: ResponsiveLayout(
        breakPoints: [
          BreakPoint(minWidth: 1024, containerWidth: 500),
          BreakPoint(minWidth: 600, containerWidth: 500),
          BreakPoint(minWidth: 0, containerWidth: 300),
        ],
        builder: (context, containerWidth) {
          return ProfileAnswerForm(
            containerWidth: containerWidth,
            roomId: widget.roomId,
            playerId: widget.playerId,
            roomData: _documentSnapshot!,
            randomizedCardsList: _randomizedCardsList,
            answers: _answers,
            checkIsCorrect: _checkIsCorrect,
            isParentPlayer: _isParentPlayer(), //boolean
          );
        },
      ),
    );
  }
}
