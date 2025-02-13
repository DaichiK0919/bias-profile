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
            padding: EdgeInsets.all(AppDimensions.paddingMedium),
            child: Container(
              decoration: BoxDecoration(
                color: AppColors.tertiary,
                borderRadius: BorderRadius.circular(16.0),
              ),
              child: Padding(
                padding: EdgeInsets.all(AppDimensions.paddingMedium),
                child: Column(
                  children: [
                    Padding(
                      padding: EdgeInsets.symmetric(
                          vertical: AppDimensions.paddingMedium),
                      child: Container(
                        child: Text(
                          'どの画像の偏見を言っているか当てよう！',
                          style: Theme.of(context).textTheme.displayMedium,
                        ),
                      ),
                    ),

                    // 上段の3つ
                    Row(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children:
                          widget.randomizedCardsList.sublist(0, 3).map((card) {
                        return Padding(
                          padding: EdgeInsets.all(AppDimensions.paddingMedium),
                          child: Image.network(
                            card['character_card_path'],
                            width: ProfileChoiceConstants.imageWidth,
                            height: ProfileChoiceConstants.imageHeight,
                            fit: BoxFit.contain,
                          ),
                        );
                      }).toList(),
                    ),
                    Row(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children:
                          widget.randomizedCardsList.sublist(3, 5).map((card) {
                        // 3番目から5番目までを取得
                        return Padding(
                          padding: EdgeInsets.all(AppDimensions.paddingMedium),
                          child: Image.network(
                            card['character_card_path'],
                            width: ProfileChoiceConstants.imageWidth,
                            height: ProfileChoiceConstants.imageHeight,
                            fit: BoxFit.contain,
                          ),
                        );
                      }).toList(),
                    ),
                  ],
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }
}
