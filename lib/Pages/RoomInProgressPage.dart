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

  @override
  void initState() {
    super.initState();

    _loadRoomSnapshot();
  }

  Future<void> _loadRoomSnapshot() async {
    _documentSnapshot = await getRoomSnapshot(widget.roomId);
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
              streamAsMap: widget.stream);
        },
      ),
    );
  }
}
