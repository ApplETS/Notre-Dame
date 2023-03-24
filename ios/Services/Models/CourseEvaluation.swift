import Foundation
import SwiftyXMLParser

public let courseEvaluationPath = ["liste", "ElementEvaluation"]

public class CourseEvaluation {
    let courseGroup: String?;

    /// Title of the evaluation (ex: Laboratoire 1)
    let title: String?;

    /// Date on which the evaluation should happen (can also be the date on which
    /// the mark was enter in the system)
    let targetDate: String?;

    /// Mark obtained by the student on the evaluation
    /// (ex: 24)
    let mark: String?;

    /// On how much the evaluation is corrected (ex: 30)
    let correctedEvaluationOutOfFormatted: String?;

    /// On how much the evaluation is corrected included bonus (ex: 30,0+20)
    let correctedEvaluationOutOf: String?;

    /// Weight of the evaluation on the course (ex: 12.5)
    let weight: String?;

    /// Average mark of the students on this evaluation (ex: 30)
    let passMark: String?;

    /// Standard deviation of the evaluation
    let standardDeviation: String?;

    /// Median of the evaluation
    let median: String?;

    /// Percentile rank of the student on this evaluation
    let percentileRank: String?;

    /// Is the mark of the evaluation published
    let published: Bool;

    /// Message given by the teacher
    let teacherMessage: String?;

    /// Is this evaluation ignored in the final grade
    let ignore: Bool;

    public init(from xml: XML.Accessor) {
        self.courseGroup = xml.coursGroupe.text
        self.title = xml.nom.text
        self.targetDate = xml.dateCible.text
        self.mark = xml.note.text
        self.correctedEvaluationOutOfFormatted = ""
        self.correctedEvaluationOutOf = xml.corrigeSur.text
        self.weight = xml.ponderation.text
        self.passMark = xml.moyenne.text
        self.standardDeviation = xml.ecartType.text
        self.median = xml.mediane.text
        self.percentileRank = xml.rangCentile.text
        self.published = xml.publie.text == "Oui"
        self.teacherMessage = xml.messageDuProf.text
        self.ignore = xml.ignoreDuCalcul.text == "Oui"
    }
}
