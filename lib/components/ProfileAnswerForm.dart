import 'package:flutter/material.dart';
import 'package:bias_profile/commons/constants.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/services.dart';
import 'package:bias_profile/components/components.dart';
import 'package:bias_profile/util/util.dart';
import 'package:bias_profile/util/RoomStatusMonitor.dart';
import 'package:bias_profile/Pages/ChooseBestHintPage.dart';

class ProfileAnswerForm extends StatefulWidget {
  final double containerWidth;
  final String roomId;
  final String playerId;
  final DocumentSnapshot roomData;
  final List<Map<String, dynamic>> randomizedCardsList;
  final List<Map<String, dynamic>> answers;
  final bool Function(int) checkIsCorrect;
  final bool isParentPlayer;

  const ProfileAnswerForm({
    super.key,
    required this.containerWidth,
    required this.roomId,
    required this.playerId,
    required this.roomData,
    required this.randomizedCardsList,
    required this.answers,
    required this.checkIsCorrect,
    required this.isParentPlayer,
  });

  @override
  State<ProfileAnswerForm> createState() => _ProfileAnswerFormState();
}

class _ProfileAnswerFormState extends State<ProfileAnswerForm>
    with RoomStatusMonitor {
  @override
  void initState() {
    super.initState();
    startRoomStatusMonitoring(
      widget.roomId,
      widget.playerId,
      skipProfileNavigation: true, // ProfileAnswerPage上での監視なのでスキップ
    );
  }

  // カード選択時の処理を共通化
  Future<void> _handleCardSelection(
      Map<String, dynamic> card, BuildContext context) async {
    if (!widget.isParentPlayer) return;

    showConfirmationDialog(
      context: context,
      confirmButtonText: 'OK',
      cancelButtonText: 'キャンセル',
      title: 'この人物に決めますか？',
      content: Image.network(
        card['character_card_path'],
        width: ProfileConstants.imageWidth,
        height: ProfileConstants.imageHeight,
        fit: BoxFit.contain,
      ),
      onConfirm: () async {
        // parent_answerを更新
        await getRoomRef(widget.roomId)
            .update({'current_turn.parent_answer': card['original_index']});

        // 正誤判定
        final isCorrect = widget.checkIsCorrect(card['original_index']);

        Navigator.pop(context);

        if (isCorrect && widget.isParentPlayer) {
          showConfirmationDialog(
              context: context,
              title: '正解！！',
              content: Image.network(
                card['character_card_path'],
                width: ProfileConstants.imageWidth,
                height: ProfileConstants.imageHeight,
                fit: BoxFit.contain,
              ),
              confirmButtonText: '次へ進む',
              onConfirm: () async {
                Navigator.pushReplacement(
                    context,
                    MaterialPageRoute(
                        builder: (context) => ChooseBestHintPage(
                              roomId: widget.roomId,
                              playerId: widget.playerId,
                            )));
              });
        } else {
          showConfirmationDialog(
            context: context,
            title: '不正解...正解はこちら',
            content: Image.network(
              widget.randomizedCardsList.firstWhere(
                  (card) => card['original_index'] == 0)['character_card_path'],
              width: ProfileConstants.imageWidth,
              height: ProfileConstants.imageHeight,
              fit: BoxFit.contain,
            ),
            confirmButtonText: '次へ進む',
            onConfirm: () async {
              showDialog(
                context: context,
                barrierDismissible: false,
                builder: (BuildContext context) =>
                    const ProgressDialog(titleText: 'ターンを開始する準備をしています。'),
              );
              DocumentReference roomRef = getRoomRef(widget.roomId);
              Map<String, dynamic> roomData =
                  await getRoomSnapshotAsMap(widget.roomId);
              List<dynamic> players = roomData['players'];

              int playerIndex = players.indexWhere(
                  (player) => player['player_id'] == widget.playerId);

              if (playerIndex != -1) {
                players[playerIndex]['can_start_next_turn'] = true;

                await roomRef.update({
                  'players': players,
                });

                print('プレイヤー $widget.playerId のcan_start_next_turnが更新されました。');
              } else {
                print('プレイヤー $widget.playerId が見つかりませんでした。');
              }
            },
          );
        }
      },
      onCancel: () {},
    );
  }

  // カード表示用のウィジェットを共通化
  Widget _buildCardItem(Map<String, dynamic> card) {
    return Flexible(
      flex: 1,
      child: GestureDetector(
        onTap: widget.isParentPlayer
            ? () => _handleCardSelection(card, context)
            : null,
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
      ),
    );
  }

  Widget build(BuildContext context) {
    return Center(
      child: Column(
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
                      widget.isParentPlayer
                          ? 'どの画像の偏見を言っているか当てよう！'
                          : '親が回答している間、他のプレイヤーが入力したプロフィールを覗いてみましょう',
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
          Expanded(
            child: ListView.separated(
              padding: EdgeInsets.symmetric(
                horizontal: AppDimensions.paddingMedium,
              ),
              itemCount: widget.answers.length,
              separatorBuilder: (context, index) => const Divider(),
              itemBuilder: (context, index) {
                final answer = widget.answers[index];
                return GestureDetector(
                  onTap: () {
                    showConfirmationDialog(
                      context: context,
                      confirmButtonText: '閉じる',
                      title: answer['theme'],
                      content: answer['answer'],
                    );
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
                            answer['theme'],
                            style: Theme.of(context).textTheme.bodyLarge,
                            overflow: TextOverflow.ellipsis,
                          ),
                        ),
                        Expanded(
                          flex: 4,
                          child: Text(
                            answer['nickname'],
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
