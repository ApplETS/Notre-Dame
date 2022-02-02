//
//  ProgressBarView.swift
//  ETSMobile WidgetExtension
//
//  Created by Club Applets on 2022-02-02.
//

import SwiftUI

struct ProgressBarView: View {
    var progress: Double
    
    var body: some View {
        VStack {
            GeometryReader { geometry in
                let height = 10.0
                let width = geometry.size.width
                
                ZStack(alignment: .leading) {
                    Rectangle()
                        .foregroundColor(Color.gray)
                        .frame(width: width,
                               height: height)
                        .cornerRadius(height / 2.0)
                    
                    Rectangle()
                        .foregroundColor(Color.green)
                        .frame(width: width * self.progress,
                               height: height)
                        .cornerRadius(height / 2.0)
                }
                .position(x: geometry.frame(in: .local).midX, y: geometry.frame(in: .local).midY)
                .frame(
                    width: geometry.frame(in: .global).width,
                    height: geometry.frame(in: .global).height
                )
            }
            .padding(EdgeInsets(top: 0, leading: 10, bottom: 0, trailing: 10))
        }
    }
}
