import Foundation
import SwiftyXMLParser

public let programPath = ["soap:Envelope", "soap:Body", "listeProgrammesResponse", "listeProgrammesResult", "liste", "Programme"]
public let programErrorPath = ["soap:Envelope", "soap:Body", "listeProgrammesResponse", "listeProgrammesResult", "erreur"]

public class Program {
    /// Name of the program
    let name: String?;

    /// Code of the program (ex: 0725)
    let code: String?;

    /// Average grade of the program (x.xx / 4.30)
    let average: String?;

    /// Number of accumulated credits for the program
    let accumulatedCredits: String?;

    /// Number of registered credits for the program
    let registeredCredits: String?;

    /// Number of completed courses for the program
    let completedCourses: String?;

    /// Number of failed courses for the program
    let failedCourses: String?;

    /// Number of equivalent courses for the program
    let equivalentCourses: String?;

    /// Status of the program (Actif, Diplome)
    let status: Bool?;

    public init(from xml: XML.Accessor) {
        self.name = xml.libelle.text
        self.code = xml.code.text
        self.average = xml.moyenne.text
        self.accumulatedCredits = xml.nbCreditsCompletes.text
        self.registeredCredits = xml.nbCreditsInscrits.text
        self.completedCourses = xml.nbCrsReussis.text
        self.failedCourses = xml.nbCrsEchoues.text
        self.equivalentCourses = xml.nbEquivalences.text
        self.status = xml.statut.text == "actif"
    }
}
