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
import org.xmlpull.v1.XmlPullParser
import org.xmlpull.v1.XmlPullParserFactory
import java.io.IOException
import java.io.StringReader
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

    override fun getSessions(user: MonETSUser, completion: (Result<List<Session>>) -> Unit) {
        val request = createRequest(Constants.LIST_SESSIONS_OPERATION, user, emptyMap())

        client.newCall(request).enqueue(object : Callback {
            override fun onFailure(call: Call, e: IOException) {
                completion(Result.failure(ApiError(e.message ?: "Unknown error")))
            }

            override fun onResponse(call: Call, response: Response) {
                val data = response.body?.string()
                Log.d("SignetsService", "getSessions onResponse data: $data")
                if (data != null) {
                    val xml = parseXml(data)
                    Log.d("SignetsService", "parsed data: $data")
                    val error = xml[sessionErrorPath]
                    if (error != null) {
                        Log.d("SignetsService", "error: $error")
                        completion(Result.failure(ApiError(error)))
                    } else {
                        val sessionsXml = xml[sessionPath]
                        if (sessionsXml != null){
                            val sessions = sessionsXml.map { Session.fromXml(it.toString()) }
                            Log.d("SignetsService", "sessions: $sessions")
                            completion(Result.success(sessions))
                        }else{
                            println("sessionsXml is null")
                        }
                    }
                }
            }
        })
    }

