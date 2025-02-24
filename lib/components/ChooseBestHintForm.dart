import 'package:flutter/material.dart';
import 'package:bias_profile/commons/constants.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:bias_profile/components/components.dart';
import 'package:bias_profile/util/util.dart';
import 'package:bias_profile/util/RoomStatusMonitor.dart';

class ChooseBestHintForm extends StatefulWidget {
  final double containerWidth;
  final String roomId;
  final String playerId;
  final DocumentSnapshot roomData;
  final List<Map<String, dynamic>> randomizedCardsList;
  final List<Map<String, dynamic>> profiles;
  final String parentPlayerId;

  const ChooseBestHintForm({
    super.key,
    required this.containerWidth,
    required this.roomId,
    required this.playerId,
    required this.roomData,
    required this.randomizedCardsList,
    required this.profiles,
    required this.parentPlayerId,
  });

  @override
  State<ChooseBestHintForm> createState() => _ChooseBestHintFormState();
}

class _ChooseBestHintFormState extends State<ChooseBestHintForm>
    with RoomStatusMonitor {
  @override
  void initState() {
    super.initState();
    startRoomStatusMonitoring(
      widget.roomId,
      widget.playerId,
      skipProfileNavigation: true,
    );
  }

  // プロフィール選択時の処理
  Future<void> _handleProfileSelection(
      Map<String, dynamic> profile, BuildContext context) async {
    final playerNickname = profile['player_nickname'] ?? '不明なプレイヤー';

    showConfirmationDialog(
      context: context,
      confirmButtonText: '決定',
      cancelButtonText: '閉じる',
      title: profile['profile_theme'],
      content: Column(
        mainAxisSize: MainAxisSize.min,
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(profile['input_profile']),
        ],
      ),
      onCancel: () {},
      onConfirm: () async {
        Navigator.pop(context);

        // 確認ダイアログを表示
        showConfirmationDialog(
          context: context,
          confirmButtonText: 'OK',
          cancelButtonText: 'キャンセル',
          title: 'このプレイヤーにポイントを付与しますか？',
          content: Text('$playerNicknameさんのヒントをベストヒントとして選びます。'),
          onCancel: () {},
          onConfirm: () async {
            showDialog(
              context: context,
              barrierDismissible: false,
              builder: (BuildContext context) =>
                  const ProgressDialog(titleText: 'ポイントを付与しています'),
            );

            // 最初にroomRefを一度だけ取得
            DocumentReference roomRef = getRoomRef(widget.roomId);

            try {
              // Firestoreからプレイヤーデータを取得
              Map<String, dynamic> roomData =
                  await getRoomSnapshotAsMap(widget.roomId);
              List<dynamic> players = roomData['players'];

              // 選ばれたプレイヤーのインデックスを取得
              int selectedPlayerIndex = players.indexWhere((player) =>
                  player['player_id'] == profile['assigned_player_id']);

              // 選ばれたプレイヤーのポイントを+1
              if (selectedPlayerIndex != -1) {
                int currentPoints = players[selectedPlayerIndex]['points'] ?? 0;
                players[selectedPlayerIndex]['points'] = currentPoints + 1;
              }

              // Firestoreを更新（この時点ではcan_start_next_turnは更新しない）
              await roomRef.update({
                'players': players,
              });

              Navigator.pop(context); // ProgressDialogを閉じる

              // 成功メッセージを表示し、次へ進むボタンが押されたときに
              // can_start_next_turnを更新するロジックを実行
              showConfirmationDialog(
                context: context,
                confirmButtonText: '次へ進む',
                title: 'ポイントを付与しました',
                content: Text('$playerNicknameさんにポイントを付与しました。'),
                onConfirm: () async {
                  // 次へ進むが押されたときに実行
                  try {
                    // 最新データを取得（roomRefは再利用）
                    Map<String, dynamic> updatedRoomData =
                        await getRoomSnapshotAsMap(widget.roomId);
                    List<dynamic> updatedPlayers = updatedRoomData['players'];

                    // 自分のプレイヤーインデックスを取得
                    int playerIndex = updatedPlayers.indexWhere(
                        (player) => player['player_id'] == widget.playerId);

                    if (playerIndex != -1) {
                      // can_start_next_turnをtrueに設定
                      updatedPlayers[playerIndex]['can_start_next_turn'] = true;

                      // Firestoreを更新（roomRefを再利用）
                      await roomRef.update({
                        'players': updatedPlayers,
                      });

                      print(
                          'プレイヤー ${widget.playerId} のcan_start_next_turnが更新されました。');
                    } else {
                      print('プレイヤー ${widget.playerId} が見つかりませんでした。');
                    }
                  } catch (e) {
                    print('エラーが発生しました: $e');

                    // エラーメッセージを表示
                    showConfirmationDialog(
                      context: context,
                      confirmButtonText: '閉じる',
                      title: 'エラーが発生しました',
                      content: Text('操作中にエラーが発生しました: $e'),
                    );
                  }
                },
              );
            } catch (e) {
              Navigator.pop(context); // ProgressDialogを閉じる

              // エラーメッセージを表示
              showConfirmationDialog(
                context: context,
                confirmButtonText: '閉じる',
                title: 'エラーが発生しました',
                content: Text('操作中にエラーが発生しました: $e'),
              );
            }
          },
        );
      },
    );
  }

  // カード表示用のウィジェットを共通化
  Widget _buildCardItem(Map<String, dynamic> card) {
    return Flexible(
      flex: 1,
      child: Padding(
        padding: EdgeInsets.all(AppDimensions.paddingMedium),
        child: ConstrainedBox(
          constraints: BoxConstraints(
            maxWidth: ProfileChoiceConstants.imageWidth,
            maxHeight: ProfileChoiceConstants.imageHeight,
          ),
          child: AspectRatio(
            aspectRatio: 1.0 / 1.46,
            child: Image.network(
              card['character_card_path'],
              width: ProfileChoiceConstants.imageWidth,
              height: ProfileChoiceConstants.imageHeight,
              fit: BoxFit.contain,
            ),
          ),
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Center(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Padding(
            padding: EdgeInsets.all(AppDimensions.paddingMedium),
            child: Container(
              decoration: BoxDecoration(
                color: AppColors.tertiary,
                borderRadius: BorderRadius.circular(16.0),
              ),
              child: Padding(
                padding: EdgeInsets.all(AppDimensions.paddingMedium),
                child: Column(children: [
                  Padding(
                    padding: EdgeInsets.symmetric(
                        vertical: AppDimensions.paddingMedium),
                    child: Text(
                      'ベストヒントを選びましょう',
                      style: Theme.of(context).textTheme.displayMedium,
                    ),
                  ),

                  // 上段の3つ
                  Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: widget.randomizedCardsList
                        .sublist(0, 3)
                        .map(_buildCardItem)
                        .toList(),
                  ),
                  // 下段の2つ
                  Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: widget.randomizedCardsList
                        .sublist(3, 5)
                        .map(_buildCardItem)
                        .toList(),
                  ),
                ]),
              ),
            ),
          ),
          Text('ベストヒントを選択してください'),
          Text('選択したプレイヤーに1pt与えられます'),
          Expanded(
            child: ListView.separated(
              padding: EdgeInsets.symmetric(
                horizontal: AppDimensions.paddingMedium,
              ),
              itemCount: widget.profiles.length,
              separatorBuilder: (context, index) => const Divider(),
              itemBuilder: (context, index) {
                final profile = widget.profiles[index];

                // 親プレイヤーのプロフィールは表示しない
                if (profile['assigned_player_id'] == widget.parentPlayerId) {
                  return const SizedBox.shrink();
                }

                return GestureDetector(
                  onTap: () {
                    _handleProfileSelection(profile, context);
                  },
                  child: Padding(
                    padding: EdgeInsets.symmetric(
                      vertical: AppDimensions.paddingSmall,
                      horizontal: AppDimensions.paddingMedium,
                    ),
                    child: Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        Expanded(
                          flex: 8,
                          child: Text(
                            profile['profile_theme'] ?? '',
                            style: Theme.of(context).textTheme.bodyLarge,
                            overflow: TextOverflow.ellipsis,
                          ),
                        ),
                        Expanded(
                          flex: 4,
                          child: Text(
                            profile['player_nickname'] ?? '',
                            style: Theme.of(context).textTheme.bodyLarge,
                            overflow: TextOverflow.ellipsis,
                            textAlign: TextAlign.right,
                          ),
                        ),
                        const Icon(
                          Icons.arrow_right_alt_sharp,
                          size: 16,
                          color: Colors.grey,
                        ),
                      ],
                    ),
                  ),
                );
              },
            ),
          ),
        ],
      ),
    );
  }
}
