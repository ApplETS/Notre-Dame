//
//  SignetsService.swift
//  ETSMobile WidgetExtension
//
//  Created by Jonathan Duval-Venne on 2022-11-07.
//

import Foundation
import SwiftyXMLParser

struct ApiError : Error {
    let message: String
}

class SignetsService: SignetsServiceProtocol {
    
    static let shared = SignetsService()

    private let baseURL = URL(string: signetsAPI)!
    private let session = URLSession(configuration: URLSessionConfiguration.default)

    private init() { }
    
    private func createRequest(soapAction: String, user: MonETSUser, extraParams: [String:String]) -> URLRequest{
        var postData = SoapRequestHelper.getParameters(for: soapAction, user: user, extraParams: extraParams)
        var request = URLRequest(url: baseURL)
        request.addValue("text/xml", forHTTPHeaderField: "Content-Type")
        request.addValue("http://etsmtl.ca/\(soapAction)", forHTTPHeaderField: "SOAPAction")
        request.httpMethod = "POST"
        request.httpBody = postData.data(using: .utf8)
        
        return request
    }
    
    func getSessions(user: MonETSUser, completion: @escaping (Result<[Session], ApiError>) -> ()) {
        var request = createRequest(soapAction: "listeSessions", user: user, extraParams: [:])
        
        URLSession.shared.dataTask(with: request) { data, response, error in
            guard let data = data else {
                print(String(describing: error))
                return
            }
            
            var xml = XML.parse(data)
            if let error = xml[sessionErrorPath].text {
                completion(.failure(ApiError(message: error)))
            }
            let sessionsXml = xml[sessionPath]
            let sessions = sessionsXml.map { Session(from: $0) }
            completion(.success(sessions))
        }.resume()
    }
    
    
    func getStudentInfo(user: MonETSUser, completion: @escaping (Result<ProfileStudent, ApiError>) -> ()) {
        var request = createRequest(soapAction: "infoEtudiant", user: user, extraParams: [:])
        
        URLSession.shared.dataTask(with: request) { data, response, error in
            guard let data = data else {
                print(String(describing: error))
                return
            }
            var xml = XML.parse(data)
            if let error = xml[studentInfoErrorPath].text {
                completion(.failure(ApiError(message: error)))
            }
            var studentInfo = xml[studentInfoPath]
            let info = ProfileStudent(from: studentInfo)
            completion(.success(info))
        }.resume()
    }
    
    func getCourses(user: MonETSUser, completion: @escaping (Result<[Course], ApiError>) -> ()) {
        var request = createRequest(soapAction: "listeCours", user: user, extraParams: [:])
        
        URLSession.shared.dataTask(with: request) { data, response, error in
            guard let data = data else {
                print(String(describing: error))
                return
            }
            var xml = XML.parse(data)
            if let error = xml[courseErrorPath].text {
                completion(.failure(ApiError(message: error)))
            }
            var coursesXml = xml[coursePath]
            let courses = coursesXml.map { Course(from: $0) }
            completion(.success(courses))
        }.resume()
    }
    
    func getCoursesActivities(user: MonETSUser, session: String, courseGroup: String, startDate: Date?, endDate: Date?, completion: @escaping (Result<[CourseActivity], ApiError>) -> ()) {
        var extraParams = [
            "pSession" : session,
            "pCoursGroupe": courseGroup,
        ]
        
        if startDate != nil && endDate != nil {
            let formatter = DateFormatter()
            formatter.dateFormat = "YY-MM-dd"
            extraParams["pDateDebut"] = formatter.string(from: startDate!)
            extraParams["pDateFin"] = formatter.string(from: endDate!)
        }
        
        var request = createRequest(soapAction: "lireHoraireDesSeances", user: user, extraParams: extraParams)
        
        URLSession.shared.dataTask(with: request) { data, response, error in
            guard let data = data else {
                print(String(describing: error))
                return
            }
            var xml = XML.parse(data)
            if let error = xml[courseActivityErrorPath].text {
                completion(.failure(ApiError(message: error)))
            }
            let courseActivityXml = xml[courseActivityPath]
            let courseActivities = courseActivityXml.map { CourseActivity(from: $0) }
            completion(.success(courseActivities))
        }.resume()
    }
    
    func getScheduleActivities(user: MonETSUser, session: String, completion: @escaping (Result<[ScheduleActivity], ApiError>) -> ()) {
        var extraParams = [
            "pSession" : session
        ]
        
        var request = createRequest(soapAction: "listeHoraireEtProf", user: user, extraParams: extraParams)
        
        URLSession.shared.dataTask(with: request) { data, response, error in
            guard let data = data else {
                print(String(describing: error))
                return
            }
            var xml = XML.parse(data)
            if let error = xml[scheduleActivityErrorPath].text {
                completion(.failure(ApiError(message: error)))
            }
            let scheduleXml = xml[scheduleActivityPath]
            let scheduleActivities = scheduleXml.map { ScheduleActivity(from: $0) }
            completion(.success(scheduleActivities))
        }.resume()
    }
    
    func getCourseSummary(user: MonETSUser, course: Course, completion: @escaping (Result<CourseSummary, ApiError>) -> ()) {
        let extraParams = [
            "pSigle" : course.acronym!,
            "pGroupe" : course.group!,
            "pSession" : course.session!
        ]
        
        var request = createRequest(soapAction: "listeElementsEvaluation", user: user, extraParams: extraParams)
        
        URLSession.shared.dataTask(with: request) { data, response, error in
            guard let data = data else {
                print(String(describing: error))
                return
            }
            var xml = XML.parse(data)
            if let error = xml[courseSummaryErrorPath].text {
                completion(.failure(ApiError(message: error)))
            }
            let courseXml = xml[courseSummaryPath]
            let courseSummary = CourseSummary(from: courseXml)
            completion(.success(courseSummary))
        }.resume()
    }
    
    func getPrograms(user: MonETSUser, completion: @escaping (Result<[Program], ApiError>) -> ()) {
        var request = createRequest(soapAction: "listeProgrammes", user: user, extraParams: [:])
        
        URLSession.shared.dataTask(with: request) { data, response, error in
            guard let data = data else {
                print(String(describing: error))
                return
            }
            var xml = XML.parse(data)
            if let error = xml[programErrorPath].text {
                completion(.failure(ApiError(message: error)))
            }
            let programXml = xml[programPath]
            let programs = programXml.map { Program(from: $0) }
            completion(.success(programs))
        }.resume()
    }
    
    func getCourseReviews(user: MonETSUser, session: Session, completion: @escaping (Result<[CourseReview], ApiError>) -> ()) {
        let extraParams = [
            "pSession" : session.shortName!
        ]
        
        var request = createRequest(soapAction: "lireEvaluationCours", user: user, extraParams: extraParams)
        
        URLSession.shared.dataTask(with: request) { data, response, error in
            guard let data = data else {
                print(String(describing: error))
                return
            }
            var xml = XML.parse(data)
            if let error = xml[courseReviewErrorPath].text {
                completion(.failure(ApiError(message: error)))
            }
            let courseReviewXml = xml[courseReviewPath]
            let courseReviews = courseReviewXml.map { CourseReview(from: $0) }
            completion(.success(courseReviews))
        }.resume()
    }
}
