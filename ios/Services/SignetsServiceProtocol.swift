//
//  SignetsServiceProtocol.swift
//  ETSMobile WidgetExtension
//
//  Created by Jonathan Duval-Venne on 2022-11-07.
//

import Foundation

protocol SignetsServiceProtocol {
    /// Call the SignetsAPI to get the courses activities for the [session] for
    /// the student ([username]). By specifying [courseGroup] we can filter the
    /// results to get only the activities for this course.
    /// If the [startDate] and/or [endDate] are specified the results will contains
    /// all the activities between these dates
    func getCoursesActivities(user: MonETSUser, session: String, courseGroup: String, startDate: Date?, endDate: Date?, completion: @escaping (Result<[CourseActivity], ApiError>) -> ());

    /// Call the SignetsAPI to get the courses activities for the [session] for
    /// the student ([username]).
    func getScheduleActivities(user: MonETSUser, session: String, completion: @escaping (Result<[ScheduleActivity], ApiError>) -> ());

    /// Call the SignetsAPI to get the courses of the student ([username]).
    func getCourses(user: MonETSUser, completion: @escaping (Result<[Course], ApiError>) -> ());

    /// Call the SignetsAPI to get all the evaluations (exams) and the summary
    /// of [course] for the student ([username]).
    func getCourseSummary(user: MonETSUser, course: Course, completion: @escaping (Result<CourseSummary, ApiError>) -> ());

    /// Call the SignetsAPI to get the list of all the [Session] for the student ([username]).
    func getSessions(user: MonETSUser, completion: @escaping (Result<[Session], ApiError>) -> ());

    /// Call the SignetsAPI to get the [ProfileStudent] for the student.
    func getStudentInfo(user: MonETSUser, completion: @escaping (Result<ProfileStudent, ApiError>) -> ());

    /// Call the SignetsAPI to get the list of all the [Program] for the student ([username]).
    func getPrograms(user: MonETSUser, completion: @escaping (Result<[Program], ApiError>) -> ());

    /// Call the SignetsAPI to get the list of all [CourseReview] for the [session]
    /// of the student ([username]).
    func getCourseReviews(user: MonETSUser, session: Session, completion: @escaping (Result<[CourseReview], ApiError>) -> ());
}
