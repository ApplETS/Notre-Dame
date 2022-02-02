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
            
            Spacer()
            
            Text("Progression de la session")
                .multilineTextAlignment(.center)
                .font(.system(size: 18))
            
            Spacer()
            
            Text("\(Int(entry.progress * 100))%")
                .font(.system(size: 22))
            
            ProgressView(progress: entry.progress)
        }
    }
}
