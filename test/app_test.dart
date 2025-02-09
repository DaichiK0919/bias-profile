import 'dart:async';
import 'package:bias_profile/commons/firebase_options.dart';
import 'package:bias_profile/main.dart' as app;
import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:integration_test/integration_test.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:flutter_dotenv/flutter_dotenv.dart';

void main() {
  IntegrationTestWidgetsFlutterBinding.ensureInitialized();

  group('Room Creation and Join Flow Test', () {
    String? roomId;

    setUpAll(() async {
      await dotenv.load(fileName: "assets/.env");
      await Firebase.initializeApp(
        options: DefaultFirebaseOptions.currentPlatform,
      );
    });

    testWidgets('Create room and verify initial room state', (tester) async {
      // アプリの起動
      app.main();
      await tester.pumpUntilFound(find.text('部屋を作る'));

      // ニックネームを入力
      final nicknameField = find.byType(TextField).first;
      await tester.enterText(nicknameField, 'HostUser');

      // 部屋を作るボタンをタップ
      await tester.tap(find.text('部屋を作る'));
      await tester.pumpUntilFound(find.text('https://bias-profile.web.app/?room_id='));

      // 画面に表示されているURLテキストを取得
      final urlWidget = find.byType(SelectableText).evaluate().first.widget as SelectableText;
      final urlText = urlWidget.data!;

      // URLから部屋IDを抽出
      final uri = Uri.parse(urlText);
      roomId = uri.queryParameters['room_id'];

      // 部屋IDが取得できたことを確認
      expect(roomId, isNotNull);
      expect(roomId!.isNotEmpty, true);
    });

    testWidgets('First player joins the room', (tester) async {
      app.main();
      await tester.pumpUntilFound(find.text('部屋を作る'));

      final nicknameField = find.byType(TextField).first;
      await tester.enterText(nicknameField, 'Player1');

      final roomIdField = find.byType(TextField).at(1);
      await tester.enterText(roomIdField, roomId!);

      // 部屋に参加
      await tester.tap(find.text('部屋を作る'));

      // 参加後の画面表示を確認
      await tester.pumpUntilFound(find.text('Player1'));
      expect(find.text('HostUser'), findsOneWidget);
    });

  });
}

extension TestUtilEx on WidgetTester {
  Future<void> pumpUntilFound(
      Finder finder, {
        Duration timeout = const Duration(seconds: 10),
        Duration pumpInterval = const Duration(milliseconds: 100),
        String description = '',
      }) async {
    bool found = false;
    final startTime = DateTime.now();

    while (!found) {
      // タイムアウトチェック
      if (DateTime.now().difference(startTime) > timeout) {
        throw TimeoutException(
          'Pump until has timed out while looking for ${finder.description}. $description',
        );
      }

      try {
        await pumpAndSettle(pumpInterval);
        found = any(finder);
      } catch (e) {
        // pumpAndSettleが失敗した場合（アニメーションが継続している場合など）
        await pump(pumpInterval);
        found = any(finder);
      }

      // 短い待機を入れてCPU負荷を下げる
      await Future.delayed(const Duration(milliseconds: 50));
    }
  }
}