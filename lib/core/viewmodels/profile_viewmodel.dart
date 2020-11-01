// FLUTTER / DART / THIRD-PARTIES
import 'package:notredame/core/models/profile_student.dart';
import 'package:notredame/core/models/program.dart';
import 'package:stacked/stacked.dart';

class ProfileViewModel extends BaseViewModel {
  List<Program> programsList = [
    Program(
        name: 'Bac',
        average: '3.01/4.30',
        status: 'Actif',
        code: '7425',
        completedCourses: '34',
        registeredCredits: '31',
        accumulatedCredits: '75',
        equivalentCourses: '0',
        failedCourses: '0'),
    Program(
        name: 'Stage',
        average: '3.01/4.30',
        status: 'Actif',
        code: '7425',
        completedCourses: '34',
        registeredCredits: '31',
        accumulatedCredits: '75',
        equivalentCourses: '0',
        failedCourses: '0')
  ];

  final profileStudent = ProfileStudent(
      balance: '12', firstName: 'John', lastName: 'Doe', permanentCode: 'DOEJ');
}
