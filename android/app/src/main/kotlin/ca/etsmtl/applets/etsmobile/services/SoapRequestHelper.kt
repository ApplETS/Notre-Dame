package ca.etsmtl.applets.etsmobile.services

import ca.etsmtl.applets.etsmobile.services.models.MonETSUser
import org.w3c.dom.Document
import org.w3c.dom.Element
import org.xmlpull.v1.XmlPullParserFactory
import org.xmlpull.v1.XmlSerializer
import java.io.ByteArrayInputStream
import java.io.StringWriter
import javax.xml.parsers.DocumentBuilderFactory
import javax.xml.transform.OutputKeys
import javax.xml.transform.TransformerFactory
import javax.xml.transform.dom.DOMSource
import javax.xml.transform.stream.StreamResult

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

    fun nodeToString(node: Element): String {
        val transformer = TransformerFactory.newInstance().newTransformer()
        transformer.setOutputProperty(OutputKeys.OMIT_XML_DECLARATION, "yes")
        transformer.setOutputProperty(OutputKeys.INDENT, "yes")
        transformer.setOutputProperty(OutputKeys.ENCODING, "UTF-8")
        val writer = StringWriter()
        transformer.transform(DOMSource(node), StreamResult(writer))
        return writer.toString().trim()
    }

    fun parseXML(xml: String): Document {
        val factory = DocumentBuilderFactory.newInstance()
        factory.isNamespaceAware = false
        val builder = factory.newDocumentBuilder()
        return builder.parse(ByteArrayInputStream(xml.toByteArray()))
    }
}