package ca.etsmtl.applets.etsmobile.services

import ca.etsmtl.applets.etsmobile.Constants
import ca.etsmtl.applets.etsmobile.services.models.MonETSUser
import ca.etsmtl.applets.etsmobile.services.models.ApiError
import ca.etsmtl.applets.etsmobile.services.models.Semester
import okhttp3.*
import okhttp3.MediaType.Companion.toMediaTypeOrNull
import okhttp3.RequestBody.Companion.toRequestBody
import org.w3c.dom.Document
import org.w3c.dom.Element
import org.xml.sax.InputSource
import java.io.ByteArrayInputStream
import java.io.IOException
import java.io.StringReader
import java.io.StringWriter
import java.util.concurrent.TimeUnit
import javax.xml.parsers.DocumentBuilderFactory
import javax.xml.transform.OutputKeys
import javax.xml.transform.TransformerFactory
import javax.xml.transform.dom.DOMSource
import javax.xml.transform.stream.StreamResult
import javax.xml.xpath.XPathConstants
import javax.xml.xpath.XPathFactory

class SignetsService private constructor(): SignetsServiceProtocol {

    companion object {
        val shared = SignetsService()
    }

    private val baseURL = Constants.SIGNETS_API
    private val client = OkHttpClient.Builder()
        .connectTimeout(60, TimeUnit.SECONDS)
        .writeTimeout(60, TimeUnit.SECONDS)
        .readTimeout(60, TimeUnit.SECONDS)
        .build()

    private fun createRequest(soapAction: String, user: MonETSUser, extraParams: Map<String, String>): Request {
        val postData = SoapRequestHelper.getParameters(soapAction, user, extraParams)
        return Request.Builder()
            .url(baseURL)
            .post(postData.toRequestBody("text/xml".toMediaTypeOrNull()))
            .addHeader("Content-Type", "text/xml")
            .addHeader("SOAPAction", "http://etsmtl.ca/$soapAction")
            .build()
    }

    override fun getSessions(user: MonETSUser, completion: (Result<List<Semester>>) -> Unit) {
        val request = createRequest(Constants.LIST_SESSIONS_OPERATION, user, emptyMap())

        client.newCall(request).enqueue(object : Callback {
            override fun onFailure(call: Call, e: IOException) {
                completion(Result.failure(ApiError(e.message ?: "Unknown error")))
            }

            override fun onResponse(call: Call, response: Response) {
                val data = response.body?.string()
                if (data != null) {
                    val errorTextContent = getTextContentOfXmlTag(data, "erreur")

                    if (!errorTextContent.isNullOrEmpty()){
                        completion(Result.failure(ApiError(errorTextContent)))
                    }

                    val trimesterNodes = getTrimestersFromXml(data)
                    if (trimesterNodes.isNotEmpty()){
                        val semesters = trimesterNodes.map { Semester.fromXml(it) }
                        completion(Result.success(semesters))
                    } else {
                        completion(Result.failure(ApiError("No sessions found")))
                    }
                }
            }
        })
    }

    fun parseXML(xml: String): Document {
        val factory = DocumentBuilderFactory.newInstance()
        factory.isNamespaceAware = false
        val builder = factory.newDocumentBuilder()
        return builder.parse(ByteArrayInputStream(xml.toByteArray()))
    }

    fun getTrimestersFromXml(xmlString: String): List<String> {
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

    private fun nodeToString(node: Element): String {
        val transformer = TransformerFactory.newInstance().newTransformer()
        transformer.setOutputProperty(OutputKeys.OMIT_XML_DECLARATION, "yes")
        transformer.setOutputProperty(OutputKeys.INDENT, "yes")
        transformer.setOutputProperty(OutputKeys.ENCODING, "UTF-8")
        val writer = StringWriter()
        transformer.transform(DOMSource(node), StreamResult(writer))
        return writer.toString().trim()
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