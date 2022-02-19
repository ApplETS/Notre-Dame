//
//  ProgressWidgetEntryView.swift
//  ETSMobile WidgetExtension
//
//  Created by Club Applets on 2022-02-02.
//

import SwiftUI

struct ProgressWidgetEntryView : View {
    var entry: ProgressProvider.Entry
    
    var body: some View {
        VStack {
            
            Text(entry.title)
                .multilineTextAlignment(.center)
                .font(.system(size: 18))
                .fixedSize(horizontal: false, vertical: true)
            
            ProgressBarView(progress: entry.progress)
                .padding(EdgeInsets.init(top: -10, leading: 10, bottom: 0, trailing: 10))
            
            Text("\(entry.elapsedDays) / \(entry.totalDays) \(entry.suffix)")
                .font(.system(size: 18))
            // TODO: add intent config to choose between these displays
            //            Text("\(Int(entry.progress * 100))%")
            //                .font(.system(size: 22))
                        
            
        }
        .padding([.top, .bottom], 20)
    }
}
