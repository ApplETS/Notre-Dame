package ca.etsmtl.applets.etsmobile.services

import ca.etsmtl.applets.etsmobile.Constants
import ca.etsmtl.applets.etsmobile.services.models.MonETSUser
import ca.etsmtl.applets.etsmobile.services.models.Semester
import okhttp3.*
import okhttp3.MediaType.Companion.toMediaTypeOrNull
import okhttp3.RequestBody.Companion.toRequestBody
import java.util.concurrent.TimeUnit

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
        client.newCall(request).enqueue(SessionsCallback(completion))
    }
}