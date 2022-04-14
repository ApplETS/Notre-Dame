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
            Color("BackgroundColor")   // use app theme

            VStack {
                
                Spacer()
                
                HStack{
                    Text(entry.title)
                        .font(.system(size: 20))
                        .frame(maxHeight: 20)
                    
                    Spacer()
                }
                .padding([.leading, .trailing], dividerPadding)
                
                Spacer()
                
                Divider()
                    .background(Color("DividerColor"))
                    .padding([.leading, .trailing], dividerPadding)
                
                Spacer()
                Spacer()
                
                HStack {
                    // limit to 5 single grade views to prevent overflow
                    ForEach(0..<min(5, entry.courseAcronyms.count)) { index in
                        SingleGradeView(course: entry.courseAcronyms[index], grade: entry.grades[index])
                    }
                }
                .padding([.leading, .trailing], 5)
                
                Spacer()
                Spacer()
            }
            .frame(maxHeight: .infinity)
        }
    }
}
