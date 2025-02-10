import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:bias_profile/components/components.dart';
import 'package:bias_profile/commons/ResponsiveLayout.dart';
import 'package:bias_profile/util/util.dart';

class ProfileAnswerPage extends StatefulWidget {
  final String roomId;
  final String playerId;
  final Stream<DocumentSnapshot<Map<String, dynamic>>> stream;
  // final String? correctCardPath;
  // final List<String> otherCardPaths;
  // final String? assignedProfileTheme;

  const ProfileAnswerPage({
    super.key,
    required this.roomId,
    required this.playerId,
    required this.stream,
    // required this.correctCardPath,
    // required this.otherCardPaths,
    // required this.assignedProfileTheme,
  });

  @override
  State<ProfileAnswerPage> createState() => _ProfileAnswerPageState();
}

class _ProfileAnswerPageState extends State<ProfileAnswerPage> {
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
          // return ProfileInputForm(
          //   containerWidth: containerWidth,
          //   roomId: widget.roomId,
          //   playerId: widget.playerId,
          //   correctCardPath: widget.correctCardPath,
          //   otherCardPaths: widget.otherCardPaths,
          //   assignedProfileTheme: widget.assignedProfileTheme,
          // );
          return SizedBox.shrink();
        },
      ),
    );
  }
}
