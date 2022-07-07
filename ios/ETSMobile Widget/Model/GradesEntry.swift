//
//  GradesEntry.swift
//  ETSMobile WidgetExtension
//
//  Created by Club Applets on 2022-02-03.
//

import WidgetKit

// Structure holding data passed from Flutter
struct GradesEntry: TimelineEntry {
    var date: Date
    let courseAcronyms: [String]
    let grades: [String]
    let title: String
}
