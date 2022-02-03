//
//  GradesProvider.swift
//  ETSMobile WidgetExtension
//
//  Created by Club Applets on 2022-02-03.
//

import WidgetKit

struct GradesProvider: TimelineProvider {
    
    let placeholderGradesEntry = GradesEntry(date: Date(), value: 0.5)
    
    func placeholder(in context: Context) -> GradesEntry {
        placeholderGradesEntry
    }
    
    func getSnapshot(in context: Context, completion: @escaping (GradesEntry) -> ()) {
        let entry: GradesEntry
        if context.isPreview {
            entry = placeholderGradesEntry
        } else {
            entry = placeholderGradesEntry      // debug
            
//            let data = UserDefaults.init(suiteName: widgetGroupId)
//            let progress = data?.double(forKey: "progress")
//            let elapsedDays = data?.integer(forKey: "elapsedDays")
//            let totalDays = data?.integer(forKey: "totalDays")
//
//            entry = GradesEntry(date: Date(),
//                                  progress: progress ?? 0.5,
//                                  elapsedDays: elapsedDays ?? 51,
//                                  totalDays: totalDays ?? 102)
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
