// Package imports:
import 'package:flutter_gen/gen_l10n/app_localizations.dart';
import 'package:fluttertoast/fluttertoast.dart';
import 'package:notredame/features/app/signets-api/models/profile_student.dart';
import 'package:notredame/features/app/signets-api/models/program.dart';
import 'package:stacked/stacked.dart';

// Project imports:
import 'package:notredame/features/app/analytics/analytics_service.dart';
import 'package:notredame/features/app/repository/user_repository.dart';
import 'package:notredame/features/student/profile/programs_credits.dart';
import 'package:notredame/utils/locator.dart';

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
      _userRepository.monETSUser?.universalCode ?? '';

  ProfileViewModel({required AppIntl intl}) : _appIntl = intl;

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
    if (_programList.isEmpty) {
      _programList = [];
    }
    if (_userRepository.programs != null) {
      _programList = _userRepository.programs!;
    }

    _programList.sort((a, b) => b.status.compareTo(a.status));
    _programList
        .sort((a, b) => a.registeredCredits.compareTo(b.registeredCredits));

    return _programList;
  }

  bool isLoadingEvents = false;

  @override
  Future<List<Program>> futureToRun() async {
    try {
      await _userRepository.getInfo(fromCacheOnly: true);
      await _userRepository.getPrograms(fromCacheOnly: true);

      setBusyForObject(isLoadingEvents, true);

      await _userRepository.getInfo();
      return await _userRepository.getPrograms();
    } catch (error) {
      onError(error);
    } finally {
      setBusyForObject(isLoadingEvents, false);
    }
    return _userRepository.programs ?? [];
  }

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
