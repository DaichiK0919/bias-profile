import 'package:bias_profile/components/components.dart';
import 'package:flutter/material.dart';
import 'package:uuid/uuid.dart';
import 'package:bias_profile/Pages/RoomRecruitingPage.dart';
import 'package:bias_profile/components/RoomEntryForm.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:bias_profile/util/util.dart';
import 'package:bias_profile/commons/constants.dart';

class RoomCreateandJoinPage extends StatefulWidget {
  final double containerWidth;

  const RoomCreateandJoinPage({super.key, required this.containerWidth});

  @override
  _RoomCreateandJoinPageState createState() => _RoomCreateandJoinPageState();
}

class _RoomCreateandJoinPageState extends State<RoomCreateandJoinPage> {
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
    if (uri.queryParameters.containsKey('room_id')) {
      setState(() {
        _roomId = uri.queryParameters['room_id'];
      });
    }
  }

  void _onRoomCreated(String roomId) {
    Navigator.push(
      context,
      MaterialPageRoute(
        builder: (context) => RoomRecruitingPage(
          roomId: roomId,
          playerId: playerId,
          isCreator: isCreator,
        ),
      ),
    );
  }

  void _joinRoom(String roomId, String nickname) async {
    Map<String, dynamic> playerData = {
      'player_id': playerId,
      'nickname': nickname,
      'ever_been_parent': false,
      'can_start_next_turn': true,
      'points': 0,
    };

    try {
      // Firestoreで指定されたroomIdのドキュメントを更新し、プレイヤーを追加
      DocumentReference roomRef = getRoomRef(roomId);
      DocumentSnapshot roomSnapshot = await getRoomSnapshot(roomId);

      showDialog(
          context: context,
          builder: (context) {
            return ProgressDialog(titleText: '参加申請中です・・・');
          });
      await Future.delayed(Duration(seconds: AppDurations.processingDuration));

      if (roomSnapshot.exists) {
        Map<String, dynamic> roomData = await getRoomSnapshotAsMap(roomId);
        String status = roomData['status'];

        if (status == 'recruiting') {
          // プレイヤーを追加
          await roomRef.update({
            'players': FieldValue.arrayUnion([playerData]), // プレイヤーを追加
          });

          print('Player added to room with ID: $roomId');
          isCreator = false;

          // CircularProgressIndicatorを非表示にするためのダイアログを閉じる
          Navigator.of(context).pop();

          // 参加成功後、RoomViewPageに遷移
          Navigator.push(
            context,
            MaterialPageRoute(
              builder: (context) => RoomRecruitingPage(
                roomId: roomId,
                playerId: playerId,
                isCreator: isCreator,
              ),
            ),
          );
        } else {
          // 参加できない場合の処理
          print('Room has already had maximum players.');
          // CircularProgressIndicatorを非表示にするためのダイアログを閉じる
          Navigator.of(context).pop();
          // スナックバーを表示
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(content: Text('部屋に参加できませんでした')),
          );
          // 参加できない場合の処理
        }
      } else {
        // ドキュメントが存在しない場合の処理
        print('Room does not exist');
        // CircularProgressIndicatorを非表示にするためのダイアログを閉じる
        Navigator.of(context).pop();
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('指定された部屋が存在しません')),
        );
      }
    } catch (e) {
      print('Error adding player to room: $e');
      // エラーハンドリング（CircularProgressIndicatorを非表示にしてエラーメッセージを表示）
      Navigator.of(context).pop();
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('エラーが発生しました。再度お試しください。')),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Center(
        child: RoomEntryForm(
          containerWidth: widget.containerWidth,
          playerId: playerId,
          onRoomCreated: _onRoomCreated,
          onRoomJoined: _joinRoom,
          initialRoomId: _roomId,
        ),
      ),
    );
  }
}
