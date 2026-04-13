//
//  Frame.swift
//  KamBing
//
//  Created by Fakhri Djamaris on 10/04/26.
//


import SwiftUI

struct Frame: View {
    var body: some View {
        VStack {
            Text("Hello, World!").frame(width: 200, height: 200).background(.yellow)
        }
        .padding()
    }
}

#Preview {
    Frame()
}


