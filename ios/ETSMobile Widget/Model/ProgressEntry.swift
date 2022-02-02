//
//  ProgressEntry.swift
//  ETSMobile WidgetExtension
//
//  Created by Club Applets on 2022-02-02.
//

import WidgetKit

// Structure holding data passed from Flutter
struct ProgressEntry: TimelineEntry {
    var date: Date
    let progress: Double
}
