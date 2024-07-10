package ca.etsmtl.applets.etsmobile.services

import android.util.Log
import ca.etsmtl.applets.etsmobile.Constants
import ca.etsmtl.applets.etsmobile.services.models.MonETSUser
import ca.etsmtl.applets.etsmobile.services.models.ApiError
import ca.etsmtl.applets.etsmobile.services.models.Session
import ca.etsmtl.applets.etsmobile.services.models.sessionErrorPath
import ca.etsmtl.applets.etsmobile.services.models.sessionPath
import okhttp3.*
import okhttp3.MediaType.Companion.toMediaTypeOrNull
import okhttp3.RequestBody.Companion.toRequestBody
import org.w3c.dom.Document
import org.w3c.dom.Element
import org.w3c.dom.Node
import org.w3c.dom.NodeList
import java.io.ByteArrayInputStream
import java.io.IOException
import java.io.StringWriter
import java.util.concurrent.TimeUnit
import javax.xml.namespace.NamespaceContext
import javax.xml.parsers.DocumentBuilderFactory
import javax.xml.transform.OutputKeys
import javax.xml.transform.TransformerFactory
import javax.xml.transform.dom.DOMSource
import javax.xml.transform.stream.StreamResult
import javax.xml.xpath.XPath
import javax.xml.xpath.XPathConstants
import javax.xml.xpath.XPathExpressionException
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

    override fun getSessions(user: MonETSUser, completion: (Result<List<Session>>) -> Unit) {
        val request = createRequest(Constants.LIST_SESSIONS_OPERATION, user, emptyMap())

        client.newCall(request).enqueue(object : Callback {
            override fun onFailure(call: Call, e: IOException) {
                completion(Result.failure(ApiError(e.message ?: "Unknown error")))
            }

            override fun onResponse(call: Call, response: Response) {
                val data = response.body?.string()
                if (data != null) {
                    val xml = parseXML(data)

                    val errorNode = getNodeAsString(xml, sessionErrorPath)
                    val trimesterNodes = getNodesByPath(xml, sessionPath)

                    Log.d("SignetsService", "errorNode: $errorNode")
                    Log.d("SignetsService", "trimesterNodes length: ${trimesterNodes.length}")

                    for (i in 0 until trimesterNodes.length){
                        val trimesterNode = trimesterNodes.item(i)
                        val shortName = getNodeByPath(trimesterNode as Document, "abrege")?.textContent
                        Log.d("SignetsService", "shortName: $shortName")
                    }
                    completion(Result.success(emptyList()))

//                    if (sessionsXml != null) {
//                        val sessions = sessionsXml.map { Session.fromXml(it) }
//                        for (session in sessions) {
//                            Log.d("SignetsService", "session: " + session.shortName)
//                        }
//                        Log.d("SignetsService", "sessions: $sessions")
//                        completion(Result.success(sessions))
//                    }
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

    fun getNodeAsString(document: Document, path: String): String? {
        val node = getNodeByPath(document, path)
        return node?.let { nodeToString(it) }
    }

    fun getNodeByPath(node: Node, path: String): Node? {
        val xPath = createXPath()
        return try {
            xPath.evaluate(path, node, XPathConstants.NODE) as Node?
        } catch (e: XPathExpressionException) {
            e.printStackTrace()
            null
        }
    }

    fun getNodesByPath(node: Node, path: String): NodeList {
        val xPath = createXPath()
        return try {
            xPath.evaluate(path, node, XPathConstants.NODESET) as NodeList
        } catch (e: XPathExpressionException) {
            e.printStackTrace()
            createEmptyNodeList()
        }
    }

    fun createXPath(): XPath {
        val xPath = XPathFactory.newInstance().newXPath()
        xPath.namespaceContext = object : NamespaceContext {
            override fun getNamespaceURI(prefix: String): String {
                return when (prefix) {
                    "soap" -> "http://schemas.xmlsoap.org/soap/envelope/"
                    "xsi" -> "http://www.w3.org/2001/XMLSchema-instance"
                    "xsd" -> "http://www.w3.org/2001/XMLSchema"
                    "" -> "http://etsmtl.ca/"  // default namespace
                    else -> ""
                }
            }

            override fun getPrefix(namespaceURI: String): String? {
                return null
            }

            override fun getPrefixes(namespaceURI: String): Iterator<String>? {
                return null
            }
        }
        return xPath
    }

    fun nodeToString(node: Node): String {
        val transformerFactory = TransformerFactory.newInstance()
        val transformer = transformerFactory.newTransformer()
        transformer.setOutputProperty(OutputKeys.OMIT_XML_DECLARATION, "yes")
        transformer.setOutputProperty(OutputKeys.INDENT, "yes")
        val source = DOMSource(node)
        val writer = StringWriter()
        val result = StreamResult(writer)
        transformer.transform(source, result)
        return writer.toString()
    }

    fun createEmptyNodeList(): NodeList {
        return object : NodeList {
            override fun getLength(): Int {
                return 0
            }

            override fun item(index: Int): Node? {
                return null
            }
        }
    }
}