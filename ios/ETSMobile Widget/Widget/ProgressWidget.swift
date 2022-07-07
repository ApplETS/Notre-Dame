//
//  ProgressWidget.swift
//  ETSMobile WidgetExtension
//
//  Created by Club Applets on 2022-02-02.
//

import SwiftUI
import WidgetKit


// Progress widget definition & configuration
struct ProgressWidget: Widget {
    
    // ID used by Flutter to update the widget (must be the same in Flutter and in the widget definition)
    let kind: String = "ETSMobile_ProgressWidget"
    
    var body: some WidgetConfiguration {
        StaticConfiguration(kind: kind, provider: ProgressProvider()) { entry in
            ProgressWidgetEntryView(entry: entry)
        }
        .configurationDisplayName("Session progress")
        .description("Display the current session progress")
        .supportedFamilies([.systemSmall])
    }
}
