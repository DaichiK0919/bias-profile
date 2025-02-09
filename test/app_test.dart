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

  group('Room Flow Tests', () {
    setUpAll(() async {
      await dotenv.load(fileName: "assets/.env");
      await Firebase.initializeApp(
        options: DefaultFirebaseOptions.currentPlatform,
      );
    });

    testWidgets('Test Case 1: Room Creation -> Join -> Cancel Join', (tester) async {
      String? roomId;

      // 1-a-i: アプリ起動 (部屋作成者視点)
      app.main();
      await tester.pumpAndSettle();

      // 1-a-iv: ニックネームバリデーション
      final createRoomButton = find.text('部屋を作る');
      await tester.tap(createRoomButton);
      await tester.pumpAndSettle();
      expect(find.text('ニックネームを入力してください'), findsOneWidget);

      // 1-a-ii: 部屋作成
      final hostNicknameField = find.byType(TextField).first;
      await tester.enterText(hostNicknameField, 'HostPlayer');
      await tester.pumpAndSettle();
      await tester.tap(createRoomButton);
      await tester.pumpAndSettle();

      // 1-a-iii: 参加募集中画面の確認
      await tester.pumpUntilFound(find.text('参加募集中'));
      expect(find.text('HostPlayer'), findsOneWidget);
      expect(find.text('参加者'), findsOneWidget);

      // URLの取得
      final urlText = find.byType(Text).evaluate().map((e) => (e.widget as Text).data).firstWhere(
            (text) => text?.contains('bias-profile.web.app/?room_id=') ?? false,
        orElse: () => null,
      );
      expect(urlText, isNotNull);
      roomId = Uri.parse(urlText!).queryParameters['room_id'];
      expect(roomId, isNotNull);

      // 1-b-i & 1-b-ii: 参加者を追加してシミュレート
      await FirebaseFirestore.instance.collection('rooms').doc(roomId).update({
        'players': FieldValue.arrayUnion([
          {
            'player_id': 'player2_id',
            'nickname': 'JoinPlayer',
            'ever_been_parent': false,
            'can_start_next_turn': true,
            'points': 0,
          }
        ])
      });
      await tester.pumpAndSettle();

      // プレイヤーリストの更新を確認
      expect(find.text('JoinPlayer'), findsOneWidget);

      // 1-c-ii: 参加者のキャンセルをシミュレート
      await FirebaseFirestore.instance.collection('rooms').doc(roomId).update({
        'players': FieldValue.arrayRemove([
          {
            'player_id': 'player2_id',
            'nickname': 'JoinPlayer',
            'ever_been_parent': false,
            'can_start_next_turn': true,
            'points': 0,
          }
        ])
      });
      await tester.pumpAndSettle();

      // プレイヤーリストから参加者が削除されたことを確認
      expect(find.text('JoinPlayer'), findsNothing);
    });

    testWidgets('Test Case 2: Room Creation -> Join -> Cancel Recruitment', (tester) async {
      String? roomId;

      // 部屋の作成
      app.main();
      await tester.pumpAndSettle();

      final hostNicknameField = find.byType(TextField).first;
      await tester.enterText(hostNicknameField, 'HostPlayer');
      await tester.pumpAndSettle();

      final createRoomButton = find.text('部屋を作る');
      await tester.tap(createRoomButton);
      await tester.pumpAndSettle();

      // URLの取得
      await tester.pumpUntilFound(find.text('参加募集中'));
      final urlText = find.byType(Text).evaluate().map((e) => (e.widget as Text).data).firstWhere(
            (text) => text?.contains('bias-profile.web.app/?room_id=') ?? false,
        orElse: () => null,
      );
      roomId = Uri.parse(urlText!).queryParameters['room_id'];
      expect(roomId, isNotNull);

      // 参加者を追加
      await FirebaseFirestore.instance.collection('rooms').doc(roomId).update({
        'players': FieldValue.arrayUnion([
          {
            'player_id': 'player2_id',
            'nickname': 'JoinPlayer',
            'ever_been_parent': false,
            'can_start_next_turn': true,
            'points': 0,
          }
        ])
      });
      await tester.pumpAndSettle();

      // 1-c-i: 募集のキャンセル
      final cancelButton = find.text('キャンセル');
      expect(cancelButton, findsOneWidget);
      await tester.tap(cancelButton);
      await tester.pumpAndSettle();

      final confirmButton = find.text('OK');
      expect(confirmButton, findsOneWidget);
      await tester.tap(confirmButton);
      await tester.pumpAndSettle();

      // キャンセル完了の確認
      final snapshot = await FirebaseFirestore.instance
          .collection('rooms')
          .doc(roomId)
          .get();
      expect(snapshot.data()?['status'], 'closed');
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
      if (DateTime.now().difference(startTime) > timeout) {
        throw TimeoutException(
          'Pump until has timed out while looking for ${finder.description}. $description',
        );
      }
      try {
        await pumpAndSettle(pumpInterval);
        found = any(finder);
      } catch (e) {
        await pump(pumpInterval);
        found = any(finder);
      }
      await Future.delayed(const Duration(milliseconds: 50));
    }
  }
}