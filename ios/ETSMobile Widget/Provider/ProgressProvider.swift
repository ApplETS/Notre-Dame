//
//  ProgressProvider.swift
//  ETSMobile WidgetExtension
//
//  Created by Club Applets on 2022-02-03.
//

import WidgetKit

struct ProgressProvider: TimelineProvider {
    static let KEY_PREFIX = "progress_"
    
    let placeholderProgressEntry = ProgressEntry(
        date: Date(),
        progress: 0.5,
        elapsedDays: 51,
        totalDays: 102,
        suffix: "days",
        title: "Session Progress (plch)")
    
    func placeholder(in context: Context) -> ProgressEntry {
        placeholderProgressEntry
    }
    
    func getSnapshot(in context: Context, completion: @escaping (ProgressEntry) -> ()) {
        let entry: ProgressEntry
        if context.isPreview {
            entry = placeholderProgressEntry
        } else {            
            let data = UserDefaults.init(suiteName: widgetGroupId)
            let progress = data?.double(forKey: ProgressProvider.KEY_PREFIX + "progress")
            let elapsedDays = data?.integer(forKey: ProgressProvider.KEY_PREFIX + "elapsedDays")
            let totalDays = data?.integer(forKey: ProgressProvider.KEY_PREFIX + "totalDays")
            let suffix = data?.string(forKey: ProgressProvider.KEY_PREFIX + "suffix")
            let title = data?.string(forKey: ProgressProvider.KEY_PREFIX + "title")
            
            entry = ProgressEntry(date: Date(),
                                  progress: progress ?? 0.5,
                                  elapsedDays: elapsedDays ?? 51,
                                  totalDays: totalDays ?? 102,
                                  suffix: suffix ?? "days",
                                  title: title ?? "Session Progress")
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
