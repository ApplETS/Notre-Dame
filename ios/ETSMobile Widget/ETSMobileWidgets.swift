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

// Preview anything in Xcode (only used for development, not working for some reason)
struct ETSMobile_Widget_Previews: PreviewProvider {
    static var previews: some View {
        VStack {
            
            ProgressWidgetEntryView(entry: ProgressEntry(date: Date(), progress: 0.5, elapsedDays: 10, totalDays: 20))
                .previewContext(WidgetPreviewContext(family: .systemSmall))
        }
    }
}
