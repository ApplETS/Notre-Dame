//
//  ProgressWidgetEntryView.swift
//  ETSMobile WidgetExtension
//
//  Created by Club Applets on 2022-02-02.
//

import SwiftUI

struct ProgressWidgetEntryView : View {
    var entry: ProgressProvider.Entry
    
    let spacing = 8.0
    
    var body: some View {
        ZStack {        // wrapper to apply custom background color
            Color("BackgroundColor")   // use app theme
            
            VStack(spacing: spacing) {
                
                HStack {        // align text left
                    Text(entry.title)
                        .multilineTextAlignment(.leading)
                        .font(.system(size: 14))
                        .fixedSize(horizontal: false, vertical: true)
                    Spacer()
                }
                .padding([.leading, .trailing], 16)
                
                
                Divider()
                    .padding([.leading, .trailing], 6.0)
                
                ProgressBarView(progress: entry.progress,
                                elapsedDays: entry.elapsedDays,
                                totalDays: entry.totalDays)
                    .scaledToFit()
                    .padding(spacing + 2.0)
            }
            .padding([.top, .bottom], spacing)
        }
    }
}
