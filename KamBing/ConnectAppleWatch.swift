//
//  ContentView.swift
//  KamBing
//
//  Created by Fakhri Djamaris on 10/04/26.
//

import SwiftUI

struct ContentView: View {
    var body: some View {
        VStack(alignment: .leading) {
            Text("Your Trip")
                .font(Font.largeTitle.bold())
                .multilineTextAlignment(.center)
            //.padding(100)
            //          // Spacer()
            
            Text("Departure Country")
            
            TextField("Departure Country", text: /*@START_MENU_TOKEN@*//*@PLACEHOLDER=Value@*/.constant("")/*@END_MENU_TOKEN@*/)
            Text("Departure Country")
            TextField("Arrival Country", text: /*@START_MENU_TOKEN@*//*@PLACEHOLDER=Value@*/.constant("")/*@END_MENU_TOKEN@*/)
            Text("Arrival Date")
            
            DatePicker(selection: /*@START_MENU_TOKEN@*/.constant(Date())/*@END_MENU_TOKEN@*/, label: { /*@START_MENU_TOKEN@*/Text("Date")/*@END_MENU_TOKEN@*/ })
            
            Button("Adapting Now") {
                //
            }
            .padding(50)
            .buttonStyle(.glassProminent)
            .tint(.green)
            
            
        }
        .padding()
    }
}

#Preview {
    ContentView()
}


