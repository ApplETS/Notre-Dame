import Foundation
import SwiftyXMLParser

public let sessionPath = ["soap:Envelope", "soap:Body", "listeSessionsResponse", "listeSessionsResult", "liste", "Trimestre"]
public let sessionErrorPath = ["soap:Envelope", "soap:Body", "listeSessionsResponse", "listeSessionsResult", "erreur"]

public class Session {
    /// Short name of the session (like H2020)
    public let shortName: String?;

    /// Complete name of the session (like Hiver 2020)
    let name: String?;

    /// Start date of the session, date when the first course is given
    let startDate: String?;

    /// End date of the session
    let endDate: String?;

    /// End date of the courses for this session, date when the last course is given
    let endDateCourses: String?;

    /// Date when the registration for the session start.
    let startDateRegistration: String?;

    /// Date when the registration for the session end.
    let deadlineRegistration: String?;

    /// Date when the cancellation of a course with refund start
    let startDateCancellationWithRefund: String?;

    /// Date when the cancellation of a course with refund end
    let deadlineCancellationWithRefund: String?;

    /// Date when the cancellation of a course with refund end for the new students
    let deadlineCancellationWithRefundNewStudent: String?;

    /// Date when the cancellation of a course without refund start for the new students
    let startDateCancellationWithoutRefundNewStudent: String?;

    /// Date when the cancellation of a course without refund end for the new students
    let deadlineCancellationWithoutRefundNewStudent: String?;

    /// Date when the cancellation of the ASEQ end.
    let deadlineCancellationASEQ: String?;
    
    public init(from xml: XML.Accessor) {
        self.shortName = xml.abrege.text
        self.name = xml.auLong.text
        self.startDate = xml.dateDebut.text
        self.endDate = xml.dateFin.text
        self.endDateCourses = xml.dateFinCours.text
        self.startDateRegistration = xml.dateDebutChemiNot.text
        self.deadlineRegistration = xml.dateFinChemiNot.text
        self.startDateCancellationWithRefund = xml.dateDebutAnnulationAvecRemboursement.text
        self.deadlineCancellationWithRefund = xml.dateFinAnnulationAvecRemboursement.text
        self.deadlineCancellationWithRefundNewStudent = xml.dateFinAnnulationAvecRemboursementNouveauxEtudiants.text
        self.startDateCancellationWithoutRefundNewStudent = xml.dateDebutAnnulationSansRemboursementNouveauxEtudiants.text
        self.deadlineCancellationWithoutRefundNewStudent = xml.dateFinAnnulationSansRemboursementNouveauxEtudiants.text
        self.deadlineCancellationASEQ = xml.dateLimitePourAnnulerASEQ.text
    }
}
