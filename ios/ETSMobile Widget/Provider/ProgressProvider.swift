//
//  ProgressProvider.swift
//  ETSMobile WidgetExtension
//
//  Created by Club Applets on 2022-02-03.
//

import WidgetKit

struct ProgressProvider: TimelineProvider {
    static let KEY_PREFIX = "progress_"
    
    let placeholderDate = Date()
    let placeholderProgress = 0.5
    let placeholderElapsedDays = 51
    let placeholderTotalDays = 102
    let placeholderSuffix = "days"
    let placeholderTitle = "Session Progress"
    
    func placeholder(in context: Context) -> ProgressEntry {
        return ProgressEntry(
            date: placeholderDate,
            progress: placeholderProgress,
            elapsedDays: placeholderElapsedDays,
            totalDays: placeholderTotalDays,
            suffix: placeholderSuffix,
            title: placeholderTitle,
            widgetHeight: context.displaySize.height)
    }
    
    func getSnapshot(in context: Context, completion: @escaping (ProgressEntry) -> ()) {
        
        let entry: ProgressEntry
        if context.isPreview {
            entry = placeholder(in: context)
        } else {            
            let data = UserDefaults.init(suiteName: widgetGroupId)
            let progress = data?.double(forKey: ProgressProvider.KEY_PREFIX + "progress")
            let elapsedDays = data?.integer(forKey: ProgressProvider.KEY_PREFIX + "elapsedDays")
            let totalDays = data?.integer(forKey: ProgressProvider.KEY_PREFIX + "totalDays")
            let suffix = data?.string(forKey: ProgressProvider.KEY_PREFIX + "suffix")
            let title = data?.string(forKey: ProgressProvider.KEY_PREFIX + "title")
            
            entry = ProgressEntry(date: Date(),
                                  progress: progress ?? placeholderProgress,
                                  elapsedDays: elapsedDays ?? placeholderElapsedDays,
                                  totalDays: totalDays ?? placeholderTotalDays,
                                  suffix: suffix ?? placeholderSuffix,
                                  title: title ?? placeholderTitle,
                                  widgetHeight: context.displaySize.height)
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
