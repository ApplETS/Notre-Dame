//
//  GradesWidgetEntryView.swift
//  ETSMobile WidgetExtension
//
//  Created by Club Applets on 2022-02-03.
//

import SwiftUI

struct GradesWidgetEntryView: View {
    var entry: GradesProvider.Entry
    
    let testData = ["ABC123", "DEF456", "GHI789", "ABC123", "DEF456"]
//    let testData = ["ABC123", "DEF456", "GHI789"]
    
    var body: some View {
        VStack {
            
            Text("Notes de la session")
                .font(.system(size: 20))
                .frame(maxHeight: 20)
            
            Divider()
            
            HStack {
                ForEach (testData, id: \.self) { value in
                    SingleGradeView(course: value, grade: "A+")
                }
            }
            .padding(EdgeInsets(top: 0, leading: 5, bottom: 0, trailing: 5))
        }
    }
}
