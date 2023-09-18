// FLUTTER / DART / THIRD-PARTIES
import 'package:fluttertoast/fluttertoast.dart';
import 'package:stacked/stacked.dart';
import 'package:flutter/material.dart';
import 'package:flutter_gen/gen_l10n/app_localizations.dart';

// SERVICES
import 'package:notredame/core/services/analytics_service.dart';

// MANAGERS
import 'package:notredame/core/managers/user_repository.dart';

// MODELS
import 'package:ets_api_clients/models.dart';

// CONSTANTS
import 'package:notredame/core/constants/programs_credits.dart';

// OTHERS
import 'package:notredame/locator.dart';

class ProfileViewModel extends FutureViewModel<List<Program>> {
  /// Load the user
  final UserRepository _userRepository = locator<UserRepository>();

  final AnalyticsService analyticsService = locator<AnalyticsService>();

  /// Localization class of the application.
  final AppIntl _appIntl;

  /// List of the programs
  List<Program> _programList = List.empty();

  /// Student's profile
  final ProfileStudent _student = ProfileStudent(
      balance: "", firstName: "", lastName: "", permanentCode: "");

  /// Return the profileStudent
  ProfileStudent get profileStudent {
    return _userRepository.info ?? _student;
  }

  /// Return the universal access code of the student
  String get universalAccessCode =>
      _userRepository?.monETSUser?.universalCode ?? '';

  ProfileViewModel({@required AppIntl intl}) : _appIntl = intl;

  double get programProgression {
    final ProgramCredits programCredits = ProgramCredits();
    int percentage = 0;

    if (programList.isNotEmpty) {
      Program currentProgram = programList.first;
      for (final program in programList) {
        if (int.parse(program.registeredCredits) >
            int.parse(currentProgram.registeredCredits)) {
          currentProgram = program;
        }
      }
      final int numberOfCreditsCompleted =
          int.parse(currentProgram.accumulatedCredits);
      final String code = currentProgram.code;
      bool foundMatch = false;

      programCredits.programsCredits.forEach((key, value) {
        if (key == code || currentProgram.name.startsWith(key)) {
          percentage = (numberOfCreditsCompleted / value * 100).round();
          foundMatch = true;
        }
      });

      if (!foundMatch) {
        final String programName = currentProgram.name;
        analyticsService.logEvent("profile_view",
            'The program $programName (code: $code) does not match any program');
        percentage = 0;
      }
    }

    return percentage.toDouble();
  }

  @override
  // ignore: type_annotate_public_apis
  void onError(error) {
    Fluttertoast.showToast(msg: _appIntl.error);
  }

  /// Return the list of programs for the student
  List<Program> get programList {
    if (_programList == null || _programList.isEmpty) {
      _programList = [];
    }
    if (_userRepository.programs != null) {
      _programList = _userRepository.programs;
    }

    _programList.sort((a, b) => b.status.compareTo(a.status));

    return _programList;
  }

  bool isLoadingEvents = false;

  @override
  Future<List<Program>> futureToRun() => _userRepository
          .getInfo(fromCacheOnly: true)
          .then((value) => _userRepository.getPrograms(fromCacheOnly: true))
          .then((value) {
        setBusyForObject(isLoadingEvents, true);
        _userRepository
            .getInfo()
            // ignore: return_type_invalid_for_catch_error
            .catchError(onError)
            // ignore: return_type_invalid_for_catch_error
            .then((value) => _userRepository.getPrograms().catchError(onError))
            .whenComplete(() {
          setBusyForObject(isLoadingEvents, false);
        });
        return value;
      });

  Future refresh() async {
    try {
      setBusyForObject(isLoadingEvents, true);
      _userRepository
          .getInfo()
          .then((value) => _userRepository.getPrograms().then((value) {
                setBusyForObject(isLoadingEvents, false);
                notifyListeners();
              }));
    } on Exception catch (error) {
      onError(error);
    }
  }
}
