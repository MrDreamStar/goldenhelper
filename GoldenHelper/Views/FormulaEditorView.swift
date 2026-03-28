//
//  FormulaEditorView.swift
//  GoldenHelper
//
//  公式编辑器视图
//

import Foundation
import SwiftUI

struct FormulaEditorView: View {
    @Environment(\.presentationMode) var presentationMode
    @Environment(\.colorScheme) var colorScheme
    
    let formula: Formula?
    let onSave: (Formula) -> Void
    
    @State private var name: String = ""
    @State private var expression: String = ""
    @State private var description: String = ""
    @State private var variables: [FormulaVariable] = []
    @State private var validationMessage: String?
    @State private var showValidationAlert = false
    
    var isEditing: Bool {
        formula != nil
    }
    
    var body: some View {
        NavigationView {
            contentView
        }
    }
    
    private var contentView: some View {
        ScrollView {
            VStack(spacing: 20) {
                nameSection
                expressionSection
                descriptionSection
                variablesSection
            }
            .padding(20)
        }
        .background(Theme.backgroundGradient(for: colorScheme).ignoresSafeArea())
        .navigationTitle(isEditing ? "编辑公式" : "新建公式")
        .navigationBarTitleDisplayMode(.inline)
        .navigationBarItems(
            leading: cancelButton,
            trailing: saveButton
        )
        .alert(isPresented: $showValidationAlert) {
            Alert(
                title: Text("保存失败"),
                message: Text(validationMessage ?? "请检查公式配置"),
                dismissButton: .default(Text("知道了"))
            )
        }
        .onAppear {
            if let formula = formula {
                name = formula.name
                expression = formula.expression
                description = formula.description
                variables = formula.variables
            }
        }
    }
    
    private var cancelButton: some View {
        Button("取消") {
            presentationMode.wrappedValue.dismiss()
        }
        .foregroundColor(Theme.secondaryText(for: colorScheme))
    }
    
    private var saveButton: some View {
        Button("保存") {
            saveFormula()
        }
        .font(.system(size: 17, weight: .semibold))
        .foregroundColor(Theme.primaryColor)
    }
    
    private var nameSection: some View {
        VStack(alignment: .leading, spacing: 8) {
            Text("公式名称")
                .font(.system(size: 13, weight: .semibold))
                .foregroundColor(Theme.secondaryText(for: colorScheme))
            
            TextField("例如：净收益计算", text: $name)
                .font(.system(size: 15))
                .foregroundColor(Theme.primaryText(for: colorScheme))
                .autocapitalization(.none)
                .disableAutocorrection(true)
                .inputFieldStyle()
        }
    }
    
    private var expressionSection: some View {
        VStack(alignment: .leading, spacing: 8) {
            Text("公式表达式")
                .font(.system(size: 13, weight: .semibold))
                .foregroundColor(Theme.secondaryText(for: colorScheme))
            
            TextField("例如：(a - b) * c - d", text: $expression)
                .font(.system(size: 15))
                .foregroundColor(Theme.primaryText(for: colorScheme))
                .autocapitalization(.none)
                .disableAutocorrection(true)
                .inputFieldStyle()
            
            Text("使用英文变量名，例如 cost、price、amount")
                .font(.system(size: 12))
                .foregroundColor(Theme.secondaryText(for: colorScheme).opacity(0.7))
        }
    }
    
    private var descriptionSection: some View {
        VStack(alignment: .leading, spacing: 8) {
            Text("描述（可选）")
                .font(.system(size: 13, weight: .semibold))
                .foregroundColor(Theme.secondaryText(for: colorScheme))
            
            TextField("简要描述公式用途", text: $description)
                .font(.system(size: 15))
                .foregroundColor(Theme.primaryText(for: colorScheme))
                .autocapitalization(.none)
                .disableAutocorrection(true)
                .inputFieldStyle()
        }
    }
    
    private var variablesSection: some View {
        VStack(alignment: .leading, spacing: 12) {
            HStack {
                Text("变量定义")
                    .font(.system(size: 13, weight: .semibold))
                    .foregroundColor(Theme.secondaryText(for: colorScheme))
                
                Spacer()
                
                Button(action: addVariable) {
                    Text("+ 添加变量")
                        .font(.system(size: 12, weight: .semibold))
                        .foregroundColor(Theme.primaryColor)
                        .padding(.horizontal, 8)
                        .padding(.vertical, 4)
                        .background(Theme.primaryColor.opacity(0.1))
                        .cornerRadius(6)
                }
            }
            
            ForEach(variables.indices, id: \.self) { index in
                variableRow(at: index)
            }
        }
    }
    
