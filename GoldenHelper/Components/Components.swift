//
//  Components.swift
//  GoldenHelper
//
//  通用UI组件
//

import SwiftUI

// MARK: - 功能卡片
struct FeatureCard: View {
    let icon: String
    let title: String
    let description: String
    let gradient: LinearGradient
    let action: () -> Void
    
    @Environment(\.colorScheme) var colorScheme
    
    var body: some View {
        Button(action: action) {
            HStack(spacing: 16) {
                // 图标
                ZStack {
                    RoundedRectangle(cornerRadius: Theme.iconCornerRadius)
                        .fill(gradient)
                        .frame(width: 52, height: 52)
                    
                    Text(icon)
                        .font(.system(size: 24))
                }
                
                // 内容
                VStack(alignment: .leading, spacing: 4) {
                    Text(title)
                        .font(.system(size: 17, weight: .semibold))
                        .foregroundColor(Theme.primaryText(for: colorScheme))
                    
                    Text(description)
                        .font(.system(size: 13))
                        .foregroundColor(Theme.secondaryText(for: colorScheme))
                        .lineLimit(1)
                }
                
                Spacer()
                
                // 箭头
                Image(systemName: "chevron.right")
                    .font(.system(size: 14, weight: .medium))
                    .foregroundColor(Theme.secondaryText(for: colorScheme).opacity(0.5))
            }
            .padding(20)
            .cardStyle()
        }
        .buttonStyle(PlainButtonStyle())
    }
}

// MARK: - 输入组件
struct LabeledInput: View {
    let label: String
    @Binding var text: String
    let placeholder: String
    let unit: String
    let keyboardType: UIKeyboardType
    
    @Environment(\.colorScheme) var colorScheme
    
    init(label: String, text: Binding<String>, placeholder: String = "", unit: String = "", keyboardType: UIKeyboardType = .numbersAndPunctuation) {
        self.label = label
        self._text = text
        self.placeholder = placeholder
        self.unit = unit
        self.keyboardType = keyboardType
    }
    
    var body: some View {
        VStack(alignment: .leading, spacing: 8) {
            Text(label)
                .font(.system(size: 13))
                .foregroundColor(Theme.secondaryText(for: colorScheme))
            
            HStack {
                TextField(placeholder, text: $text)
                    .keyboardType(keyboardType)
                    .font(.system(size: 16))
                    .foregroundColor(Theme.primaryText(for: colorScheme))
                
                if !unit.isEmpty {
                    Text(unit)
                        .font(.system(size: 14))
                        .foregroundColor(Theme.secondaryText(for: colorScheme))
                }
            }
            .inputFieldStyle()
        }
    }
}

// MARK: - 分段选择器
struct SegmentedPicker<T: Hashable>: View {
    let options: [T]
    @Binding var selection: T
    let titleForOption: (T) -> String
    
    @Environment(\.colorScheme) var colorScheme
    
    var body: some View {
        HStack(spacing: 4) {
            ForEach(options, id: \.self) { option in
                Button {
                    withAnimation(.easeInOut(duration: 0.2)) {
                        selection = option
                    }
                } label: {
                    Text(titleForOption(option))
                        .font(.system(size: 14, weight: selection == option ? .semibold : .regular))
                        .foregroundColor(selection == option ? Theme.primaryText(for: colorScheme) : Theme.secondaryText(for: colorScheme))
                        .frame(maxWidth: .infinity)
                        .frame(height: 40)
                        .background(
                            RoundedRectangle(cornerRadius: 10)
                                .fill(selection == option ? Theme.cardBackground(for: colorScheme) : Color.clear)
                                .shadow(color: selection == option ? Theme.cardShadow(for: colorScheme) : .clear, radius: 4, x: 0, y: 2)
                        )
                }
                .buttonStyle(PlainButtonStyle())
            }
        }
        .padding(4)
        .background(Theme.inputBackground(for: colorScheme))
        .cornerRadius(Theme.inputCornerRadius)
    }
}

// MARK: - 信息行
struct InfoRow: View {
    let label: String
    let value: String
    let isHighlighted: Bool
    
    @Environment(\.colorScheme) var colorScheme
    
    init(label: String, value: String, isHighlighted: Bool = false) {
        self.label = label
        self.value = value
        self.isHighlighted = isHighlighted
    }
    
    var body: some View {
        HStack {
            Text(label)
                .font(.system(size: 14))
                .foregroundColor(Theme.secondaryText(for: colorScheme))
            
            Spacer()
            
            Text(value)
                .font(.system(size: 15, weight: .semibold))
                .foregroundColor(Theme.primaryText(for: colorScheme))
        }
        .padding(.vertical, 12)
        .padding(.horizontal, isHighlighted ? 20 : 0)
        .background(
            isHighlighted ?
            RoundedRectangle(cornerRadius: 12)
                .fill(Theme.goldColor.opacity(0.1))
            : nil
        )
    }
}

// MARK: - 区块标题
struct SectionHeader: View {
    let title: String
    
    @Environment(\.colorScheme) var colorScheme
    
    var body: some View {
        Text(title)
            .font(.system(size: 13, weight: .semibold))
            .foregroundColor(Theme.secondaryText(for: colorScheme))
            .tracking(1)
            .padding(.leading, 4)
    }
}

// MARK: - 主按钮
struct PrimaryButton: View {
    let title: String
    let gradient: LinearGradient
    let action: () -> Void
    
