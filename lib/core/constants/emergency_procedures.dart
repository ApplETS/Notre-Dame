import 'package:notredame/core/models/emergency_procedure.dart';
import 'package:notredame/generated/l10n.dart';

final List<EmergencyProcedure> emergencyProcedures = [
  EmergencyProcedure(
      title: AppIntl.current.security_bomb_threat_title,
      detail: 'assets/html/${AppIntl.current.security_bomb_threat_detail}'),
  EmergencyProcedure(
      title: AppIntl.current.security_suspicious_packages_title,
      detail:
          'assets/html/${AppIntl.current.security_suspicious_packages_detail}'),
  EmergencyProcedure(
      title: AppIntl.current.security_evacuation_title,
      detail: 'assets/html/${AppIntl.current.security_evacuation_detail}'),
  EmergencyProcedure(
      title: AppIntl.current.security_gas_leak_title,
      detail: 'assets/html/${AppIntl.current.security_gas_leak_detail}'),
  EmergencyProcedure(
      title: AppIntl.current.security_fire_title,
      detail: 'assets/html/${AppIntl.current.security_fire_detail}'),
  EmergencyProcedure(
      title: AppIntl.current.security_broken_elevator_title,
      detail: 'assets/html/${AppIntl.current.security_broken_elevator_detail}'),
  EmergencyProcedure(
      title: AppIntl.current.security_electrical_outage_title,
      detail:
          'assets/html/${AppIntl.current.security_electrical_outage_detail}'),
  EmergencyProcedure(
      title: AppIntl.current.security_armed_person_title,
      detail: 'assets/html/${AppIntl.current.security_armed_person_detail}'),
  EmergencyProcedure(
      title: AppIntl.current.security_earthquake_title,
      detail: 'assets/html/${AppIntl.current.security_earthquake_detail}'),
  EmergencyProcedure(
      title: AppIntl.current.security_medical_emergency_title,
      detail:
          'assets/html/${AppIntl.current.security_medical_emergency_detail}'),
];
