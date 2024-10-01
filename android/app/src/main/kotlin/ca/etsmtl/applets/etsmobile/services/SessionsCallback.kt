package ca.etsmtl.applets.etsmobile.services

import ca.etsmtl.applets.etsmobile.services.models.Semester
import ca.etsmtl.applets.etsmobile.services.SoapRequestHelper.nodeToString
import ca.etsmtl.applets.etsmobile.services.models.ApiError
import okhttp3.Response
import okhttp3.Call
import okhttp3.Callback
import org.w3c.dom.Document
import org.w3c.dom.Element
import org.xml.sax.InputSource
import java.io.IOException
import java.io.StringReader
import javax.xml.parsers.DocumentBuilderFactory
import javax.xml.xpath.XPathConstants
import javax.xml.xpath.XPathFactory

class SessionsCallback(private val completion: (Result<List<Semester>>) -> Unit) : Callback {

    override fun onFailure(call: Call, e: IOException) {
        completion(Result.failure(ApiError(e.message ?: "Unknown error")))
    }

    override fun onResponse(call: Call, response: Response) {
        val data = response.body?.string()
        if (data != null) {
            val errorTextContent = getTextContentOfXmlTag(data, "erreur")

            if (!errorTextContent.isNullOrEmpty()) {
                completion(Result.failure(ApiError(errorTextContent)))
                return
            }

            val trimesterNodes = getTrimestersFromXml(data)
            if (trimesterNodes.isNotEmpty()) {
                val semesters = trimesterNodes.map { Semester.fromXml(it) }
                completion(Result.success(semesters))
            } else {
                completion(Result.failure(ApiError("No sessions found")))
            }
        } else {
            completion(Result.failure(ApiError("No data received")))
        }
    }

    private fun getTrimestersFromXml(xmlString: String): List<String> {
        val trimesters = mutableListOf<String>()

        try {
            val documentBuilder = DocumentBuilderFactory.newInstance().newDocumentBuilder()
            val inputSource = InputSource(StringReader(xmlString)).apply { encoding = "UTF-8" }
            val document: Document = documentBuilder.parse(inputSource)
            document.documentElement.normalize()

            val xpath = XPathFactory.newInstance().newXPath()
            val trimesterExpression = "//Trimestre"
            val nodeList = xpath.evaluate(trimesterExpression, document, XPathConstants.NODESET) as org.w3c.dom.NodeList

            for (i in 0 until nodeList.length) {
                val node = nodeList.item(i) as Element
                trimesters.add(nodeToString(node))
            }
        } catch (e: Exception) {
            e.printStackTrace()
        }

        return trimesters
    }

    private fun getTextContentOfXmlTag(xmlContent: String, tagName: String): String? {
        val factory = DocumentBuilderFactory.newInstance()
        val builder = factory.newDocumentBuilder()
        val inputStream = xmlContent.byteInputStream()
        val document: Document = builder.parse(inputStream)
        document.documentElement.normalize()

        val node = document.getElementsByTagName(tagName).item(0)
        return node?.textContent
    }
}
