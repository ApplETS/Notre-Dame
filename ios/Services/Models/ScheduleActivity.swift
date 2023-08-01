import Foundation
import SwiftyXMLParser

public let scheduleActivityPath = ["soap:Envelope", "soap:Body", "listeHoraireEtProfResponse", "listeHoraireEtProfResult", "listeActivites", "HoraireActivite"]
public let scheduleActivityErrorPath = ["soap:Envelope", "soap:Body", "listeHoraireEtProfResponse", "listeHoraireEtProfResult", "erreur"]

public class ScheduleActivity {
    // The course acronym (ex: "ABC123")
    let courseAcronym: String?;

    /// The group number of the activity (ex: "09")
    let courseGroup: String?;

    /// the location of the course
    let courseTitle: String?;

    /// The current day of the week (starting monday)
    /// for the ScheduleActivity (ex: 5 for friday)
    let dayOfTheWeek: String?;

    /// The current day of the week (ex: "Vendredi")
    let day: String?;

    /// Date when the activity start (no date part)
    let startTime: String?;

    /// Date when the activity end (no date part)
    let endTime: String?;

      //The code corresponding to the type of schedule activity
    let activityCode: String?;

    /// If the activity schedule is the main activity associated to the course (usually the )
    let isPrincipalActivity: Bool;

    /// the location of the activity
    let activityLocation: String?;

    /// the name of the activity
    let name: String?;

    public init(from xml: XML.Accessor) {
        self.courseAcronym = xml.sigle.text
        self.courseGroup = xml.groupe.text
        self.courseTitle = xml.titreCours.text
        self.dayOfTheWeek = xml.jour.text
        self.day = xml.journee.text
        self.startTime = xml.heureDebut.text
        self.endTime = xml.heureFin.text
        self.activityCode = xml.codeActivite.text
        self.isPrincipalActivity = xml.activitePrincipale.text == "Oui"
        self.activityLocation = xml.local.text
        self.name = xml.nomActivite.text
    }
}
