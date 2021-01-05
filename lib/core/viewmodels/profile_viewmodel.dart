// FLUTTER / DART / THIRD-PARTIES
import 'package:notredame/core/managers/profile_repository.dart';
import 'package:notredame/core/models/profile_student.dart';
import 'package:notredame/core/models/program.dart';
import 'package:stacked/stacked.dart';

import '../../locator.dart';

class ProfileViewModel extends FutureViewModel<List<Program>> {
  final ProfileRepository _profileRepository = locator<ProfileRepository>();

  List<Program> _programList = List.empty();
  final ProfileStudent _student = ProfileStudent(
      balance: "", firstName: "", lastName: "", permanentCode: "", men: "");

  ProfileStudent get profileStudent {
    return _profileRepository.info ?? _student;
  }

  List<Program> get programsList {
    if (_programList == null || _programList.isEmpty) {
      _programList = [];
    }
    if (_profileRepository.programs != null) {
      for (final Program program in _profileRepository.programs) {
        _programList.add(program);
      }
    }
    return _programList;
  }

  @override
  Future<List<Program>> futureToRun() {
    return _profileRepository
        .getInfos()
        .then((value) => _profileRepository.getPrograms());
  }
}
