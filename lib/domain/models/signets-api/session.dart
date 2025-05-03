// ignore_for_file: invalid_annotation_target

import 'package:freezed_annotation/freezed_annotation.dart';

part 'session.freezed.dart';
part 'session.g.dart';

@freezed
abstract class Session with _$Session {
  // ignore: unused_element to create methods
  const Session._();

  const factory Session({
    /// Short name (like H2020)
    @JsonKey(name: 'abrege', )
    required String shortName,

    /// Complete name (like Hiver 2020)
    @JsonKey(name: 'auLong')
    required String longName,

    /// Start date
    @JsonKey(name: 'dateDebut')
    required DateTime startDate,

    /// End date
    @JsonKey(name: 'dateFin')
    required DateTime endDate,

    /// Courses end date
    @JsonKey(name: 'dateFinCours')
    required DateTime endDateCourses,

    /// Registration start
    @JsonKey(name: 'dateDebutChemiNot')
    required DateTime startDateRegistration,

    /// Registration end
    @JsonKey(name: 'dateFinChemiNot')
    required DateTime deadlineRegistration,

    /// Cancellation with refund start
    @JsonKey(name: 'dateDebutAnnulationAvecRemboursement')
    required DateTime startDateCancellationWithRefund,

    /// Cancellation with refund end
    @JsonKey(name: 'dateFinAnnulationAvecRemboursement')
    required DateTime deadlineCancellationWithRefund,

    /// Cancellation with refund end (new students)
    @JsonKey(name: 'dateFinAnnulationAvecRemboursementNouveauxEtudiants')
    required DateTime deadlineCancellationWithRefundNewStudent,

    /// Cancellation without refund start (new students)
    @JsonKey(name: 'dateDebutAnnulationSansRemboursementNouveauxEtudiants')
    required DateTime startDateCancellationWithoutRefundNewStudent,

    /// Cancellation without refund end (new students)
    @JsonKey(name: 'dateFinAnnulationSansRemboursementNouveauxEtudiants')
    required DateTime deadlineCancellationWithoutRefundNewStudent,

    /// ASEQ cancellation deadline
    @JsonKey(name: 'dateLimitePourAnnulerASEQ')
    required DateTime deadlineCancellationASEQ,
  }) = _Session;

  factory Session.fromJson(Map<String, dynamic> json) => _$SessionFromJson(json);

  int get daysCompleted => DateTime.now().difference(startDate).inDays;
  int get totalDays => endDate.difference(startDate).inDays;
}
