import 'package:flutter/material.dart';
import 'package:uuid/uuid.dart';
import 'package:bias_profile/Pages/RoomViewPage.dart';
import 'package:bias_profile/components/RoomEntryForm.dart';
import 'package:cloud_firestore/cloud_firestore.dart';

class CreateandJoinRoomPage extends StatefulWidget {
  final double containerWidth;

  const CreateandJoinRoomPage({super.key, required this.containerWidth});

  @override
  _CreateandJoinRoomPageState createState() => _CreateandJoinRoomPageState();
}

class _CreateandJoinRoomPageState extends State<CreateandJoinRoomPage> {
  String? _roomId;
  final String playerId = Uuid().v4();
  FirebaseFirestore db = FirebaseFirestore.instance;
  bool isCreator = true;

  @override
  void initState() {
    super.initState();
    _parseRoomIdFromUrl();
  }

  void _parseRoomIdFromUrl() {
    final uri = Uri.base;
    if (uri.queryParameters.containsKey('roomId')) {
      setState(() {
        _roomId = uri.queryParameters['roomId'];
      });
    }
  }

  void _onRoomCreated(String roomId) {
    Navigator.push(
      context,
      MaterialPageRoute(
        builder: (context) => RoomViewPage(
          roomId: roomId,
          playerId: playerId,
          isCreator: isCreator,
        ),
      ),
    );
  }

  void _joinRoom(String roomId, String nickname) async {
    print('Joining room with ID: $roomId and nickname: $nickname');
    Map<String, dynamic> playerData = {
      'player_id': playerId,
      'nickname': nickname,
      'ever_been_parent': false,
      'can_start_next_turn': false,
      'points': 0,
    };

    try {
      // Firestoreで指定されたroomIdのドキュメントを更新し、プレイヤーを追加
      DocumentReference roomRef = db.collection('rooms').doc(roomId);
      await roomRef.update({
        'players': FieldValue.arrayUnion([playerData]), // プレイヤーを追加
      });

      print('Player added to room with ID: $roomId');
      isCreator = false;
      // 参加成功後、RoomViewPageに遷移
      Navigator.push(
        context,
        MaterialPageRoute(
          builder: (context) => RoomViewPage(
            roomId: roomId,
            playerId: playerId,
            isCreator: isCreator,
          ),
        ),
      );
    } catch (e) {
      print('Error adding player to room: $e');
      // エラーハンドリング（必要に応じてユーザーに通知）
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Center(
        child: RoomEntryForm(
          containerWidth: widget.containerWidth,
          onRoomCreated: _onRoomCreated,
          onRoomJoined: _joinRoom,
          initialRoomId: _roomId,
        ),
      ),
    );
  }
}
