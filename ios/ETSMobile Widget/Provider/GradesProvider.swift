//
//  GradesProvider.swift
//  ETSMobile WidgetExtension
//
//  Created by Club Applets on 2022-02-03.
//

import WidgetKit

struct GradesProvider: TimelineProvider {
    static let KEY_PREFIX = "grade_"
    
    let placeholderGradesEntry = GradesEntry(
        date: Date(),
        courseAcronyms: ["ABC123", "DEF456", "GHI789", "ABC123", "DEF456", "GHI789"],
        grades: ["A+", "B", "A+", "B", "A+" , "E"],
        title: "Grades - A2022")
    
    func placeholder(in context: Context) -> GradesEntry {
        placeholderGradesEntry
    }
    
    func getSnapshot(in context: Context, completion: @escaping (GradesEntry) -> ()) {
        var entry: GradesEntry = placeholderGradesEntry
        if !context.isPreview {
            if let data = UserDefaults.init(suiteName: widgetGroupId) {
                if let courseAcronyms = data.object(forKey: GradesProvider.KEY_PREFIX + "courseAcronyms") as? [String],
                   let grades = data.object(forKey: GradesProvider.KEY_PREFIX + "grades") as? [String],
                   let title = data.string(forKey: GradesProvider.KEY_PREFIX + "title") {
                    entry = GradesEntry(date: Date(),
                                        courseAcronyms: courseAcronyms,
                                        grades: grades,
                                        title: title)
                }
            }
        }
        completion(entry)
    }
    
    func getTimeline(in context: Context, completion: @escaping (Timeline<GradesEntry>) -> ()) {
        getSnapshot(in: context) { (entry) in
            let timeline = Timeline(entries: [entry], policy: .atEnd)
            completion(timeline)
        }
    }
}