    private func variableRow(at index: Int) -> some View {
        HStack(spacing: 10) {
            TextField("变量名", text: $variables[index].name)
                .font(.system(size: 14))
                .foregroundColor(Theme.primaryText(for: colorScheme))
                .autocapitalization(.none)
                .disableAutocorrection(true)
                .padding(.horizontal, 12)
                .frame(height: 40)
                .background(Theme.inputBackground(for: colorScheme))
                .cornerRadius(8)
            
            Button(action: { removeVariable(at: index) }) {
                Image(systemName: "xmark")
                    .font(.system(size: 12, weight: .medium))
                    .foregroundColor(Theme.positiveColor)
                    .frame(width: 24, height: 24)
                    .background(Theme.positiveColor.opacity(0.1))
                    .cornerRadius(12)
            }
        }
    }
    
    private func addVariable() {
        withAnimation {
            variables.append(FormulaVariable(name: "", label: ""))
        }
    }
    
    private func removeVariable(at index: Int) {
        withAnimation {
            variables.remove(at: index)
        }
    }
    
    private func saveFormula() {
        let trimmedName = name.trimmingCharacters(in: .whitespacesAndNewlines)
        let trimmedExpression = expression.trimmingCharacters(in: .whitespacesAndNewlines)
        
        guard !trimmedName.isEmpty else {
            showValidationError("请输入公式名称")
            return
        }
        
        guard !trimmedExpression.isEmpty else {
            showValidationError("请输入公式表达式")
            return
        }
        
        let sanitizedVariables = variables.map {
            FormulaVariable(
                name: $0.name.trimmingCharacters(in: .whitespacesAndNewlines),
                label: $0.name.trimmingCharacters(in: .whitespacesAndNewlines),
                value: $0.value
            )
        }
        
        guard let validationError = validateFormula(
            expression: trimmedExpression,
            variables: sanitizedVariables
        ) else {
            let newFormula = Formula(
                name: trimmedName,
                expression: trimmedExpression,
                description: description.trimmingCharacters(in: .whitespacesAndNewlines),
                variables: sanitizedVariables
            )
            
            onSave(newFormula)
            presentationMode.wrappedValue.dismiss()
            return
        }
        
        showValidationError(validationError)
    }
    
    private func showValidationError(_ message: String) {
        validationMessage = message
        showValidationAlert = true
    }
    
    private func validateFormula(expression: String, variables: [FormulaVariable]) -> String? {
        let identifierPattern = "^[A-Za-z_][A-Za-z0-9_]*$"
        let identifierRegex = try? NSRegularExpression(pattern: identifierPattern)
        
        if variables.contains(where: { $0.name.isEmpty }) {
            return "变量名不能为空"
        }
        
        if variables.contains(where: {
            identifierRegex?.firstMatch(
                in: $0.name,
                range: NSRange(location: 0, length: $0.name.utf16.count)
            ) == nil
        }) {
            return "变量名只能使用英文、数字和下划线，且不能以数字开头"
        }
        
        let variableNames = variables.map(\.name)
        if Set(variableNames).count != variableNames.count {
            return "变量名不能重复"
        }
        
        if !isBalanced(expression: expression) {
            return "公式括号不匹配"
        }
        
        let tokenPattern = "[A-Za-z_][A-Za-z0-9_]*"
        let tokenRegex = try? NSRegularExpression(pattern: tokenPattern)
        let expressionRange = NSRange(location: 0, length: expression.utf16.count)
        let referencedVariables = tokenRegex?
            .matches(in: expression, range: expressionRange)
            .compactMap { match -> String? in
                guard let range = Range(match.range, in: expression) else { return nil }
                return String(expression[range])
            } ?? []
        
        let undefinedVariables = Set(referencedVariables).subtracting(variableNames)
        if !undefinedVariables.isEmpty {
            return "公式中存在未定义变量：\(undefinedVariables.sorted().joined(separator: ", "))"
        }
        
        let allowedCharacterPattern = "^[A-Za-z0-9_+\\-*/().\\s]+$"
        let allowedCharacterRegex = try? NSRegularExpression(pattern: allowedCharacterPattern)
        if allowedCharacterRegex?.firstMatch(in: expression, range: expressionRange) == nil {
            return "公式只能包含英文变量、数字、空格和 +-*/() 运算符"
        }
        
        if expression.contains("**") || expression.contains("//") {
            return "当前公式仅支持 +、-、*、/ 四则运算"
        }
        
        let testVariables = variables.map { FormulaVariable(name: $0.name, label: $0.label, value: 1) }
        guard FormulaEvaluator.evaluate(expression: expression, variables: testVariables) != nil else {
            return "公式格式无效，请检查表达式写法"
        }
        
        return nil
    }
    
    private func isBalanced(expression: String) -> Bool {
        var stackCount = 0
        for character in expression {
            if character == "(" {
                stackCount += 1
            } else if character == ")" {
                stackCount -= 1
                if stackCount < 0 {
                    return false
                }
            }
        }
        return stackCount == 0
    }
}

struct FormulaEditorView_Previews: PreviewProvider {
    static var previews: some View {
        FormulaEditorView(formula: nil) { _ in }
    }
}
