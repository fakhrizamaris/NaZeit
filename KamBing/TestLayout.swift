//
//  TestLayout.swift
//  KamBing
//
//  Created by Fakhri Djamaris on 13/04/26.
//

import SwiftUI

struct TestLayout: View {
    var body: some View {
        VStack {
            Image(systemName: "person.circle.fill")
                .resizable()
                .frame(width: 100, height: 100)
                .foregroundColor(.blue)
            
            Text("Fakhri")
        }
    }
}
