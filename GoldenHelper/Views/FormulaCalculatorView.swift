//
//  FormulaCalculatorView.swift
//  GoldenHelper
//
//  公式计算视图
//

import SwiftUI

struct FormulaCalculatorView: View {
    @Environment(\.presentationMode) var presentationMode
    @Environment(\.colorScheme) var colorScheme
    
    let formula: Formula
    let onComplete: (Double, [FormulaVariable]) -> Void
    
    @State private var variables: [FormulaVariable] = []
    @State private var variableInputs: [String] = []
    
    var calculatedResult: String {
        guard let result = FormulaEvaluator.evaluate(expression: formula.expression, variables: variables) else {
            return "计算错误"
        }
        return AppState.DecimalDisplayFormatter.string(from: result, minimumFractionDigits: 4, maximumFractionDigits: 4)
    }
    
    var body: some View {
        NavigationView {
            ScrollView {
                VStack(spacing: 20) {
                    // 公式表达式
                    VStack(alignment: .leading, spacing: 8) {
                        Text("公式")
                            .font(.system(size: 13, weight: .semibold))
                            .foregroundColor(Theme.secondaryText(for: colorScheme))
                        
                        Text(formula.expression)
                            .font(.system(size: 14, weight: .medium, design: .monospaced))
                            .foregroundColor(Theme.primaryColor)
                            .padding(12)
                            .frame(maxWidth: .infinity, alignment: .leading)
                            .background(Theme.primaryColor.opacity(0.08))
                            .cornerRadius(8)
                    }
                    
                    // 变量输入
                    VStack(alignment: .leading, spacing: 12) {
                        Text("变量值")
                            .font(.system(size: 13, weight: .semibold))
                            .foregroundColor(Theme.secondaryText(for: colorScheme))
                        
                        ForEach(Array(variables.enumerated()), id: \.element.id) { index, variable in
                            VStack(alignment: .leading, spacing: 6) {
                                Text(variable.label.isEmpty ? variable.name : variable.label)
                                    .font(.system(size: 13))
                                    .foregroundColor(Theme.secondaryText(for: colorScheme))
                                
                                HStack {
                                    TextField("请输入数值", text: Binding(
                                        get: {
                                            variableInputs.indices.contains(index) ? variableInputs[index] : ""
                                        },
                                        set: { newValue in
                                            let normalizedValue = NumericInputFormatter.normalized(newValue)
                                            if variableInputs.indices.contains(index) {
                                                variableInputs[index] = normalizedValue
                                            }
                                            variables[index].value = Double(normalizedValue) ?? 0
                                        }
                                    ))
                                    .keyboardType(.numbersAndPunctuation)
                                    .font(.system(size: 16))
                                    .foregroundColor(Theme.primaryText(for: colorScheme))
                                    .autocapitalization(.none)
                                    .disableAutocorrection(true)
                                }
                                .inputFieldStyle()
                            }
                        }
                    }
                    
                    // 计算结果
                    VStack(spacing: 8) {
                        Text("计算结果")
                            .font(.system(size: 14))
                            .foregroundColor(Theme.secondaryText(for: colorScheme))
                        
                        Text(calculatedResult)
                            .font(.system(size: 36, weight: .bold))
                            .foregroundColor(Theme.primaryColor)
                    }
                    .padding(.vertical, 24)
                    .frame(maxWidth: .infinity)
                    .background(Theme.cardBackground(for: colorScheme))
                    .cornerRadius(Theme.cardCornerRadius)
                    .shadow(color: Theme.cardShadow(for: colorScheme), radius: 6, x: 0, y: 2)
                }
                .padding(20)
            }
            .background(Theme.backgroundGradient(for: colorScheme).ignoresSafeArea())
            .navigationTitle(formula.name)
            .navigationBarTitleDisplayMode(.inline)
            .toolbar {
                ToolbarItem(placement: .navigationBarTrailing) {
                    Button("完成") {
                        if let result = Double(calculatedResult) {
                            onComplete(result, variables)
                        }
                        presentationMode.wrappedValue.dismiss()
                    }
                    .font(.system(size: 17, weight: .semibold))
                    .foregroundColor(Theme.primaryColor)
                }
            }
            .onAppear {
                loadVariables()
            }
            .onTapGesture {
                hideKeyboard()
            }
        }
    }
    
    private func loadVariables() {
        if let savedVars = formula.savedVariables, !savedVars.isEmpty {
            variables = savedVars
        } else {
            variables = formula.variables.map { v in
                FormulaVariable(name: v.name, label: v.label, value: 0, unit: v.unit)
            }
        }
        
        variableInputs = variables.map { variable in
            variable.value == 0 ? "" : formatNumericInput(variable.value)
        }
    }
    
    private func formatNumericInput(_ value: Double) -> String {
        let formatter = NumberFormatter()
        formatter.numberStyle = .decimal
        formatter.usesGroupingSeparator = false
        formatter.minimumFractionDigits = 0
        formatter.maximumFractionDigits = 8
        formatter.roundingMode = .halfUp
        formatter.decimalSeparator = "."
        
        return formatter.string(from: NSNumber(value: value)) ?? String(value)
    }
    
    private func hideKeyboard() {
        UIApplication.shared.sendAction(#selector(UIResponder.resignFirstResponder), to: nil, from: nil, for: nil)
    }
}

struct FormulaCalculatorView_Previews: PreviewProvider {
    static var previews: some View {
        FormulaCalculatorView(
            formula: Formula(
                name: "测试公式",
                expression: "a + b * c",
                description: "测试",
                variables: [
                    FormulaVariable(name: "a", label: "变量A"),
                    FormulaVariable(name: "b", label: "变量B"),
                    FormulaVariable(name: "c", label: "变量C")
                ]
            )
        ) { _, _ in }
    }
}
