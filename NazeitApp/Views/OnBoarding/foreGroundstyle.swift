//
//  foreGroundstyle.swift
//  KamBing
//
//  Created by Fakhri Djamaris on 16/04/26.
//

import SwiftUI

struct ForeGroundStyle: View{
    var body: some View {
        VStack {
            Text("Kam")
                .frame(width: 100, height: 100)
                .foregroundStyle(Color.secondary)
                .font(.system(size: 30, weight: .bold, design: .rounded))
            Image(systemName: "moon.stars.fill")
                .font(Font.system(size: 55, weight: .bold, design: .rounded))
                .foregroundStyle(Color.circadianTest, Color.yellow)
        }
    }
}

#Preview {
    ForeGroundStyle()
}
