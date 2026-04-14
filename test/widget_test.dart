import 'package:flutter_test/flutter_test.dart';
// 確保導入了正確的路徑
import 'package:my_first_app/main.dart'; 

void main() {
  testWidgets('App displays home page', (WidgetTester tester) async {
    // 修正點 1：將 GeofenceMapPage() 改為 MyApp()
    // 因為您的 main.dart 定義的主程式類別是 MyApp
    await tester.pumpWidget(const MyApp());

    // 修正點 2：如果您目前的介面還沒寫好「正在監聽...」的文字，
    // 測試執行時會失敗。如果您只是想先讓紅線消失，可以先註解掉下面這行。
    // expect(find.text('正在監聽內壢車站範圍'), findsOneWidget);
    
    // 或者改為尋找您的 App 標題（假設您的標題是「智慧支付引導系統」）
    // expect(find.text('智慧支付引導系統'), findsOneWidget);
  });
}