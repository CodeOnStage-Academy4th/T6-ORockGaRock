//
//  LineShape.swift
//  UpAndDown
//
//  Created by 양시준 on 8/8/25.
//

import SwiftUI

struct LineShape: Shape {
    var dataPoints: [Double]
    var fillArea: Bool = false
    var bottomPadding: CGFloat = 0.2 // 아래쪽 여유 공간 비율 (0.0 ~ 1.0)

    func path(in rect: CGRect) -> Path {
        var path = Path()

        // 데이터가 없거나 하나만 있으면 그리지 않음
        guard dataPoints.count > 1 else {
            return path
        }

        let maxValue = dataPoints.max() ?? 1.0
        let minValue = dataPoints.min() ?? 0.0
        let range = maxValue - minValue

        // 실제 차트 영역 높이 (하단 패딩 제외)
        let chartHeight = rect.height * (1 - bottomPadding)

        let stepX = rect.width / CGFloat(dataPoints.count - 1)

        // 첫 번째 점부터 시작
        let firstNormalizedPoint = range == 0 ? 0.5 : (dataPoints[0] - minValue) / range
        let firstY = chartHeight * (1 - CGFloat(firstNormalizedPoint))
        let firstX: CGFloat = 0

        if fillArea {
            // 채우기용 패스: 하단 왼쪽 모서리에서 시작
            path.move(to: CGPoint(x: firstX, y: rect.height))
            path.addLine(to: CGPoint(x: firstX, y: firstY))
        } else {
            // 선만 그릴 때
            path.move(to: CGPoint(x: firstX, y: firstY))
        }

        // 모든 데이터 포인트를 연결
        for (index, point) in dataPoints.enumerated() {
            // 0으로 나누는 것을 방지
            let normalizedPoint = range == 0 ? 0.5 : (point - minValue) / range
            let y = chartHeight * (1 - CGFloat(normalizedPoint))
            let x = stepX * CGFloat(index)

            if index == 0 && !fillArea {
                continue // 이미 move(to:)로 처리됨
            } else {
                path.addLine(to: CGPoint(x: x, y: y))
            }
        }

        if fillArea {
            // 채우기를 위해 마지막 점에서 하단 오른쪽 모서리로, 그리고 시작점으로 돌아가기
            let lastX = stepX * CGFloat(dataPoints.count - 1)
            path.addLine(to: CGPoint(x: lastX, y: rect.height))
            path.addLine(to: CGPoint(x: firstX, y: rect.height))
            path.closeSubpath()
        }

        return path
    }
}

#Preview {
    VStack(spacing: 20) {
        // 선만 그리기
        LineShape(dataPoints: [0, 1, 0.5, 1])
            .stroke(Color.blue, lineWidth: 2)

        // 채우기 포함 (기본 여유 공간)
        LineShape(dataPoints: [0, 1, 0.5, 1], fillArea: true)
            .fill(LinearGradient(colors: [Color.orange.opacity(0.3), Color.clear], startPoint: .top, endPoint: .bottom))

        // 채우기 포함 (더 많은 여유 공간)
        LineShape(dataPoints: [0, 1, 0.5, 1], fillArea: true, bottomPadding: 0.4)
            .fill(LinearGradient(colors: [Color.green.opacity(0.3), Color.clear], startPoint: .top, endPoint: .bottom))
    }
    .padding()
}
