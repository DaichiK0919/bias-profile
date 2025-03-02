import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:bias_profile/commons/ResponsiveLayout.dart';
import 'package:bias_profile/commons/constants.dart';
import 'package:bias_profile/components/PlayerList.dart';

class ResultPage extends StatefulWidget {
  final String roomId;
  final String playerId;
  final Stream<DocumentSnapshot<Map<String, dynamic>>> stream;

  const ResultPage({
    super.key,
    required this.roomId,
    required this.playerId,
    required this.stream,
  });

  @override
  State<ResultPage> createState() => _ResultPageState();
}

class _ResultPageState extends State<ResultPage> {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('最終結果'),
        automaticallyImplyLeading: false,
      ),
      body: ResponsiveLayout(
        breakPoints: [
          BreakPoint(minWidth: 1024, containerWidth: 500),
          BreakPoint(minWidth: 600, containerWidth: 500),
          BreakPoint(minWidth: 0, containerWidth: 300),
        ],
        builder: (context, containerWidth) {
          return ResultForm(
            containerWidth: containerWidth,
            roomId: widget.roomId,
            playerId: widget.playerId,
            stream: widget.stream,
          );
        },
      ),
    );
  }
}

class ResultForm extends StatefulWidget {
  final double containerWidth;
  final String roomId;
  final String playerId;
  final Stream<DocumentSnapshot<Map<String, dynamic>>> stream;

  const ResultForm({
    super.key,
    required this.containerWidth,
    required this.roomId,
    required this.playerId,
    required this.stream,
  });

  @override
  State<ResultForm> createState() => _ResultFormState();
}

class _ResultFormState extends State<ResultForm> {
  @override
  Widget build(BuildContext context) {
    return Center(
      child: Container(
        width: widget.containerWidth,
        padding: EdgeInsets.all(AppDimensions.paddingLarge),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Column(
              children: [
                PlayerList(
                  documentSnapshot: widget.stream,
                  listTitle: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        '最終スコア',
                        style: Theme.of(context).textTheme.labelLarge,
                      ),
                    ],
                  ),
                ),
              ],
            ),
            Container(
              margin: EdgeInsets.only(top: AppDimensions.marginLarge),
              child: ElevatedButton(
                onPressed: () {
                  // 全ての画面をクリアしてHomePageに戻る（名前付きルートを使用）
                  Navigator.of(context).pushNamedAndRemoveUntil(
                    '/',
                    (route) => false,
                  );
                },
                style: ElevatedButton.styleFrom(
                  padding: EdgeInsets.symmetric(
                    horizontal: AppDimensions.paddingLarge,
                    vertical: AppDimensions.paddingMedium,
                  ),
                ),
                child: Text('TOP画面に進む'),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
