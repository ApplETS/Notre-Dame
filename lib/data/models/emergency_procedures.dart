// Project imports:
import 'package:notredame/data/models/emergency_procedure.dart';
import 'package:notredame/l10n/app_localizations.dart';

List<EmergencyProcedure> emergencyProcedures(AppIntl intl) => [
  EmergencyProcedure(
    title: intl.security_bomb_threat_title,
    detail: 'assets/markdown/${intl.security_bomb_threat_detail}',
  ),
  EmergencyProcedure(
    title: intl.security_suspicious_packages_title,
    detail: 'assets/markdown/${intl.security_suspicious_packages_detail}',
  ),
  EmergencyProcedure(
    title: intl.security_evacuation_title,
    detail: 'assets/markdown/${intl.security_evacuation_detail}',
  ),
  EmergencyProcedure(title: intl.security_gas_leak_title, detail: 'assets/markdown/${intl.security_gas_leak_detail}'),
  EmergencyProcedure(title: intl.security_fire_title, detail: 'assets/markdown/${intl.security_fire_detail}'),
  EmergencyProcedure(
    title: intl.security_broken_elevator_title,
    detail: 'assets/markdown/${intl.security_broken_elevator_detail}',
  ),
  EmergencyProcedure(
    title: intl.security_electrical_outage_title,
    detail: 'assets/markdown/${intl.security_electrical_outage_detail}',
  ),
  EmergencyProcedure(
    title: intl.security_armed_person_title,
    detail: 'assets/markdown/${intl.security_armed_person_detail}',
  ),
  EmergencyProcedure(
    title: intl.security_earthquake_title,
    detail: 'assets/markdown/${intl.security_earthquake_detail}',
  ),
  EmergencyProcedure(
    title: intl.security_medical_emergency_title,
    detail: 'assets/markdown/${intl.security_medical_emergency_detail}',
  ),
];
