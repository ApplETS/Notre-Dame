package ca.etsmtl.applets.etsmobile.services

import okhttp3.*
import java.io.IOException
import com.google.gson.Gson
import java.util.concurrent.TimeUnit
import ca.etsmtl.applets.etsmobile.services.models.MonETSUser
import okhttp3.MediaType.Companion.toMediaTypeOrNull
import okhttp3.RequestBody.Companion.toRequestBody

class MonETSClient private constructor() {
//    enum class MonETSError : Exception() {
//        MALFORMED_JSON
//    }

    private val baseURL = "https://monEtsAPI/authentification"
    private val client = OkHttpClient.Builder()
        .connectTimeout(60, TimeUnit.SECONDS)
        .writeTimeout(60, TimeUnit.SECONDS)
        .readTimeout(60, TimeUnit.SECONDS)
        .build()
    private val gson = Gson()

    companion object {
        val shared = MonETSClient()
    }

    fun authenticate(user: MonETSUser) {
        val postData = gson.toJson(user).toRequestBody("application/json".toMediaTypeOrNull())

        val request = Request.Builder()
            .url(baseURL)
            .post(postData)
            .addHeader("Content-Type", "application/json")
            .build()

        client.newCall(request).enqueue(object : Callback {
            override fun onFailure(call: Call, e: IOException) {
                println(e.message)
            }

            override fun onResponse(call: Call, response: Response) {
                response.use {
                    if (!it.isSuccessful) throw IOException("Unexpected code $response")

                    println(it.body?.string())
                }
            }
        })
    }
}