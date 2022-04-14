//
//  ProgressBarView.swift
//  ETSMobile WidgetExtension
//
//  Created by Club Applets on 2022-02-02.
//

import SwiftUI

struct ProgressBarView: View {
    var progress: Double        // [0..1]
    var elapsedDays: Int
    var totalDays: Int
    var suffix: String
    
    let lineWidth = 10.0        // TODO: use metrics.size.height to adapt line width
    
    var body: some View {
        GeometryReader { metrics in
            ZStack {
                // background (full) circle
                Circle()
                    .stroke(lineWidth: lineWidth)
                    .opacity(0.4)
                    .foregroundColor(Color("ProgressBackground"))
                
                // progress circle
                Circle()
                    .trim(from: 0.0, to: progress)
                    .stroke(style: StrokeStyle(lineWidth: lineWidth, lineCap: .round, lineJoin: .round))
                    .foregroundColor(Color("ProgressForeground"))
                    .rotationEffect(Angle(degrees: 270.0))      // start at the top
                
                // inner circle
                Circle()
                    .fill(Color("ProgressBackground"))
                    .opacity(0.4)
                    .frame(width: metrics.size.height * 0.7,
                           height: metrics.size.height * 0.7)
                
                // progress text
                VStack {
                    Text("\(Int(progress * 100)) %")
                        .lineLimit(1)
                        .minimumScaleFactor(0.5)
                    Text("\(elapsedDays) / \(totalDays) \(suffix)")
                        .font(.system(size: 9))
                        .lineLimit(1)
                        .minimumScaleFactor(0.5)
                }
                .frame(width: metrics.size.height * 0.5,
                       height: metrics.size.height * 0.6)
            }
        }
    }
}
