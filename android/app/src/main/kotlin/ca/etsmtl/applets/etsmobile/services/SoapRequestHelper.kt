package ca.etsmtl.applets.etsmobile.services

import ca.etsmtl.applets.etsmobile.services.models.MonETSUser
import org.xmlpull.v1.XmlPullParserFactory
import org.xmlpull.v1.XmlSerializer
import java.io.StringWriter

object SoapRequestHelper {
    fun getParameters(requestAction: String, user: MonETSUser, extraParams: Map<String, String>): String {
        val xmlSerializer = XmlPullParserFactory.newInstance().newSerializer()
        val writer = StringWriter()

        xmlSerializer.setOutput(writer)
        xmlSerializer.startDocument("UTF-8", true)
        xmlSerializer.startTag("", "soap:Envelope")
        xmlSerializer.attribute("", "xmlns:xsi", "http://www.w3.org/2001/XMLSchema-instance")
        xmlSerializer.attribute("", "xmlns:xsd", "http://www.w3.org/2001/XMLSchema")
        xmlSerializer.attribute("", "xmlns:soap", "http://schemas.xmlsoap.org/soap/envelope/")
        xmlSerializer.startTag("", "soap:Body")
        xmlSerializer.startTag("", requestAction)
        xmlSerializer.attribute("", "xmlns", "http://etsmtl.ca/")
        xmlSerializer.startTag("", "codeAccesUniversel")
        xmlSerializer.text(user.username)
        xmlSerializer.endTag("", "codeAccesUniversel")
        xmlSerializer.startTag("", "motPasse")
        xmlSerializer.text(user.password)
        xmlSerializer.endTag("", "motPasse")
        buildXmlForExtraParams(xmlSerializer, extraParams)
        xmlSerializer.endTag("", requestAction)
        xmlSerializer.endTag("", "soap:Body")
        xmlSerializer.endTag("", "soap:Envelope")
        xmlSerializer.endDocument()

        return writer.toString()
    }

    private fun buildXmlForExtraParams(xmlSerializer: XmlSerializer, extraParams: Map<String, String>) {
        for ((nodeName, nodeValue) in extraParams) {
            xmlSerializer.startTag("", nodeName)
            xmlSerializer.text(nodeValue)
            xmlSerializer.endTag("", nodeName)
        }
    }
}