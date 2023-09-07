//
//  GradesWidgetEntryView.swift
//  ETSMobile WidgetExtension
//
//  Created by Club Applets on 2022-02-03.
//

import SwiftUI

struct GradesWidgetEntryView: View {
    var entry: GradesProvider.Entry
    
    let dividerPadding = 16.0
    let spacing = 8.0
    
    var body: some View {
        ZStack {
            Color("BackgroundColor")

            VStack {
                HStack {
                    Text(entry.title)
                        .font(.system(size: 18))
                        .frame(maxHeight: 20)
                    
                    Spacer()
                }
                .padding(.top) // Add padding to the top
                
                Divider()
                    .background(Color("DividerColor"))
                    .padding(.bottom) // Add padding to the bottom
                
                HStack {
                    // limit to 5 single grade views to prevent overflow
                    ForEach(0..<min(5, entry.courseAcronyms.count)) { index in
                        SingleGradeView(course: entry.courseAcronyms[index], grade: entry.grades[index])
                    }
                }
                .padding([.leading, .trailing], 5 - spacing)
                
                Spacer() // Only one Spacer is needed
            }
            .padding([.leading, .trailing], dividerPadding)
            .frame(maxHeight: .infinity)
        }
    }
}
