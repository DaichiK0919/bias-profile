import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:bias_profile/components/components.dart';
import 'package:bias_profile/commons/ResponsiveLayout.dart';
import 'package:bias_profile/util/util.dart';

class RoomInProgressPage extends StatefulWidget {
  final String roomId;
  final String playerId;
  final Stream<DocumentSnapshot<Map<String, dynamic>>> stream;

  const RoomInProgressPage({
    super.key,
    required this.roomId,
    required this.playerId,
    required this.stream,
  });

  @override
  State<RoomInProgressPage> createState() => _RoomInProgressPageState();
}

class _RoomInProgressPageState extends State<RoomInProgressPage> {
  DocumentSnapshot? _documentSnapshot;
  String? _correctCardPath;
  List<String> _otherCardPaths = []; // falseの画像パスを保持
  String? _assignedProfileTheme;

  @override
  void initState() {
    super.initState();

    _loadRoomSnapshot();
  }

  Future<void> _loadRoomSnapshot() async {
    _documentSnapshot = await getRoomSnapshot(widget.roomId);
    if (_documentSnapshot != null) {
      final roomData = _documentSnapshot!.data() as Map<String, dynamic>;

      // current_turnフィールドからcharcter_cardsとprofileリストを取得
      final currentTurn = roomData['current_turn'] as Map<String, dynamic>;

      final cards =
          List<Map<String, dynamic>>.from(currentTurn['character_cards']);
      final profiles = List<Map<String, dynamic>>.from(currentTurn['profiles']);

      final assignedProfile = profiles.firstWhere(
        (profile) => profile['assigned_player_id'] == widget.playerId,
        orElse: () => {
          'profile_theme': null,
          'assigned_player_id': null,
          'input_profile': null
        },
      );

      _assignedProfileTheme =
          assignedProfile != null && assignedProfile['profile_theme'] != null
              ? assignedProfile['profile_theme'] as String
              : null;

      // is_correct=trueのカードのパスを1つ取得
      final correctCard = cards.firstWhere(
        (card) => card['is_correct'] == true,
        orElse: () => {'character_card_path': null, 'is_correct': false},
      );

      _correctCardPath =
          correctCard != null && correctCard['character_card_path'] != null
              ? correctCard['character_card_path'] as String
              : null;
      _otherCardPaths = cards
          .where((card) => card['is_correct'] == false)
          .map((card) => card['character_card_path'] as String)
          .toList();
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
        title: switch (_documentSnapshot!.get('status')) {
          'in_progress' => Text('プレイヤー一覧'),
          'closed' => Text('最終結果'),
          _ => null,
        },
        automaticallyImplyLeading: false,
      ),
      body: ResponsiveLayout(
        breakPoints: [
          BreakPoint(minWidth: 1024, containerWidth: 500),
          BreakPoint(minWidth: 600, containerWidth: 500),
          BreakPoint(minWidth: 0, containerWidth: 300),
        ],
        builder: (context, containerWidth) {
          return RoomInProgressForm(
            containerWidth: containerWidth,
            roomId: widget.roomId,
            playerId: widget.playerId,
            streamAsMap: widget.stream,
            correctCardPath: _correctCardPath,
            otherCardPaths: _otherCardPaths,
            assignedProfileTheme: _assignedProfileTheme,
          );
        },
      ),
    );
  }
}
