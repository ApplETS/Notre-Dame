//
//  ETSMobileWidgets.swift
//  ETSMobile Widgets main file
//
//  Created by Club Applets on 2021-11-04.
//

import WidgetKit
import SwiftUI

private let widgetGroupId = "group.ca.etsmtl.applets.ETSMobile"

struct Provider: TimelineProvider {
    
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
            
            let data = UserDefaults.init(suiteName:widgetGroupId)
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


// Bundle to group all the widgets supported by the app
@main
struct ETSMobileWidgets: WidgetBundle {
    var body: some Widget {
        ProgressWidget()
    }
}

// Preview anything in Xcode (only used for development, not working for some reason)
struct ETSMobile_Widget_Previews: PreviewProvider {
    static var previews: some View {
        VStack {
            
            ProgressWidgetEntryView(entry: ProgressEntry(date: Date(), progress: 0.5, elapsedDays: 10, totalDays: 20))
                .previewContext(WidgetPreviewContext(family: .systemSmall))
        }
    }
}
