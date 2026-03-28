//
//  FormulaEditorView.swift
//  GoldenHelper
//
//  公式编辑器视图
//

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
                .inputFieldStyle()
            
            Text("使用变量名如 a, b, c 或自定义名称")
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
        guard !name.isEmpty else {
            return
        }
        guard !expression.isEmpty else {
            return
        }
        
        let newFormula = Formula(
            name: name,
            expression: expression,
            description: description,
            variables: variables
        )
        
        onSave(newFormula)
        presentationMode.wrappedValue.dismiss()
    }
}

struct FormulaEditorView_Previews: PreviewProvider {
    static var previews: some View {
        FormulaEditorView(formula: nil) { _ in }
    }
}
