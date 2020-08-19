import 'package:flutter/material.dart';
import 'package:notredame/generated/l10n.dart';

class EmergencyProcedures {
  String title;
  String detail;

  EmergencyProcedures({@required this.title, @required this.detail});
}

final List<EmergencyProcedures> emergencyProcedures = [
  EmergencyProcedures(
      title: AppIntl.current.security_bomb_threat_title,
      detail: 'assets/${AppIntl.current.security_bomb_threat_detail}'),
  EmergencyProcedures(
      title: AppIntl.current.security_suspicious_packages_title,
      detail: 'assets/${AppIntl.current.security_suspicious_packages_detail}'),
  EmergencyProcedures(
      title: AppIntl.current.security_evacuation_title,
      detail: 'assets/${AppIntl.current.security_evacuation_detail}'),
  EmergencyProcedures(
      title: AppIntl.current.security_gas_leak_title,
      detail: 'assets/${AppIntl.current.security_gas_leak_detail}'),
  EmergencyProcedures(
      title: AppIntl.current.security_fire_title,
      detail: 'assets/${AppIntl.current.security_fire_detail}'),
  EmergencyProcedures(
      title: AppIntl.current.security_broken_elevator_title,
      detail: 'assets/${AppIntl.current.security_broken_elevator_detail}'),
  EmergencyProcedures(
      title: AppIntl.current.security_electrical_outage_title,
      detail: 'assets/${AppIntl.current.security_electrical_outage_detail}'),
  EmergencyProcedures(
      title: AppIntl.current.security_armed_person_title,
      detail: 'assets/${AppIntl.current.security_armed_person_detail}'),
  EmergencyProcedures(
      title: AppIntl.current.security_earthquake_title,
      detail: 'assets/${AppIntl.current.security_earthquake_detail}'),
  EmergencyProcedures(
      title: AppIntl.current.security_medical_emergency_title,
      detail: 'assets/${AppIntl.current.security_medical_emergency_detail}'),
];
