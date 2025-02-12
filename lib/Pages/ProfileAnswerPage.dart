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

  // ターン数を考慮したシャッフル関数
  List<Map<String, dynamic>> _seededShuffle(
      List<Map<String, dynamic>> list, int turnCount) {
    // roomIdとターン数を組み合わせてシード値を生成
    final seed = widget.roomId.hashCode ^ turnCount;
    final random = Random(seed);

    final shuffled = List<Map<String, dynamic>>.from(list);
    for (var i = shuffled.length - 1; i > 0; i--) {
      final j = random.nextInt(i + 1);
      final temp = shuffled[i];
      shuffled[i] = shuffled[j];
      shuffled[j] = temp;
    }
    return shuffled;
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

      // current_turnフィールドを取得
      final currentTurn = roomData['current_turn'] as Map<String, dynamic>;

      // ターン数を取得
      final turnCount = currentTurn['turn_count'] as int;

      // ターン数を考慮したシャッフルを実行
      _randomizedCardsList = _seededShuffle(
          List<Map<String, dynamic>>.from(currentTurn['character_cards']),
          turnCount);
    }
    setState(() {});
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
            randomizedCardsList: _randomizedCardsList,
          );
        },
      ),
    );
  }
}