//    override fun getStudentInfo(user: ca.etsmtl.applets.etsmobile.services.models.MonETSUser, completion: (Result<ProfileStudent, ApiError>) -> Unit) {
//        val request = createRequest("infoEtudiant", user, emptyMap())
//
//        client.newCall(request).enqueue(object : Callback {
//            override fun onFailure(call: Call, e: IOException) {
//                completion(Result.failure(ApiError(e.message ?: "Unknown error")))
//            }
//
//            override fun onResponse(call: Call, response: Response) {
//                val data = response.body?.string()
//                if (data != null) {
//                    val xml = parseXml(data)
//                    val error = xml[studentInfoErrorPath]
//                    if (error != null) {
//                        completion(Result.failure(ApiError(error)))
//                    } else {
//                        val studentInfo = xml[studentInfoPath]
//                        val info = ProfileStudent.fromXml(studentInfo)
//                        completion(Result.success(info))
//                    }
//                }
//            }
//        })
//    }
//
//    override fun getCourses(user: ca.etsmtl.applets.etsmobile.services.models.MonETSUser, completion: (Result<List<Course>, ApiError>) -> Unit) {
//        val request = createRequest("listeCours", user, emptyMap())
//
//        client.newCall(request).enqueue(object : Callback {
//            override fun onFailure(call: Call, e: IOException) {
//                completion(Result.failure(ApiError(e.message ?: "Unknown error")))
//            }
//
//            override fun onResponse(call: Call, response: Response) {
//                val data = response.body?.string()
//                if (data != null) {
//                    val xml = parseXml(data)
//                    val error = xml[courseErrorPath]
//                    if (error != null) {
//                        completion(Result.failure(ApiError(error)))
//                    } else {
//                        val coursesXml = xml[coursePath]
//                        val courses = coursesXml.map { Course.fromXml(it) }
//                        completion(Result.success(courses))
//                    }
//                }
//            }
//        })
//    }
//
//    override fun getCoursesActivities(user: ca.etsmtl.applets.etsmobile.services.models.MonETSUser, session: String, courseGroup: String, startDate: Date?, endDate: Date?, completion: (Result<List<CourseActivity>, ApiError>) -> Unit) {
//        val extraParams = mutableMapOf(
//            "pSession" to session,
//            "pCoursGroupe" to courseGroup
//        )
//        if (startDate != null && endDate != null) {
//            val formatter = SimpleDateFormat("YY-MM-dd", Locale.getDefault())
//            extraParams["pDateDebut"] = formatter.format(startDate)
//            extraParams["pDateFin"] = formatter.format(endDate)
//        }
//
//        val request = createRequest("lireHoraireDesSeances", user, extraParams)
//
//        client.newCall(request).enqueue(object : Callback {
//            override fun onFailure(call: Call, e: IOException) {
//                completion(Result.failure(ApiError(e.message ?: "Unknown error")))
//            }
//
//            override fun onResponse(call: Call, response: Response) {
//                val data = response.body?.string()
//                if (data != null) {
//                    val xml = parseXml(data)
//                    val error = xml[courseActivityErrorPath]
//                    if (error != null) {
//                        completion(Result.failure(ApiError(error)))
//                    } else {
//                        val courseActivityXml = xml[courseActivityPath]
//                        val courseActivities = courseActivityXml.map { CourseActivity.fromXml(it) }
//                        completion(Result.success(courseActivities))
//                    }
//                }
//            }
//        })
//    }
//
//    override fun getScheduleActivities(user: ca.etsmtl.applets.etsmobile.services.models.MonETSUser, session: String, completion: (Result<List<ScheduleActivity>, ApiError>) -> Unit) {
//        val extraParams = mapOf("pSession" to session)
//        val request = createRequest("listeHoraireEtProf", user, extraParams)
//
//        client.newCall(request).enqueue(object : Callback {
//            override fun onFailure(call: Call, e: IOException) {
//                completion(Result.failure(ApiError(e.message ?: "Unknown error")))
//            }
//
//            override fun onResponse(call: Call, response: Response) {
//                val data = response.body?.string()
//                if (data != null) {
//                    val xml = parseXml(data)
//                    val error = xml[scheduleActivityErrorPath]
//                    if (error != null) {
//                        completion(Result.failure(ApiError(error)))
//                    } else {
//                        val scheduleXml = xml[scheduleActivityPath]
//                        val scheduleActivities = scheduleXml.map { ScheduleActivity.fromXml(it) }
//                        completion(Result.success(scheduleActivities))
//                    }
//                }
//            }
//        })
//    }
//
//    override fun getCourseSummary(user: ca.etsmtl.applets.etsmobile.services.models.MonETSUser, course: Course, completion: (Result<CourseSummary, ApiError>) -> Unit) {
//        val extraParams = mapOf(
//            "pSigle" to course.acronym,
//            "pGroupe" to course.group,
//            "pSession" to course.session
//        )
//        val request = createRequest("listeElementsEvaluation", user, extraParams)
//
//        client.newCall(request).enqueue(object : Callback {
//            override fun onFailure(call: Call, e: IOException) {
//                completion(Result.failure(ApiError(e.message ?: "Unknown error")))
//            }
//
//            override fun onResponse(call: Call, response: Response) {
//                val data = response.body?.string()
//                if (data != null) {
//                    val xml = parseXml(data)
//                    val error = xml[courseSummaryErrorPath]
//                    if (error != null) {
//                        completion(Result.failure(ApiError(error)))
//                    } else {
//                        val courseXml = xml[courseSummaryPath]
//                        val courseSummary = CourseSummary.fromXml(courseXml)
//                        completion(Result.success(courseSummary))
//                    }
//                }
//            }
//        })
//    }
//
//    override fun getPrograms(user: ca.etsmtl.applets.etsmobile.services.models.MonETSUser, completion: (Result<List<Program>, ApiError>) -> Unit) {
//        val request = createRequest("listeProgrammes", user, emptyMap())
//
//        client.newCall(request).enqueue(object : Callback {
//            override fun onFailure(call: Call, e: IOException) {
//                completion(Result.failure(ApiError(e.message ?: "Unknown error")))
//            }
//
//            override fun onResponse(call: Call, response: Response) {
//                val data = response.body?.string()
//                if (data != null) {
//                    val xml = parseXml(data)
//                    val error = xml[programErrorPath]
//                    if (error != null) {
//                        completion(Result.failure(ApiError(error)))
//                    } else {
//                        val programXml = xml[programPath]
//                        val programs = programXml.map { Program.fromXml(it) }
//                        completion(Result.success(programs))
//                    }
//                }
//            }
//        })
//    }
//
//    override fun getCourseReviews(user: ca.etsmtl.applets.etsmobile.services.models.MonETSUser, session: ca.etsmtl.applets.etsmobile.services.models.Session, completion: (Result<List<CourseReview>, ApiError>) -> Unit) {
//        val extraParams = mapOf("pSession" to session.shortName)
//        val request = createRequest("lireEvaluationCours", user, extraParams)
//
//        client.newCall(request).enqueue(object : Callback {
//            override fun onFailure(call: Call, e: IOException) {
//                completion(Result.failure(ApiError(e.message ?: "Unknown error")))
//            }
//
//            override fun onResponse(call: Call, response: Response) {
//                val data = response.body?.string()
//                if (data != null) {
//                    val xml = parseXml(data)
//                    val error = xml[courseReviewErrorPath]
//                    if (error != null) {
//                        completion(Result.failure(ApiError(error)))
//                    } else {
//                        val courseReviewXml = xml[courseReviewPath]
//                        val courseReviews = courseReviewXml.map { CourseReview.fromXml(it) }
//                        completion(Result.success(courseReviews))
//                    }
//                }
//            }
//        })
//    }

    private fun parseXml(xml: String): Map<List<String>, String> {
        val factory = XmlPullParserFactory.newInstance()
        factory.isNamespaceAware = true
        val parser = factory.newPullParser()
        parser.setInput(StringReader(xml))

        val result = mutableMapOf<List<String>, String>()
        val path = mutableListOf<String>()
        var eventType = parser.eventType
        var text: String? = null

        while (eventType != XmlPullParser.END_DOCUMENT) {
            when (eventType) {
                XmlPullParser.START_TAG -> {
                    path.add(parser.name)
                }
                XmlPullParser.TEXT -> {
                    text = parser.text
                }
                XmlPullParser.END_TAG -> {
                    if (text != null) {
                        result[path.toList()] = text
                        text = null
                    }
                    path.removeAt(path.size - 1)
                }
            }
            eventType = parser.next()
        }
        return result
    }
}