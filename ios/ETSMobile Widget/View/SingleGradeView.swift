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
    
    var body: some View {
        VStack (alignment: .center, spacing: 0) {
            
            ZStack {
                Color.red.edgesIgnoringSafeArea(.all)
                
                Text(course)
                    .foregroundColor(.white)
                    .font(.system(size: 16))
            }
            .frame(height: 30, alignment: .center)
            
            Divider()
            
            Text(grade)
                .font(.system(size: 24))
                .padding(EdgeInsets(top: 4, leading: 0, bottom: 4, trailing: 0))
        }
        .frame(minWidth: 60, idealWidth: 64, maxWidth: 70, minHeight: 60, idealHeight: 70, maxHeight: 70, alignment: .center)
        .border(Color.gray, width: 0.2)
        .cornerRadius(6)    // fixme cutting off corners
//        .shadow(color: .gray, radius: 0.5, x: -1, y: -1)
    }
}

struct SingleGradeView_Previews: PreviewProvider {
    static var previews: some View {
        SingleGradeView(course: "ABC123", grade: "A+")
    }
}
