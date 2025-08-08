//
//  LineChartView.swift
//  UpAndDown
//
//  Created by 양시준 on 8/8/25.
//

import SwiftUI

struct LineChartView: View {
    @State var visibleDataCount: Int = 60
    let data: [Double]
    let lineColor: Color
    let lineWidth: CGFloat
    let bottomPadding: CGFloat
    
    init(data: [Double], lineColor: Color, lineWidth: CGFloat, fillArea: Bool = false, fillColor: Color? = nil, bottomPadding: CGFloat = 0.2) {
        self.data = data
        self.lineColor = lineColor
        self.lineWidth = lineWidth
        self.bottomPadding = bottomPadding
    }
    
    var body: some View {
        ZStack {
            // 채우기 영역
            LineShape(dataPoints: data.suffix(visibleDataCount), fillArea: true, bottomPadding: bottomPadding)
                .fill(LinearGradient(colors: [lineColor.opacity(0.8), lineColor.opacity(0)], startPoint: .top, endPoint: .bottom))
            
            // 선 그리기
            LineShape(dataPoints: data.suffix(visibleDataCount), fillArea: false, bottomPadding: bottomPadding)
                .stroke(lineColor, style: StrokeStyle(lineWidth: lineWidth, lineCap: .round, lineJoin: .round))
        }
        .frame(maxWidth: .infinity)
        .padding(4)
    }
}

#Preview {
    VStack(spacing: 20) {
        // 선만 그리기
        LineChartView(
            data: [1, 2, 4, 3, 2, 5, 1, 2, 4, 5],
            lineColor: Color.orange,
            lineWidth: 3
        )
    }
    .padding()
}
