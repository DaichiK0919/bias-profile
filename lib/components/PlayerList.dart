import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:bias_profile/commons/constants.dart';

class PlayerList extends StatelessWidget {
  final Stream<DocumentSnapshot<Map<String, dynamic>>> documentSnapshot;
  final Widget listTitle;

  const PlayerList({
    Key? key,
    required this.documentSnapshot,
    required this.listTitle,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Container(
      width: double.infinity,
      margin: EdgeInsets.symmetric(vertical: AppDimensions.marginLarge),
      decoration: BoxDecoration(
        color: Colors.grey,
        borderRadius: BorderRadius.circular(12.0),
      ),
      child: Padding(
        padding: EdgeInsets.all(AppDimensions.paddingLarge),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            listTitle,
            StreamBuilder<DocumentSnapshot>(
                stream: documentSnapshot,
                builder: (context, snapshot) {
                  if (snapshot.connectionState == ConnectionState.waiting) {
                    return CircularProgressIndicator();
                  } else {
                    final data = snapshot.data!.data() as Map<String, dynamic>;
                    final players = data['players'] as List<dynamic>;
                    return Column(
                      children: players.map((player) {
                        return Card(
                          child: Container(
                            width: double.infinity,
                            height: 36.0,
                            decoration: BoxDecoration(
                              color: Colors.white,
                              borderRadius: BorderRadius.circular(8.0),
                            ),
                            alignment: Alignment.centerLeft,
                            padding: EdgeInsets.symmetric(horizontal: 16.0),
                            child: Row(
                              mainAxisAlignment: MainAxisAlignment.spaceBetween,
                              children: [
                                Text(
                                  player['nickname'],
                                  textAlign: TextAlign.center,
                                ),
                                if (data['status'] != 'recruiting')
                                  Text(player['points'].toString() + 'pt')
                                else
                                  SizedBox.shrink(),
                              ],
                            ),
                          ),
                        );
                      }).toList(),
                    );
                  }
                }),
          ],
        ),
      ),
    );
  }
}
