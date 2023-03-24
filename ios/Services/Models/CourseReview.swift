import Foundation
import SwiftyXMLParser

public let courseReviewPath = ["soap:Envelope", "soap:Body", "lireEvaluationCoursResponse", "lireEvaluationCoursResult", "listeEvaluations", "EvaluationCours"]
public let courseReviewErrorPath = ["soap:Envelope", "soap:Body", "lireEvaluationCoursResponse", "lireEvaluationCoursResult", "erreur"]

public class CourseReview {
    /// Course acronym (ex: LOG430)
    let acronym: String?;

    /// Course group, on which group the student is registered
    let group: String?;

    /// Name of the professor
    let teacherName: String?;

    /// Date when the evaluation start.
    let startAt: String?;

    /// When the evaluation end.
    let endAt: String?;

    /// Type of the evaluation
    let type: String?;

    /// Is the evaluation completed
    let isCompleted: String?;

    public init(from xml: XML.Accessor) {
        self.acronym = xml.Sigle.text
        self.group = xml.Groupe.text
        self.teacherName = xml.Enseignant.text
        self.startAt = xml.DateDebutEvaluation.text
        self.endAt = xml.DateFinEvaluation.text
        self.type = xml.TypeEvaluation.text
        self.isCompleted = xml.EstComplete.text
    }
}
