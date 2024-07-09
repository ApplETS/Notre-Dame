package ca.etsmtl.applets.etsmobile.services.models

import org.xmlpull.v1.XmlPullParser
import org.xmlpull.v1.XmlPullParserFactory
import java.io.StringReader

val sessionPath = listOf("soap:Envelope", "soap:Body", "listeSessionsResponse", "listeSessionsResult", "liste", "Trimestre")
val sessionErrorPath = listOf("soap:Envelope", "soap:Body", "listeSessionsResponse", "listeSessionsResult", "erreur")

data class Session(
    val shortName: String?,
    val name: String?,
    val startDate: String?,
    val endDate: String?,
    val endDateCourses: String?,
    val startDateRegistration: String?,
    val deadlineRegistration: String?,
    val startDateCancellationWithRefund: String?,
    val deadlineCancellationWithRefund: String?,
    val deadlineCancellationWithRefundNewStudent: String?,
    val startDateCancellationWithoutRefundNewStudent: String?,
    val deadlineCancellationWithoutRefundNewStudent: String?,
    val deadlineCancellationASEQ: String?
) {
    companion object {
        fun fromXml(xml: String): Session {
            val factory = XmlPullParserFactory.newInstance()
            factory.isNamespaceAware = true
            val parser = factory.newPullParser()
            parser.setInput(StringReader(xml))

            var eventType = parser.eventType
            var currentTag: String? = null
            var shortName: String? = null
            var name: String? = null
            var startDate: String? = null
            var endDate: String? = null
            var endDateCourses: String? = null
            var startDateRegistration: String? = null
            var deadlineRegistration: String? = null
            var startDateCancellationWithRefund: String? = null
            var deadlineCancellationWithRefund: String? = null
            var deadlineCancellationWithRefundNewStudent: String? = null
            var startDateCancellationWithoutRefundNewStudent: String? = null
            var deadlineCancellationWithoutRefundNewStudent: String? = null
            var deadlineCancellationASEQ: String? = null

            while (eventType != XmlPullParser.END_DOCUMENT) {
                when (eventType) {
                    XmlPullParser.START_TAG -> {
                        currentTag = parser.name
                    }
                    XmlPullParser.TEXT -> {
                        when (currentTag) {
                            "abrege" -> shortName = parser.text
                            "auLong" -> name = parser.text
                            "dateDebut" -> startDate = parser.text
                            "dateFin" -> endDate = parser.text
                            "dateFinCours" -> endDateCourses = parser.text
                            "dateDebutChemiNot" -> startDateRegistration = parser.text
                            "dateFinChemiNot" -> deadlineRegistration = parser.text
                            "dateDebutAnnulationAvecRemboursement" -> startDateCancellationWithRefund = parser.text
                            "dateFinAnnulationAvecRemboursement" -> deadlineCancellationWithRefund = parser.text
                            "dateFinAnnulationAvecRemboursementNouveauxEtudiants" -> deadlineCancellationWithRefundNewStudent = parser.text
                            "dateDebutAnnulationSansRemboursementNouveauxEtudiants" -> startDateCancellationWithoutRefundNewStudent = parser.text
                            "dateFinAnnulationSansRemboursementNouveauxEtudiants" -> deadlineCancellationWithoutRefundNewStudent = parser.text
                            "dateLimitePourAnnulerASEQ" -> deadlineCancellationASEQ = parser.text
                        }
                    }
                    XmlPullParser.END_TAG -> {
                        currentTag = null
                    }
                }
                eventType = parser.next()
            }

            return Session(
                shortName,
                name,
                startDate,
                endDate,
                endDateCourses,
                startDateRegistration,
                deadlineRegistration,
                startDateCancellationWithRefund,
                deadlineCancellationWithRefund,
                deadlineCancellationWithRefundNewStudent,
                startDateCancellationWithoutRefundNewStudent,
                deadlineCancellationWithoutRefundNewStudent,
                deadlineCancellationASEQ
            )
        }
    }
}