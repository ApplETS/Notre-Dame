package ca.etsmtl.applets.etsmobile.services

import ca.etsmtl.applets.etsmobile.services.models.MonETSUser
import ca.etsmtl.applets.etsmobile.services.models.Semester

interface SignetsServiceProtocol {
    fun getSessions(user: MonETSUser, completion: (Result<List<Semester>>) -> Unit)
//    fun getStudentInfo(user: ca.etsmtl.applets.etsmobile.services.models.MonETSUser, completion: (Result<ProfileStudent, ApiError>) -> Unit)
//    fun getCourses(user: ca.etsmtl.applets.etsmobile.services.models.MonETSUser, completion: (Result<List<Course>, ApiError>) -> Unit)
//    fun getCoursesActivities(user: ca.etsmtl.applets.etsmobile.services.models.MonETSUser, session: String, courseGroup: String, startDate: Date?, endDate: Date?, completion: (Result<List<CourseActivity>, ApiError>) -> Unit)
//    fun getScheduleActivities(user: ca.etsmtl.applets.etsmobile.services.models.MonETSUser, session: String, completion: (Result<List<ScheduleActivity>, ApiError>) -> Unit)
//    fun getCourseSummary(user: ca.etsmtl.applets.etsmobile.services.models.MonETSUser, course: Course, completion: (Result<CourseSummary, ApiError>) -> Unit)
//    fun getPrograms(user: ca.etsmtl.applets.etsmobile.services.models.MonETSUser, completion: (Result<List<Program>, ApiError>) -> Unit)
//    fun getCourseReviews(user: ca.etsmtl.applets.etsmobile.services.models.MonETSUser, session: ca.etsmtl.applets.etsmobile.services.models.Session, completion: (Result<List<CourseReview>, ApiError>) -> Unit)
}