    var body: some View {
        Button(action: action) {
            Text(title)
                .font(.system(size: 16, weight: .semibold))
                .foregroundColor(.white)
                .frame(maxWidth: .infinity)
                .frame(height: 48)
                .background(gradient)
                .cornerRadius(Theme.buttonCornerRadius)
                .shadow(color: Theme.primaryColor.opacity(0.3), radius: 8, x: 0, y: 4)
        }
    }
}

// MARK: - 浮动操作按钮
struct FloatingActionButton: View {
    let action: () -> Void
    
    var body: some View {
        Button(action: action) {
            ZStack {
                Circle()
                    .fill(Theme.primaryGradient)
                    .frame(width: 56, height: 56)
                    .shadow(color: Theme.primaryColor.opacity(0.4), radius: 8, x: 0, y: 4)
                
                Image(systemName: "plus")
                    .font(.system(size: 24, weight: .medium))
                    .foregroundColor(.white)
            }
        }
    }
}

// MARK: - 空状态视图
struct EmptyStateView: View {
    let icon: String
    let title: String
    let description: String
    
    @Environment(\.colorScheme) var colorScheme
    
    var body: some View {
        VStack(spacing: 16) {
            Text(icon)
                .font(.system(size: 48))
            
            Text(title)
                .font(.system(size: 18, weight: .semibold))
                .foregroundColor(Theme.primaryText(for: colorScheme))
            
            Text(description)
                .font(.system(size: 14))
                .foregroundColor(Theme.secondaryText(for: colorScheme))
                .multilineTextAlignment(.center)
        }
        .padding(60)
    }
}

// MARK: - 设置项
struct SettingRow: View {
    let icon: String
    let title: String
    let subtitle: String?
    let trailing: AnyView?
    
    @Environment(\.colorScheme) var colorScheme
    
    init(icon: String, title: String, subtitle: String? = nil, trailing: AnyView? = nil) {
        self.icon = icon
        self.title = title
        self.subtitle = subtitle
        self.trailing = trailing
    }
    
    var body: some View {
        HStack(spacing: 12) {
            Text(icon)
                .font(.system(size: 20))
            
            VStack(alignment: .leading, spacing: 2) {
                Text(title)
                    .font(.system(size: 16, weight: .medium))
                    .foregroundColor(Theme.primaryText(for: colorScheme))
                
                if let subtitle = subtitle {
                    Text(subtitle)
                        .font(.system(size: 13))
                        .foregroundColor(Theme.secondaryText(for: colorScheme))
                }
            }
            
            Spacer()
            
            if let trailing = trailing {
                trailing
            }
        }
        .padding(.vertical, 12)
    }
}

// MARK: - 公式表达式计算器
struct FormulaEvaluator {
    static func evaluate(expression: String, variables: [FormulaVariable]) -> Double? {
        var expr = expression.replacingOccurrences(of: " ", with: "")
        
        // 按变量名长度降序排序，避免短变量名先替换导致的问题
        let sortedVars = variables.sorted { $0.name.count > $1.name.count }
        
        for variable in sortedVars {
            guard !variable.name.isEmpty else { continue }
            expr = expr.replacingOccurrences(of: variable.name, with: String(variable.value))
        }
        
        return evaluateExpression(expr)
    }
    
    private static func evaluateExpression(_ expr: String) -> Double? {
        var expression = expr
        var maxIterations = 100
        
        // 处理括号
        while expression.contains("(") && maxIterations > 0 {
            maxIterations -= 1
            
            guard let openIndex = expression.lastIndex(of: "("),
                  let closeIndex = expression[openIndex...].firstIndex(of: ")") else {
                break
            }
            
            let innerStart = expression.index(after: openIndex)
            let inner = String(expression[innerStart..<closeIndex])
            
            guard let innerResult = evaluateSimple(inner) else { return nil }
            
            expression = String(expression[..<openIndex]) + String(innerResult) + String(expression[expression.index(after: closeIndex)...])
        }
        
        return evaluateSimple(expression)
    }
    
    private static func evaluateSimple(_ expr: String) -> Double? {
        var numbers: [Double] = []
        var operators: [Character] = []
        var currentNum = ""
        var expectNumber = true
        
        for char in expr {
            if (char == "-" || char == "+") && expectNumber {
                currentNum.append(char)
            } else if char == "+" || char == "-" || char == "*" || char == "/" {
                if !currentNum.isEmpty {
                    if let num = Double(currentNum) {
                        numbers.append(num)
                    }
                    currentNum = ""
                }
                operators.append(char)
                expectNumber = true
            } else {
                currentNum.append(char)
                expectNumber = false
            }
        }
        
        if !currentNum.isEmpty {
            if let num = Double(currentNum) {
                numbers.append(num)
            }
        }
        
        guard !numbers.isEmpty else { return 0 }
        
        // 先处理乘除
        var i = 0
        while i < operators.count {
            if operators[i] == "*" || operators[i] == "/" {
                let left = numbers[i]
                let right = numbers[i + 1]
                let result: Double
                
                if operators[i] == "*" {
                    result = left * right
                } else {
                    result = right != 0 ? left / right : 0
                }
                
                numbers.remove(at: i + 1)
                numbers[i] = result
                operators.remove(at: i)
            } else {
                i += 1
            }
        }
        
        // 再处理加减
        var result = numbers[0]
        for j in 0..<operators.count {
            if operators[j] == "+" {
                result += numbers[j + 1]
            } else if operators[j] == "-" {
                result -= numbers[j + 1]
            }
        }
        
        return result
    }
}
