//
//  ProgressWidgetEntryView.swift
//  ETSMobile WidgetExtension
//
//  Created by Club Applets on 2022-02-02.
//

import SwiftUI

struct ProgressWidgetEntryView : View {
    var entry: Provider.Entry
    
    var body: some View {
        VStack {
            
            Text("Progression de la session")
                .multilineTextAlignment(.center)
                .font(.system(size: 18))
                .padding(EdgeInsets.init(top: 5, leading: 0, bottom: 0, trailing: 0))
            
            Spacer()
            
            Text("\(Int(entry.progress * 100))%")
                .font(.system(size: 22))
            
            Text("\(entry.elapsedDays)j / \(entry.totalDays)j")
                .font(.system(size: 18))
            
            ProgressBarView(progress: entry.progress)
        }
    }
}
