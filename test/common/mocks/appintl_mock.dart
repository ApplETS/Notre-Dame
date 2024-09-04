import 'package:mockito/annotations.dart';
import 'package:flutter_gen/gen_l10n/app_localizations.dart';
import 'package:mockito/mockito.dart';

@GenerateNiceMocks([MockSpec<AppIntlMock>()])
class AppIntlMock extends Mock implements AppIntl {}
