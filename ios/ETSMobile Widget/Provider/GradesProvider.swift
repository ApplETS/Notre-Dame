//
//  GradesProvider.swift
//  ETSMobile WidgetExtension
//
//  Created by Club Applets on 2022-02-03.
//

import WidgetKit

struct GradesProvider: TimelineProvider {
    
    let placeholderGradesEntry = GradesEntry(date: Date(),
                                             courseAcronyms: ["ABC123", "DEF456", "GHI789", "ABC123", "DEF456"],
                                             grades: ["A+", "B", "A+", "B", "A+"],
                                             session: "A2021")
    
    func placeholder(in context: Context) -> GradesEntry {
        placeholderGradesEntry
    }
    
    func getSnapshot(in context: Context, completion: @escaping (GradesEntry) -> ()) {
        var entry: GradesEntry = placeholderGradesEntry
        if !context.isPreview {
            if let data = UserDefaults.init(suiteName: widgetGroupId) {
                if let courseAcronyms = data.object(forKey: "courseAcronyms") as? [String],
                   let grades = data.object(forKey: "grades") as? [String],
                   let session = data.string(forKey: "session") {
                    entry = GradesEntry(date: Date(),
                                        courseAcronyms: courseAcronyms,
                                        grades: grades,
                                        session: session)
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
