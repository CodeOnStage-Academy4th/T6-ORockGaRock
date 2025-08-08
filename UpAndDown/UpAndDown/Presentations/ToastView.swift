//
//  ToastView.swift
//  UpAndDown
//
//  Created by kim yijun on 8/8/25.
//

import SwiftUI

struct ToastView: View {
    
    let title: String
    let description: String
    let isVisible: Bool
    
    var body: some View {
        if isVisible {
            VStack(spacing: 12) {
                // 제목
                Text(title)
                    .font(.system(size: 20, weight: .bold))
                    .foregroundColor(.white)
                    .multilineTextAlignment(.center)
                    .lineLimit(2)
                
                // 설명
                if !description.isEmpty {
                    Text(description)
                        .font(.system(size: 16, weight: .medium))
                        .foregroundColor(.white.opacity(0.9))
                        .multilineTextAlignment(.center)
                        .lineSpacing(2)
                        .lineLimit(4)
                }
            }
            .frame(width: 280, height: 160) // 고정 크기
            .background(
                RoundedRectangle(cornerRadius: 16)
                    .fill(Color.black.opacity(0.85))
                    .shadow(color: .black.opacity(0.3), radius: 10, x: 0, y: 5)
            )
            .scaleEffect(isVisible ? 1.0 : 0.8)
            .opacity(isVisible ? 1.0 : 0.0)
            .animation(.spring(response: 0.4, dampingFraction: 0.8), value: isVisible)
        }
    }
}

// 토스트 관리를 위한 ObservableObject
class ToastManager: ObservableObject {
    @Published var isVisible = false
    @Published var title = ""
    @Published var description = ""
    
    private var onComplete: (() -> Void)?
    
    func showToast(title: String, description: String = "", duration: Double = 3.0, onComplete: (() -> Void)? = nil) {
        self.title = title
        self.description = description
        self.onComplete = onComplete
        
        withAnimation {
            isVisible = true
        }
        
        DispatchQueue.main.asyncAfter(deadline: .now() + duration) {
            withAnimation {
                self.isVisible = false
            }
            
            // 애니메이션이 완료된 후 콜백 실행
            DispatchQueue.main.asyncAfter(deadline: .now() + 0.4) {
                self.onComplete?()
                self.onComplete = nil
            }
        }
    }
    
    // 기존 방식과의 호환성을 위한 메서드 (deprecated)
    func showToast(message: String, duration: Double = 3.0, onComplete: (() -> Void)? = nil) {
        showToast(title: message, description: "", duration: duration, onComplete: onComplete)
    }
}

#Preview {
    ZStack {
        Color.gray.opacity(0.1)
            .ignoresSafeArea()
        
        ToastView(title: "게임이 곧 시작됩니다", description: "", isVisible: true)
    }
}
