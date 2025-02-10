import 'package:flutter/material.dart';
import 'package:bias_profile/commons/constants.dart';

class UitestProfileInputForm extends StatelessWidget {
  const UitestProfileInputForm({super.key});
  final double containerWidth = 500;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Center(
        child: Container(
          width: containerWidth,
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Container(
                margin: EdgeInsets.fromLTRB(0, AppDimensions.marginMedium, 0, AppDimensions.marginMedium),
                decoration: BoxDecoration(
                  color: Colors.grey,
                  borderRadius: BorderRadius.circular(12.0),
                ),
                child: Padding(
                  padding: EdgeInsets.all(AppDimensions.paddingLarge),
                  child: Column(
                    children: [
                      Text(
                        'こちらの人物の見た目から勝手に想像して\n指定したプロフィールを入力してください',
                      ),
                      SizedBox(height: 16.0),
                      Image(
                          image: NetworkImage('https://picsum.photos/236/340')),
                    ],
                  ),
                ),
              ),
              Container(
                margin: EdgeInsets.fromLTRB(
                    AppDimensions.marginLarge, AppDimensions.marginMedium, AppDimensions.marginLarge, AppDimensions.paddingLarge),
                child: Form(
                  child: TextFormField(
                    keyboardType: TextInputType.multiline,
                    maxLines: 4,
                    decoration: InputDecoration(
                      labelText: '（ここにお題が入る）',
                      labelStyle: Theme.of(context).textTheme.labelMedium,
                      border: OutlineInputBorder(),
                    ),
                  ),
                ),
              ),
              ElevatedButton(
                onPressed: () {
                  print('入力完了');
                },
                child: Text('入力完了'),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
