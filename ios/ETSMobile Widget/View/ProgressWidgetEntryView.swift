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
    let dividerPadding = 16.0
    
    var body: some View {
        ZStack {        // wrapper to apply custom background color
            Color("BackgroundColor")
            
            VStack(spacing: spacing) {
                
                HStack {        // align text left
                    Text(entry.title)
                        .multilineTextAlignment(.leading)
                        .font(.system(size: 14))
                        .lineLimit(2)
                        .minimumScaleFactor(0.5)
                    Spacer()
                }
                .frame(maxHeight: 25)       // TODO: scale to widget size
                .padding([.leading, .trailing], dividerPadding)
                
                
                Divider()
                    .background(Color("DividerColor"))
                    .padding([.leading, .trailing], dividerPadding)
                
                ProgressBarView(progress: entry.progress,
                                elapsedDays: entry.elapsedDays,
                                totalDays: entry.totalDays,
                                suffix: String(entry.suffix.prefix(1)))
                    .scaledToFit()
                    .padding(spacing)
            }
            .padding([.top, .bottom], spacing)
        }
    }
}
