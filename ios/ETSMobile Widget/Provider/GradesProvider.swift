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
                                             grades: ["A+", "B", "A+", "B", "A+"])
    
    func placeholder(in context: Context) -> GradesEntry {
        placeholderGradesEntry
    }
    
    func getSnapshot(in context: Context, completion: @escaping (GradesEntry) -> ()) {
        let entry: GradesEntry
        if context.isPreview {
            entry = placeholderGradesEntry
        } else {
            
            if let data = UserDefaults.init(suiteName: widgetGroupId) {
                // TODO: handle nil values better
                let courseAcronyms = data.object(forKey: "courseAcronyms") as? [String] ?? []
                let grades = data.object(forKey: "grades") as? [String] ?? []
                
                entry = GradesEntry(date: Date(), courseAcronyms: courseAcronyms, grades: grades)
            } else {    // error reading userdefaults
                entry = placeholderGradesEntry      // debug
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
