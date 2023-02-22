import Foundation
import SwiftyXMLParser

public let coursePath = ["soap:Envelope", "soap:Body", "listeCoursResponse", "listeCoursResult", "liste", "Cours"]
public let courseErrorPath = ["soap:Envelope", "soap:Body", "listeCoursResponse", "listeCoursResult", "erreur"]

public struct Course {
    
    /// Course acronym (ex: LOG430)
    public let acronym: String?
    
    /// Title of the course (ex: Chimie et matériaux)
    let title: String?
    
    /// Course group, on which group the student is registered
    public let group: String?
    
    /// Session short name during which the course is given (ex: H2020)
    public let session: String?
    
    /// Code number of the program of which the course is a part of
    let programCode: String?
    
    /// Final grade of the course (ex: A+, C, ...) if the course doesn't
    /// have a the grade yet the variable will be null.
    let grade: String?
    
    /// Number of credits of the course
    let numberOfCredits: String?
    
    public init(from xml: XML.Accessor) {
        self.acronym = xml.sigle.text
        self.title = xml.titreCours.text
        self.group = xml.groupe.text
        self.session = xml.session.text
        self.programCode = xml.programmeEtudes.text
        self.grade = xml.cote.text
        self.numberOfCredits = xml.nbCredits.text
    }
}
