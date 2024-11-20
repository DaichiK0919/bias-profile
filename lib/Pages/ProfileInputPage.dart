import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:bias_profile/components/components.dart';
import 'package:bias_profile/commons/ResponsiveLayout.dart';
import 'package:bias_profile/util/util.dart';

class ProfileInputPage extends StatefulWidget {
  final String roomId;
  final String playerId;
  final Stream<DocumentSnapshot<Map<String, dynamic>>> stream;

  const ProfileInputPage({
    super.key,
    required this.roomId,
    required this.playerId,
    required this.stream,
  });

  @override
  State<ProfileInputPage> createState() => _ProfileInputPageState();
}

class _ProfileInputPageState extends State<ProfileInputPage> {
  DocumentSnapshot? _documentSnapshot;
  String? _correctCardPath;

  @override
  void initState() {
    super.initState();
    _loadRoomSnapshot();
  }

  Future<void> _loadRoomSnapshot() async {
    _documentSnapshot = await getRoomSnapshot(widget.roomId);
    if (_documentSnapshot != null) {
      final data = _documentSnapshot!.data() as Map<String, dynamic>;
      final cards = data['character_cards'] as List<dynamic>;

      // is_correct=trueのカードのパスを1つ取得
      final correctCard = cards.firstWhere(
        (card) => card['is_correct'] == true,
        orElse: () => null,
      );
      _correctCardPath = correctCard != null
          ? correctCard['character_card_path'] as String
          : null;
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
        title: Text('プロフィール入力画面'),
        automaticallyImplyLeading: false,
      ),
      body: ResponsiveLayout(
        breakPoints: [
          BreakPoint(minWidth: 1024, containerWidth: 500),
          BreakPoint(minWidth: 600, containerWidth: 500),
          BreakPoint(minWidth: 0, containerWidth: 300),
        ],
        builder: (context, containerWidth) {
          return ProfileInputForm(
            containerWidth: containerWidth,
            roomId: widget.roomId,
            playerId: widget.playerId,
            correctCardPath: _correctCardPath,
          );
        },
      ),
    );
  }
}
