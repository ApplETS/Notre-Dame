// FLUTTER / DART / THIRD-PARTIES
import 'package:flutter_test/flutter_test.dart';
import 'package:flutter_gen/gen_l10n/app_localizations.dart';
import 'package:mockito/mockito.dart';

// SERVICES / MANAGERS
import 'package:notredame/core/managers/user_repository.dart';
import 'package:notredame/core/services/navigation_service.dart';

// VIEW MODEL
import 'package:notredame/core/viewmodels/login_viewmodel.dart';

// CONSTANTS
import 'package:notredame/core/constants/router_paths.dart';
import 'package:notredame/core/constants/app_info.dart';
// OTHER
import '../helpers.dart';
import '../mock/managers/user_repository_mock.dart';

void main() {
  const String universalCodeValid = "AA11111";
  const String universalCodeInvalid = "A1111";
  const String passwordCodeValid = "password";
  const String passwordCodeInvalid = "";

  NavigationService navigationService;
  UserRepositoryMock userRepositoryMock;

  AppIntl appIntl;

  LoginViewModel viewModel;

  group('LoginViewModel - ', () {
    setUp(() async {
      navigationService = setupNavigationServiceMock();
      userRepositoryMock = setupUserRepositoryMock() as UserRepositoryMock;
      setupLogger();
      setupPreferencesServiceMock();
      appIntl = await setupAppIntl();

      viewModel = LoginViewModel(intl: appIntl);
    });

    tearDown(() {
      unregister<NavigationService>();
      unregister<UserRepository>();
    });

    group('validateUniversalCode - ', () {
      test('with right formatted universal code should return null', () {
        expect(viewModel.validateUniversalCode(universalCodeValid), null);
        expect(viewModel.universalCode, universalCodeValid);
      });

      test('with empty value should return login_error_field_required', () {
        expect(viewModel.validateUniversalCode(""),
            appIntl.login_error_field_required);
        expect(viewModel.universalCode, "");
      });

      test(
          'with wrong formatted universal code should return login_error_invalid_universal_code',
          () {
        expect(viewModel.validateUniversalCode(universalCodeInvalid),
            appIntl.login_error_invalid_universal_code);
        expect(viewModel.universalCode, "");
      });
    });

    group('validatePassword - ', () {
      test('with not empty value should return null', () {
        expect(viewModel.validatePassword(passwordCodeValid), null);
        expect(viewModel.password, passwordCodeValid);
      });

      test('with empty value should return login_error_field_required', () {
        expect(viewModel.validatePassword(passwordCodeInvalid),
            appIntl.login_error_field_required);
        expect(viewModel.password, passwordCodeInvalid);
      });
    });

    group('canSubmit - ', () {
      test('universal code and password are correct should return true', () {
        viewModel.validateUniversalCode(universalCodeValid);
        viewModel.validatePassword(passwordCodeValid);

        expect(viewModel.canSubmit, true);
      });

      test('universal code is incorrect should return false', () {
        viewModel.validatePassword(passwordCodeValid);

        expect(viewModel.canSubmit, false);
      });

      test('password is not set should return false', () {
        viewModel.validateUniversalCode(universalCodeValid);

        expect(viewModel.canSubmit, false);
      });
    });

    group('signIn - ', () {
      test('with right credentials should redirect to the Dashboard route',
          () async {
        UserRepositoryMock.stubAuthenticate(
            userRepositoryMock, universalCodeValid);

        viewModel.validateUniversalCode(universalCodeValid);
        viewModel.validatePassword(passwordCodeValid);

        await viewModel.authenticate();
        verify(
            navigationService.pushNamedAndRemoveUntil(RouterPaths.dashboard));
      });

      test(
          'universal code and/or password are not set, should return a error message',
          () async {
        viewModel.validateUniversalCode(universalCodeValid);

        expect(await viewModel.authenticate(), appIntl.error);
      });

      test('with wrong credentials should return a error message', () async {
        UserRepositoryMock.stubAuthenticate(userRepositoryMock, "AA11112",
            toReturn: false);

        viewModel.validateUniversalCode("AA11112");
        viewModel.validatePassword(passwordCodeValid);

        expect(await viewModel.authenticate(), appIntl.error);
        expect(viewModel.password, "");
      });
    });

    group('Emails - ', () {
      test('Has the right mailto', () {
        final str = viewModel.mailtoStr("email", "subject");

        expect(str, "mailto:{email}?subject={subject}");
      });
    });
  });
}
