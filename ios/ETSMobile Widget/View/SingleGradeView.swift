//
//  SingleGradeView.swift
//  ETSMobile WidgetExtension
//
//  Created by Club Applets on 2022-02-03.
//

import SwiftUI

struct SingleGradeView: View {
    let course: String
    let grade: String
    
    let cornerRadius = 6.0
    
    var body: some View {
        VStack (alignment: .center, spacing: 0) {
            
            ZStack {
                Color("ETSLightRed").edgesIgnoringSafeArea(.all)
                
                Text(course)
                    .foregroundColor(.white)
                    .font(.system(size: 16))
                    .lineLimit(1)
                    .minimumScaleFactor(0.5)
                    .padding([.leading, .trailing], 2)
            }
            .frame(height: 30, alignment: .center)    // warning: changing the height offsets the outline
            
            Divider()
            
            Text(grade)
                .font(.system(size: 24))
                .padding([.top, .bottom], 4)
        }
        .frame(minWidth: 50, idealWidth: 64, maxWidth: 70, minHeight: 60, idealHeight: 70, maxHeight: 70, alignment: .center)
        .cornerRadius(cornerRadius)
        .overlay(
            RoundedRectangle(cornerRadius: cornerRadius)
                .stroke(Color.gray, lineWidth: 0.3)
                .offset(y: 1)      // fixes the small blank area between the top of the red bg and the outline
        )
    }
}

struct SingleGradeView_Previews: PreviewProvider {
    static var previews: some View {
        SingleGradeView(course: "ABC123", grade: "A+")
    }
}
