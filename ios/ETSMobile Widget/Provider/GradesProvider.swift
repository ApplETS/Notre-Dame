//
//  GradesProvider.swift
//  ETSMobile WidgetExtension
//
//  Created by Club Applets on 2022-02-03.
//

import WidgetKit

struct GradesProvider: TimelineProvider {
    static let KEY_PREFIX = "grade_"
    
    let keychainService: KeychainService
    let signetsService: SignetsService
    
    let placeholderGradesEntry = GradesEntry(
        date: Date(),
        courseAcronyms: ["ABC123", "DEF456", "GHI789", "JKL012", "MNO345"],
        grades: ["A+", "B", "A+", "B", "A+"],
        title: "Grades - A2022")
    
    init() {
        keychainService = KeychainService()
        signetsService = SignetsService.shared
    }
    
    func placeholder(in context: Context) -> GradesEntry {
        placeholderGradesEntry
    }
    
    func getSnapshot(in context: Context, completion: @escaping (GradesEntry) -> ()) {
        var entry: GradesEntry = placeholderGradesEntry
        
        guard let username = keychainService.get(key: usernameKey),
              let password = keychainService.get(key: passwordKey) else {
            completion(entry)
            return
        }
        
        if !context.isPreview {
            let user = MonETSUser(username: username, password: password, typeUsagerId: 1)
            
            signetsService.getCourses(user: user, completion: { result in
                switch result {
                case .success(let courses):
                    let currentSession = getCurrenSession()
                    let sessionCourses = courses.filter { $0.session == currentSession }
                    
                    let dispatchGroup = DispatchGroup()
                    var courseAcronyms: [String] = []
                    var grades: [String] = []
                    
                    for course in sessionCourses {
                        dispatchGroup.enter()
                        signetsService.getCourseSummary(user: user, course: course, completion: { result in
                            switch result {
                            case .success(let summary):
                                courseAcronyms.append(course.acronym!)
                                grades.append(summary.currentMarkInPercent ?? "N/A")
                                dispatchGroup.leave()
                            case .failure:
                                courseAcronyms.append(course.acronym!)
                                grades.append("N/A")
                                dispatchGroup.leave()
                            }
                        })
                    }
                    
                    dispatchGroup.notify(queue: .main) {
                        entry = GradesEntry(date: Date(), courseAcronyms: courseAcronyms, grades: grades, title: "Grades - \(currentSession)")
                        completion(entry)
                    }
                    
                case .failure(let error):
                    //entry.error = error.message
                    completion(entry)
                }
            })
        }
        else {
            completion(entry)
        }
    }
    
    func getTimeline(in context: Context, completion: @escaping (Timeline<GradesEntry>) -> ()) {
        getSnapshot(in: context) { (entry) in
            let timeline = Timeline(entries: [entry], policy: .atEnd)
            completion(timeline)
        }
    }
    
    func getCurrenSession() -> String {
        if let data = UserDefaults.init(suiteName: widgetGroupId) {
            if let title = data.string(forKey: GradesProvider.KEY_PREFIX + "title") {
                let separated = title.split(separator: " ")
                return String(separated.last ?? "")
            }
        }
        return ""
    }
}
