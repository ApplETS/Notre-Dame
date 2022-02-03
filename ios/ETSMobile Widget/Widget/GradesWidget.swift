//
//  GradesWidget.swift
//  ETSMobile WidgetExtension
//
//  Created by Club Applets on 2022-02-03.
//

import SwiftUI
import WidgetKit


// Grades widget definition & configuration
struct GradesWidget: Widget {
    
    // ID used by Flutter to update the widget (must be the same in Flutter and in the widget definition)
    let kind: String = "ETSMobile_GradesWidget"
    
    var body: some WidgetConfiguration {
        StaticConfiguration(kind: kind, provider: GradesProvider()) { entry in
            GradesWidgetEntryView(entry: entry)
        }
        .configurationDisplayName("Grades")
        .description("Display grades for the current session")
        .supportedFamilies([.systemMedium])
    }
}
