import 'dart:async';
import 'package:bias_profile/commons/firebase_options.dart';
import 'package:bias_profile/main.dart' as app;
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:integration_test/integration_test.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:flutter_dotenv/flutter_dotenv.dart';

void main() {
  IntegrationTestWidgetsFlutterBinding.ensureInitialized();

  group('Room Creation and Join Flow Test', () {
    setUpAll(() async {
      await dotenv.load(fileName: "assets/.env");
      await Firebase.initializeApp(
        options: DefaultFirebaseOptions.currentPlatform,
      );
    });

    testWidgets('Create room and verify initial room state', (tester) async {
      // アプリ起動
      app.main();
      await tester.pumpAndSettle();

      // 部屋作成
      final hostNicknameField = find.byType(TextField).first;
      await tester.enterText(hostNicknameField, 'HostPlayer');
      await tester.pumpAndSettle();

      final createRoomButton = find.text('部屋を作る');
      expect(createRoomButton, findsOneWidget);
      await tester.tap(createRoomButton);
      await tester.pumpAndSettle();

      // 部屋作成確認
      await tester.pumpUntilFound(find.text('参加募集中'));
      expect(find.text('HostPlayer'), findsOneWidget);

      // 画面に表示されているURLから部屋IDを取得
      final urlText = find.byType(Text).evaluate().map((e) => (e.widget as Text).data).firstWhere(
            (text) => text?.contains('bias-profile.web.app/?room_id=') ?? false,
        orElse: () => null,
      );
      expect(urlText, isNotNull);
      final roomId = Uri.parse(urlText!).queryParameters['room_id'];
      expect(roomId, isNotNull);

      // 参加者を擬似的に追加
      await FirebaseFirestore.instance.collection('rooms').doc(roomId).update({
        'players': FieldValue.arrayUnion([
          {
            'player_id': 'player2_id',
            'nickname': 'Player2',
            'ever_been_parent': false,
            'can_start_next_turn': true,
            'points': 0,
          }
        ])
      });
      await tester.pumpAndSettle();

      // リストにプレイヤーが追加されたことを確認
      expect(find.text('Player2'), findsOneWidget);

      // 募集締切
      final closeRecruitmentButton = find.text('締め切る');
      expect(closeRecruitmentButton, findsOneWidget);
      await tester.tap(closeRecruitmentButton);
      await tester.pumpAndSettle();
      final confirmButton = find.text('締め切る').last;
      await tester.tap(confirmButton);
      await tester.pumpAndSettle();
      await tester.pumpUntilFound(find.text('プレイヤー一覧'));
      expect(
          find.descendant(
              of: find.byType(Card),
              matching: find.text('HostPlayer')
          ),
          findsOneWidget
      );
      expect(
          find.descendant(
              of: find.byType(Card),
              matching: find.text('Player2')
          ),
          findsOneWidget
      );
      expect(find.text('0pt'), findsWidgets);
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