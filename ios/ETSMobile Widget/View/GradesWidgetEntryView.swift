//
//  GradesWidgetEntryView.swift
//  ETSMobile WidgetExtension
//
//  Created by Club Applets on 2022-02-03.
//

import SwiftUI

struct GradesWidgetEntryView: View {
    var entry: GradesProvider.Entry
    
    var body: some View {
        VStack {
            
            Text("Notes - \(entry.session)")
                .font(.system(size: 20))
                .frame(maxHeight: 20)
            
            Divider()
            
            HStack {
                // TODO: don't take more than 5 entries? (to avoid overflow)
                ForEach(Array(entry.courseAcronyms.enumerated()), id: \.element) { index, element in
                    SingleGradeView(course: element, grade: entry.grades[index])
                }
            }
            .padding(EdgeInsets(top: 0, leading: 5, bottom: 0, trailing: 5))
        }
    }
}
