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

    var roundedGrade: String {
        let gradeWithPeriod = grade.replacingOccurrences(of: ",", with: ".") // Replace comma with period
        
        if let gradeValue = Double(gradeWithPeriod) {
            let roundedValue = Int(round(gradeValue))
            return "\(roundedValue) %"
        } else {
            // If the grade is not a numeric value, display the original grade string (e.g., "A-")
            return grade
        }
    }


    var body: some View {
        VStack (alignment: .center, spacing: 0) {
            
            ZStack {
                Color("ETSLightRed")
                    .frame(height: 30)
                
                Text(course)
                    .foregroundColor(.white)
                    .font(.system(size: 16))
                    .lineLimit(1)
                    .minimumScaleFactor(0.5)
                    .padding([.leading, .trailing], 2)
            }
            .frame(height: 30, alignment: .center)
            
            Text(roundedGrade)
                .font(.system(size: 24))
                .padding([.top, .bottom], 4)
        }
        .frame(minWidth: 50, idealWidth: 64, maxWidth: 70, minHeight: 60, idealHeight: 70, maxHeight: 70, alignment: .top)
        .background(
            RoundedRectangle(cornerRadius: cornerRadius)
                .strokeBorder(Color.gray, lineWidth: 0.3)
        )
        .cornerRadius(cornerRadius)
    }
}


struct SingleGradeView_Previews: PreviewProvider {
    static var previews: some View {
        SingleGradeView(course: "ABC123", grade: "A+")
    }
}
