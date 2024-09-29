import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:uuid/uuid.dart';
import 'package:bias_profile/constants.dart';

class RoomEnterForm extends StatefulWidget {
  final double containerWidth;
  final Function(String) onRoomCreated;
  final Function(String, String) onRoomJoined;
  final String? initialRoomId;

  const RoomEnterForm({
    Key? key,
    required this.containerWidth,
    required this.onRoomCreated,
    required this.onRoomJoined,
    this.initialRoomId,
  }) : super(key: key);

  @override
  State<RoomEnterForm> createState() => _RoomEnterFormState();
}

class _RoomEnterFormState extends State<RoomEnterForm> {
  final _formKey = GlobalKey<FormState>();
  final TextEditingController _nicknameController = TextEditingController();
  final TextEditingController _roomIdController = TextEditingController();
  FirebaseFirestore db = FirebaseFirestore.instance;

  @override
  void initState() {
    super.initState();
    if (widget.initialRoomId != null) {
      _roomIdController.text = widget.initialRoomId!;
    }
  }

  bool isValidNickname(String nickname) {
    return nickname.length >= 2 && nickname.length <= 10;
  }

  Future<DocumentReference> createRoom(String nickname) async {
    Map<String, dynamic> players = {
      'player_id': Uuid().v4(),
      'nickname': nickname,
      'ever_been_parent': false,
      'can_start_next_turn': false,
      'points': 0,
    };

    Map<String, dynamic> current_turn = {
      'turn_count': 0,
      'character_cards': [],
      'profiles': [],
      'parent_player_id': null,
      'parent_answer': null,
      'created_at': FieldValue.serverTimestamp(),
      'updated_at': FieldValue.serverTimestamp(),
    };

    DocumentReference roomRef = await db.collection('rooms').add({
      'status': 'recruiting',
      'players': [players],
      'current_turn': current_turn,
      'created_at': FieldValue.serverTimestamp(),
      'updated_at': FieldValue.serverTimestamp(),
    });

    print('部屋と作成者、ターンの情報が保存されました。IDは : ${roomRef.id} です');

    return roomRef;
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      width: widget.containerWidth,
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Form(
            key: _formKey,
            child: Column(
              children: [
                TextFormField(
                  validator: (value) {
                    if (value == null || value.isEmpty) {
                      return 'ニックネームを入力してください';
                    }
                    if (!isValidNickname(value)) {
                      return '2〜10文字で入力してください';
                    }
                    return null;
                  },
                  controller: _nicknameController,
                  decoration: InputDecoration(
                    labelText: 'ニックネームを入力',
                    labelStyle: Theme.of(context).textTheme.labelMedium,
                    border: OutlineInputBorder(),
                  ),
                ),
                SizedBox(height: 20),
                TextFormField(
                  controller: _roomIdController,
                  decoration: InputDecoration(
                    labelText: '部屋IDを入力 (新規作成時は空欄)',
                    labelStyle: Theme.of(context).textTheme.labelMedium,
                    border: OutlineInputBorder(),
                  ),
                ),
              ],
            ),
          ),
          Padding(
            padding: EdgeInsets.all(kPaddingLarge),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceEvenly,
              children: [
                ElevatedButton(
                  onPressed: () async {
                    if (_formKey.currentState!.validate()) {
                      String nickname = _nicknameController.text;
                      String roomId = _roomIdController.text;
                      if (roomId.isNotEmpty) {
                        widget.onRoomJoined(roomId, nickname);
                      } else {
                        try {
                          DocumentReference roomRef =
                              await createRoom(nickname);
                          widget.onRoomCreated(roomRef.id);
                        } catch (e) {
                          print('Error creating room: $e');
                          // エラーメッセージを表示する
                        }
                      }
                    }
                  },
                  child: Text('部屋に参加/作成'),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}
