//
//  ProgressProvider.swift
//  ETSMobile WidgetExtension
//
//  Created by Club Applets on 2022-02-03.
//

import WidgetKit

struct ProgressProvider: TimelineProvider {
    
    let placeholderProgressEntry = ProgressEntry(date: Date(), progress: 0.5, elapsedDays: 51, totalDays: 102)
    
    func placeholder(in context: Context) -> ProgressEntry {
        placeholderProgressEntry
    }
    
    func getSnapshot(in context: Context, completion: @escaping (ProgressEntry) -> ()) {
        let entry: ProgressEntry
        if context.isPreview {
            entry = placeholderProgressEntry
        } else {
//            entry = placeholderProgressEntry      // debug
            
            let data = UserDefaults.init(suiteName: widgetGroupId)
            let progress = data?.double(forKey: "progress")
            let elapsedDays = data?.integer(forKey: "elapsedDays")
            let totalDays = data?.integer(forKey: "totalDays")
            
            entry = ProgressEntry(date: Date(),
                                  progress: progress ?? 0.5,
                                  elapsedDays: elapsedDays ?? 51,
                                  totalDays: totalDays ?? 102)
        }
        completion(entry)
    }
    
    func getTimeline(in context: Context, completion: @escaping (Timeline<ProgressEntry>) -> ()) {
        getSnapshot(in: context) { (entry) in
            let timeline = Timeline(entries: [entry], policy: .atEnd)
            completion(timeline)
        }
    }
}
