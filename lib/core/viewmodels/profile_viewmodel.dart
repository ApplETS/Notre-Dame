// FLUTTER / DART / THIRD-PARTIES
import 'package:notredame/core/managers/user_repository.dart';
import 'package:notredame/core/models/profile_student.dart';
import 'package:notredame/core/models/program.dart';
import 'package:stacked/stacked.dart';

import '../../locator.dart';

class ProfileViewModel extends FutureViewModel<List<Program>> {
  final UserRepository _userRepository = locator<UserRepository>();

  List<Program> _programList = List.empty();
  final ProfileStudent _student = ProfileStudent(
      balance: "", firstName: "", lastName: "", permanentCode: "");

  ProfileStudent get profileStudent {
    return _userRepository.info ?? _student;
  }

  Future<List<Program>> getProgramsList() async {
    if (_programList == null || _programList.isEmpty) {
      _programList = [];
    }
    if (_userRepository.programs != null) {
      for (final Program program in _userRepository.programs) {
        _programList.add(program);
      }
    }
    return _programList;
  }

  @override
  Future<List<Program>> futureToRun() {
    return _userRepository
        .getInfo()
        .then((value) => _userRepository.getPrograms());
  }
}
