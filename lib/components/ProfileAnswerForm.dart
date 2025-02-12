import 'package:flutter/material.dart';
import 'package:bias_profile/commons/constants.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/services.dart';
import 'package:bias_profile/components/components.dart';
import 'package:bias_profile/util/util.dart';
import 'package:bias_profile/util/RoomStatusMonitor.dart';
import 'package:bias_profile/Pages/ProfileInputPage.dart';

class ProfileAnswerForm extends StatefulWidget {
  final double containerWidth;
  final String roomId;
  final String playerId;
  final List<Map<String, dynamic>> randomizedCardsList;

  const ProfileAnswerForm({
    super.key,
    required this.containerWidth,
    required this.roomId,
    required this.playerId,
    required this.randomizedCardsList,
  });

  @override
  State<ProfileAnswerForm> createState() => _ProfileAnswerFormState();
}

class _ProfileAnswerFormState extends State<ProfileAnswerForm>
    with RoomStatusMonitor {
  @override
  void initState() {
    super.initState();
  }

  Widget build(BuildContext context) {
    return Center(
      child: Column(
        children: [
          Padding(
            padding: EdgeInsets.all(AppDimensions.paddingLarge),
            child: Container(
              decoration: BoxDecoration(
                color: AppColors.tertiary,
                borderRadius: BorderRadius.circular(16.0),
              ),
              child: Column(
                children: [
                  Text(
                    'どの画像の偏見を行っているか当てよう！',
                    style: TextStyle(fontSize: AppDimensions.fontSizeMedium),
                  ),
                  // 上段の3つ
                  Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children:
                        widget.randomizedCardsList.sublist(0, 3).map((card) {
                      return Padding(
                        padding: EdgeInsets.symmetric(
                            horizontal: AppDimensions.paddingMedium),
                        child: Image.network(
                          card['character_card_path'],
                          width: 96,
                          height: 142,
                          fit: BoxFit.contain,
                        ),
                      );
                    }).toList(),
                  ),
                  SizedBox(height: 8),
                  // 下段の2つ
                  Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children:
                        widget.randomizedCardsList.sublist(3, 5).map((card) {
                      // 3番目から5番目までを取得
                      return Padding(
                        padding: EdgeInsets.symmetric(
                            horizontal: AppDimensions.paddingMedium),
                        child: Image.network(
                          card['character_card_path'],
                          width: 96,
                          height: 142,
                          fit: BoxFit.contain,
                        ),
                      );
                    }).toList(),
                  ),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }
}
