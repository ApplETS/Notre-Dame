// FLUTTER / DART / THIRD-PARTIES
import 'package:flutter_test/flutter_test.dart';

// VIEWS
import 'package:notredame/ui/views/login_view.dart';

// HELPERS
import '../../helpers.dart';

void main() {
  group('LoginView - ', () {
    setUp(() {});

    tearDown(() {});

    group('UI - ', () {
      testWidgets('has universal code and password text field', (WidgetTester tester) async {
        await tester.pumpWidget(localizedWidget(child: LoginView()));
        await tester.pumpAndSettle();

        // TODO check if there is both text fieds
      });
    });
  });

}