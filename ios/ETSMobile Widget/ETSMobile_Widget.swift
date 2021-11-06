//
//  ETSMobile_Widget.swift
//  ETSMobile Widget
//
//  Created by Club Applets on 2021-11-04.
//

import WidgetKit
import SwiftUI

private let widgetGroupId = "group.ca.etsmtl.applets.ETSMobile"

struct Provider: TimelineProvider {
    func placeholder(in context: Context) -> SimpleEntry {
        SimpleEntry(date: Date(), progress: 0.5)
    }

    func getSnapshot(in context: Context, completion: @escaping (SimpleEntry) -> ()) {
        let entry: SimpleEntry
        if context.isPreview {
            entry = SimpleEntry(date: Date(), progress: 0.5)
        } else {
            let data = UserDefaults.init(suiteName:widgetGroupId)
            entry = SimpleEntry(date: Date(), progress: data?.double(forKey: "progress") ?? 0.5)
        }
        completion(entry)
    }

    func getTimeline(in context: Context, completion: @escaping (Timeline<Entry>) -> ()) {
        getSnapshot(in: context) { (entry) in
            let timeline = Timeline(entries: [entry], policy: .atEnd)
            completion(timeline)
        }
    }
}

struct SimpleEntry: TimelineEntry {
    var date: Date
    let progress: Double
}

struct CustomProgressView: View {
    var progress: Double
    
    var body: some View {
        VStack {
            GeometryReader { geometry in
                let height = 10.0
//                let height = geometry.size.height
//                let width = 50.0
                let width = geometry.size.width
                        ZStack(alignment: .leading) {
                            Rectangle()
                                .foregroundColor(Color.gray)
                                .frame(width: width,
                                       height: height)
                                .cornerRadius(height / 2.0)

                            Rectangle()
                                .foregroundColor(Color.green)
                                .frame(width: width * self.progress,
                                       height: height)
                                .cornerRadius(height / 2.0)
                        }
                    }
            .padding(EdgeInsets(top: 10, leading: 10, bottom: 10, trailing: 10))
        }
    }
}


struct ETSMobile_WidgetEntryView : View {
    var entry: Provider.Entry

    var body: some View {
        VStack {
            Text("Progression de la session")
            Text("\(entry.progress)")
            
            Spacer()
            
            CustomProgressView(progress: entry.progress)
        }
    }
}

@main
struct ETSMobile_Widget: Widget {
    let kind: String = "ETSMobile_Widget"

    var body: some WidgetConfiguration {
        StaticConfiguration(kind: kind, provider: Provider()) { entry in
            ETSMobile_WidgetEntryView(entry: entry)
        }
        .configurationDisplayName("My Widget")
        .description("This is an example widget.")
    }
}

struct ETSMobile_Widget_Previews: PreviewProvider {
    static var previews: some View {
        VStack {
            
            ETSMobile_WidgetEntryView(entry: SimpleEntry(date: Date(), progress: 0.5))
                .previewContext(WidgetPreviewContext(family: .systemSmall))
        }
    }
}
