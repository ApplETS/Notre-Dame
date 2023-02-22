import Foundation
import SwiftyXMLParser

public let courseActivityPath = ["soap:Envelope", "soap:Body", "lireHoraireDesSeancesResponse", "lireHoraireDesSeancesResult", "ListeDesSeances", "Seances"]
public let courseActivityErrorPath = ["soap:Envelope", "soap:Body", "lireHoraireDesSeancesResponse", "lireHoraireDesSeancesResult", "erreur"]

public class CourseActivity {
    /// Course acronym and group
    /// Presented like: acronym-group (ex: LOG430-02)
    let courseGroup: String?;

    /// Course name
    let courseName: String?;

    /// Activity name (ex: "Labo A")
    let activityName: String?;

    /// Description of the activity
    /// (ex: "Laboratoire (Groupe A)")
    let activityDescription: String?;

    /// Place where the activity is given
    let activityLocation: String?;

    /// Date when the activity start
    let startDateTime: String?;

    /// Date when the activity end
    let endDateTime: String?;
    
    public init(from xml: XML.Accessor) {
        self.courseGroup = xml.coursGroupe.text
        self.courseName = xml.libelleCours.text
        self.activityName = xml.nomActivite.text
        self.activityDescription = xml.descriptionActivite.text
        self.activityLocation = xml.local.text
        self.startDateTime = xml.dateDebut.text
        self.endDateTime = xml.dateFin.text
    }
}
