//
//  ProgressEntry.swift
//  ETSMobile WidgetExtension
//
//  Created by Club Applets on 2022-02-02.
//

import SwiftUI
import WidgetKit

// Structure holding data passed from Flutter
struct ProgressEntry: TimelineEntry {
    var date: Date
    let progress: Double
    let elapsedDays: Int
    let totalDays: Int
    let suffix: String
    let title: String
    let widgetHeight: CGFloat
}
