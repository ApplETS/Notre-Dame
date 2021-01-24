// FLUTTER / DART / THIRD-PARTIES
import 'package:oktoast/oktoast.dart';
import 'package:stacked/stacked.dart';

// MANAGERS
import 'package:notredame/core/managers/user_repository.dart';

// MODELS
import 'package:notredame/core/models/profile_student.dart';
import 'package:notredame/core/models/program.dart';

// OTHERS
import 'package:notredame/generated/l10n.dart';
import '../../locator.dart';

class ProfileViewModel extends FutureViewModel<List<Program>> {
  final UserRepository _userRepository = locator<UserRepository>();

  List<Program> _programList = List.empty();
  final ProfileStudent _student = ProfileStudent(
      balance: "", firstName: "", lastName: "", permanentCode: "");

  ProfileStudent get profileStudent {
    return _userRepository.info ?? _student;
  }

  String get universalAccessCode =>
      _userRepository?.monETSUser?.universalCode ?? '';

  @override
  // ignore: type_annotate_public_apis
  void onError(error) {
    showToast(AppIntl.current.error);
  }

  List<Program> get programList {
    if (_programList == null || _programList.isEmpty) {
      _programList = [];
    }
    if (_userRepository.programs != null) {
      _programList = _userRepository.programs;
    }
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
            .catchError(onError)
            .then((value) => _userRepository.getPrograms().catchError(onError))
            .whenComplete(() => setBusyForObject(isLoadingEvents, false));
        return value;
      });
}
