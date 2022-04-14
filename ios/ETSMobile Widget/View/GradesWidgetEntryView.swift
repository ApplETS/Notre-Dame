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
        ZStack {
            Color("BackgroundColor")   // use app theme
            
            VStack {
                Text(entry.title)
                    .font(.system(size: 20))
                    .frame(maxHeight: 20)
                
                Divider()
                
                HStack {
                    ForEach(0..<min(5, entry.courseAcronyms.count)) { index in
                        SingleGradeView(course: entry.courseAcronyms[index], grade: entry.grades[index])
                    }
                }
                .padding([.leading, .trailing], 5)
            }
        }
    }
}
