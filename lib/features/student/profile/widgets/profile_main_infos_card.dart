import 'package:flutter/material.dart';
import 'package:notredame/features/student/profile/profile_viewmodel.dart';

Card getMainInfoCard(ProfileViewModel model) {
  var programName = "";
  if (model.programList.isNotEmpty) {
    programName = model.programList.last.name;
  }

  return Card(
    child: Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: <Widget>[
          Padding(
            padding: const EdgeInsets.all(5.0),
            child: Text(
              '${model.profileStudent.firstName} ${model.profileStudent.lastName}',
              style: const TextStyle(
                fontSize: 18,
                fontWeight: FontWeight.bold,
              ),
            ),
          ),
          Padding(
            padding: const EdgeInsets.all(10.0),
            child: Text(
              programName,
              style: const TextStyle(
                fontSize: 16,
              ),
            ),
          ),
        ],
      ),
    ),
  );
}
