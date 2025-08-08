//
//  LineShape.swift
//  UpAndDown
//
//  Created by 양시준 on 8/8/25.
//

import SwiftUI

struct LineShape: Shape {
    var dataPoints: [Double]
    
    func path(in rect: CGRect) -> Path {
        var path = Path()
        
        // 데이터가 없거나 하나만 있으면 그리지 않음
        guard dataPoints.count > 1 else {
            return path
        }

        let maxValue = dataPoints.max() ?? 1.0
        let minValue = dataPoints.min() ?? 0.0
        let range = maxValue - minValue
        
        let stepX = rect.width / CGFloat(dataPoints.count - 1)
        
        for (index, point) in dataPoints.enumerated() {
            // 0으로 나누는 것을 방지
            let normalizedPoint = range == 0 ? 0.5 : (point - minValue) / range
            let y = rect.height * (1 - CGFloat(normalizedPoint))
            let x = stepX * CGFloat(index)
            
            if index == 0 {
                path.move(to: CGPoint(x: x, y: y))
            } else {
                path.addLine(to: CGPoint(x: x, y: y))
            }
        }
        
        return path
    }
}

#Preview {
    LineShape(dataPoints: [0, 1, 0.5, 1])
        .stroke(Color.blue, lineWidth: 2)
}
