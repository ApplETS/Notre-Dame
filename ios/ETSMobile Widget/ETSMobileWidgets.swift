//
//  ETSMobileWidgets.swift
//  ETSMobile Widgets main file
//
//  Created by Club Applets on 2021-11-04.
//

import WidgetKit
import SwiftUI



// Bundle to group all the widgets supported by the app
@main
struct ETSMobileWidgets: WidgetBundle {
    var body: some Widget {
        ProgressWidget()
        GradesWidget()
    }
}
