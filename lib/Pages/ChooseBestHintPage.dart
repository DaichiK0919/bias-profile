import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:bias_profile/commons/ResponsiveLayout.dart';
import 'package:bias_profile/util/util.dart';
import 'package:bias_profile/util/RoomStatusMonitor.dart';

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

  Future<void> _loadRoomSnapshot() async {
    _documentSnapshot = await getRoomSnapshot(widget.roomId);
    if (_documentSnapshot != null) {
      final roomData = _documentSnapshot!.data() as Map<String, dynamic>;
      final currentTurn = roomData['current_turn'] as Map<String, dynamic>;

      _profiles = List<Map<String, dynamic>>.from(currentTurn['profiles']);
      _parentPlayerId = currentTurn['parent_player_id'] as String;

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
          // TODO: ここにベストヒント選択のUIを実装
          return const Center(
            child: Text('ベストヒントを選択するUIをここに実装します'),
          );
        },
      ),
    );
  }
}
