//
//  Theme.swift
//  GoldenHelper
//
//  主题和颜色定义
//

import SwiftUI

struct Theme {
    // MARK: - 主色调
    static let primaryColor = Color(red: 102/255, green: 126/255, blue: 234/255)
    static let secondaryColor = Color(red: 118/255, green: 75/255, blue: 162/255)
    static let goldColor = Color(red: 255/255, green: 215/255, blue: 0/255)
    static let goldSecondary = Color(red: 255/255, green: 179/255, blue: 71/255)
    
    // MARK: - 状态颜色
    static let positiveColor = Color(red: 239/255, green: 68/255, blue: 68/255)  // 红色表示盈利
    static let negativeColor = Color(red: 16/255, green: 185/255, blue: 129/255)  // 绿色表示亏损
    static let warningColor = Color.orange
    
    // MARK: - 渐变
    static let goldGradient = LinearGradient(
        colors: [goldColor, goldSecondary],
        startPoint: .topLeading,
        endPoint: .bottomTrailing
    )
    
    static let primaryGradient = LinearGradient(
        colors: [primaryColor, secondaryColor],
        startPoint: .topLeading,
        endPoint: .bottomTrailing
    )
    
    static let positiveGradient = LinearGradient(
        colors: [Color(red: 16/255, green: 185/255, blue: 129/255), Color(red: 5/255, green: 150/255, blue: 105/255)],
        startPoint: .topLeading,
        endPoint: .bottomTrailing
    )
    
    static let negativeGradient = LinearGradient(
        colors: [positiveColor, Color(red: 220/255, green: 38/255, blue: 38/255)],
        startPoint: .topLeading,
        endPoint: .bottomTrailing
    )
    
    // MARK: - 背景渐变
    static func backgroundGradient(for colorScheme: ColorScheme) -> LinearGradient {
        if colorScheme == .dark {
            return LinearGradient(
                colors: [
                    Color(red: 26/255, green: 26/255, blue: 46/255),
                    Color(red: 22/255, green: 33/255, blue: 62/255)
                ],
                startPoint: .top,
                endPoint: .bottom
            )
        } else {
            return LinearGradient(
                colors: [
                    Color(red: 248/255, green: 249/255, blue: 250/255),
                    Color(red: 233/255, green: 236/255, blue: 239/255)
                ],
                startPoint: .top,
                endPoint: .bottom
            )
        }
    }
    
    // MARK: - 卡片背景
    static func cardBackground(for colorScheme: ColorScheme) -> Color {
        colorScheme == .dark ? Color(red: 37/255, green: 37/255, blue: 66/255) : .white
    }
    
    static func inputBackground(for colorScheme: ColorScheme) -> Color {
        colorScheme == .dark ? Color(red: 26/255, green: 26/255, blue: 46/255) : Color(red: 248/255, green: 249/255, blue: 250/255)
    }
    
    // MARK: - 文字颜色
    static func primaryText(for colorScheme: ColorScheme) -> Color {
        colorScheme == .dark ? Color(red: 248/255, green: 249/255, blue: 250/255) : Color(red: 26/255, green: 26/255, blue: 46/255)
    }
    
    static func secondaryText(for colorScheme: ColorScheme) -> Color {
        colorScheme == .dark ? Color(red: 173/255, green: 181/255, blue: 189/255) : Color(red: 108/255, green: 117/255, blue: 125/255)
    }
    
    // MARK: - 分隔线颜色
    static func dividerColor(for colorScheme: ColorScheme) -> Color {
        colorScheme == .dark ? Color(red: 61/255, green: 61/255, blue: 92/255) : Color(red: 233/255, green: 236/255, blue: 239/255)
    }
    
    // MARK: - 阴影
    static func cardShadow(for colorScheme: ColorScheme) -> Color {
        colorScheme == .dark ? Color.black.opacity(0.2) : Color.black.opacity(0.06)
    }
    
    // MARK: - 圆角
    static let cardCornerRadius: CGFloat = 16
    static let buttonCornerRadius: CGFloat = 12
    static let inputCornerRadius: CGFloat = 12
    static let iconCornerRadius: CGFloat = 14
}

// MARK: - 自适应颜色扩展
extension Color {
    static func adaptive(light: Color, dark: Color) -> Color {
        return Color(UIColor { traitCollection in
            traitCollection.userInterfaceStyle == .dark ? UIColor(dark) : UIColor(light)
        })
    }
}

// MARK: - 视图修饰符
struct CardStyle: ViewModifier {
    @Environment(\.colorScheme) var colorScheme
    
    func body(content: Content) -> some View {
        content
            .background(Theme.cardBackground(for: colorScheme))
            .cornerRadius(Theme.cardCornerRadius)
            .shadow(color: Theme.cardShadow(for: colorScheme), radius: 6, x: 0, y: 2)
    }
}

struct InputFieldStyle: ViewModifier {
    @Environment(\.colorScheme) var colorScheme
    
    func body(content: Content) -> some View {
        content
            .padding(.horizontal, 16)
            .frame(height: 48)
            .background(Theme.inputBackground(for: colorScheme))
            .cornerRadius(Theme.inputCornerRadius)
    }
}

extension View {
    func cardStyle() -> some View {
        modifier(CardStyle())
    }
    
    func inputFieldStyle() -> some View {
        modifier(InputFieldStyle())
    }
}
