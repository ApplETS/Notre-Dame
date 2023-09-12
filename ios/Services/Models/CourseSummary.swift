import Foundation
import SwiftyXMLParser

public let courseSummaryPath = ["soap:Envelope", "soap:Body", "listeElementsEvaluationResponse", "listeElementsEvaluationResult"]
public let courseSummaryErrorPath = ["soap:Envelope", "soap:Body", "listeElementsEvaluationResponse", "listeElementsEvaluationResult", "erreur"]

public class CourseSummary {
    /// Mark obtained by the student.
    /// (ex: 24)
    let currentMark: String?;

    /// Mark obtained by the student in percent.
    /// (ex: 24)
    let currentMarkInPercent: String?;

    /// On how much the course is actually corrected (ex: 30)
    /// Sum of all the evaluations weight already published.
    let markOutOf: String?;

    /// Average mark of the class (ex: 30)
    let passMark: String?;

    /// Standard deviation of the class
    let standardDeviation: String?;

    /// Median of the class
    let median: String?;

    /// Percentile rank of the student on this course
    let percentileRank: String?;

    /// All the evaluations for this courses.
    let evaluations: [CourseEvaluation];

    public init(from xml: XML.Accessor) {
        self.currentMark = xml.scoreFinalSur100.text
        self.currentMarkInPercent = xml.noteACeJour.text
        self.markOutOf = xml.tauxPublication.text
        self.passMark = xml.moyenneClasse.text
        self.standardDeviation = xml.ecartTypeClasse.text
        self.median = xml.medianeClasse.text
        self.percentileRank = xml.rangCentileClasse.text
        self.evaluations = xml[courseEvaluationPath].map { CourseEvaluation(from: $0) }
    }
}
