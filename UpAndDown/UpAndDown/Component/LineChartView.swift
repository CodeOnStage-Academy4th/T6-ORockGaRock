//
//  LineChartView.swift
//  UpAndDown
//
//  Created by 양시준 on 8/8/25.
//

import SwiftUI

struct LineChartView: View {
    let data: [Double]
    let lineColor: Color
    let lineWidth: CGFloat
    
    var body: some View {
        ScrollViewReader { proxy in
            ScrollView(.horizontal, showsIndicators: false) {
                LineShape(dataPoints: data)
                    .stroke(lineColor, style: StrokeStyle(lineWidth: lineWidth, lineCap: .round, lineJoin: .round))
                    .frame(width: CGFloat(data.count * 10))
                    .id(0)
            }
            .frame(height: 200)
            .onAppear {
                proxy.scrollTo(0, anchor: .trailing)
            }
        }
    }
}

#Preview {
    LineChartView(
        data: [1, 2, 4, 3, 2, 5, 1, 2, 4, 5],
        lineColor: Color.orange,
        lineWidth: 3
    )
}
