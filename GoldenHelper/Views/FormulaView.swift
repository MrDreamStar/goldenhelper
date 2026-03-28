//
//  FormulaView.swift
//  GoldenHelper
//
//  通用公式计算器视图
//

import SwiftUI

struct FormulaView: View {
    @EnvironmentObject var appState: AppState
    @Environment(\.colorScheme) var colorScheme
    
    @State private var showEditor = false
    @State private var showCalculator = false
    @State private var showDeleteConfirm = false
    @State private var editingFormula: Formula?
    @State private var selectedFormula: Formula?
    @State private var deleteTarget: Formula?
    
    var body: some View {
        ZStack(alignment: .bottomTrailing) {
            ScrollView {
                VStack(spacing: 20) {
                    // 我的公式列表
                    if !appState.formulas.isEmpty {
                        myFormulasSection
                    } else {
                        EmptyStateView(
                            icon: "📝",
                            title: "暂无自定义公式",
                            description: "点击下方按钮创建您的第一个公式"
                        )
                    }
                    
                    // 预设公式模板
                    presetTemplatesSection
                }
                .padding(.horizontal, 20)
                .padding(.top, 20)
                .padding(.bottom, 100)
            }
            .background(Theme.backgroundGradient(for: colorScheme).ignoresSafeArea())
            
            // 浮动添加按钮
            FloatingActionButton {
                editingFormula = nil
                showEditor = true
            }
            .padding(.trailing, 24)
            .padding(.bottom, 24)
        }
        .navigationTitle("通用公式计算器")
        .navigationBarTitleDisplayMode(.inline)
        .sheet(isPresented: $showEditor) {
            FormulaEditorView(formula: editingFormula) { formula in
                if let editing = editingFormula,
                   appState.formulas.contains(where: { $0.id == editing.id }) {
                    // 编辑现有公式
                    var updated = formula
                    updated.id = editing.id
                    appState.updateFormula(updated)
                } else {
                    // 新建公式（包括从模板创建）
                    appState.addFormula(formula)
                }
            }
        }
        .sheet(isPresented: $showCalculator) {
            if let formula = selectedFormula {
                FormulaCalculatorView(formula: formula) { result, variables in
                    appState.updateFormulaResult(id: formula.id, result: result, variables: variables)
                }
            }
        }
        .alert(isPresented: $showDeleteConfirm) {
            Alert(
                title: Text("确认删除"),
                message: Text("确定要删除公式「\(deleteTarget?.name ?? "")」吗？"),
                primaryButton: .destructive(Text("删除"), action: {
                    if let target = deleteTarget {
                        appState.deleteFormula(target)
                    }
                }),
                secondaryButton: .cancel(Text("取消"))
            )
        }
    }
    
    // MARK: - 我的公式列表
    private var myFormulasSection: some View {
        VStack(alignment: .leading, spacing: 12) {
            SectionHeader(title: "我的公式")
            
            ForEach(appState.formulas) { formula in
                FormulaCard(
                    formula: formula,
                    onTap: {
                        selectedFormula = formula
                        showCalculator = true
                    },
                    onEdit: {
                        editingFormula = formula
                        showEditor = true
                    },
                    onDelete: {
                        deleteTarget = formula
                        showDeleteConfirm = true
                    }
                )
            }
        }
    }
    
    // MARK: - 预设公式模板
    private var presetTemplatesSection: some View {
        VStack(alignment: .leading, spacing: 12) {
            SectionHeader(title: "预设公式模板")
            
            ForEach(FormulaTemplate.presets, id: \.name) { template in
                PresetTemplateCard(template: template) {
                    editingFormula = Formula(
                        name: template.name,
                        expression: template.expression,
                        description: template.description,
                        variables: template.variables
                    )
                    showEditor = true
                }
            }
        }
    }
}

// MARK: - 公式卡片
struct FormulaCard: View {
    let formula: Formula
    let onTap: () -> Void
    let onEdit: () -> Void
    let onDelete: () -> Void
    
    @Environment(\.colorScheme) var colorScheme
    
    var body: some View {
        Button(action: onTap) {
            VStack(alignment: .leading, spacing: 8) {
                // 标题行
                HStack {
                    Text(formula.name)
                        .font(.system(size: 17, weight: .semibold))
                        .foregroundColor(Theme.primaryText(for: colorScheme))
                        .lineLimit(1)
                    
                    Spacer()
                    
                    HStack(spacing: 8) {
                        Button(action: onEdit) {
                            Image(systemName: "pencil")
                                .font(.system(size: 14))
                                .foregroundColor(Theme.primaryColor)
                                .frame(width: 32, height: 32)
                                .background(Theme.primaryColor.opacity(0.1))
                                .cornerRadius(8)
                        }
                        
                        Button(action: onDelete) {
                            Image(systemName: "trash")
                                .font(.system(size: 14))
                                .foregroundColor(Theme.positiveColor)
                                .frame(width: 32, height: 32)
                                .background(Theme.positiveColor.opacity(0.1))
                                .cornerRadius(8)
                        }
                    }
                }
                
                // 描述
                Text(formula.description.isEmpty ? "点击进行计算" : formula.description)
                    .font(.system(size: 13))
                    .foregroundColor(Theme.secondaryText(for: colorScheme))
                    .lineLimit(1)
                
                // 上次计算结果
                if let lastResult = formula.lastResult {
                    HStack {
                        Text("计算结果：")
                            .font(.system(size: 12))
                            .foregroundColor(Theme.secondaryText(for: colorScheme))
                        
                        Text(String(format: "%.4f", lastResult))
                            .font(.system(size: 16, weight: .bold))
                            .foregroundColor(Theme.negativeColor)
                    }
                    .padding(10)
                    .frame(maxWidth: .infinity, alignment: .leading)
                    .background(
                        RoundedRectangle(cornerRadius: 8)
                            .fill(Theme.negativeColor.opacity(0.1))
                    )
                    .overlay(
                        RoundedRectangle(cornerRadius: 8)
                            .stroke(Theme.negativeColor.opacity(0.3), lineWidth: 1)
                            .padding(.leading, -3)
                            .mask(
                                HStack {
                                    Rectangle().frame(width: 3)
                                    Spacer()
                                }
                            )
                    )
                    .padding(.top, 4)
                }
            }
            .padding(16)
            .cardStyle()
        }
        .buttonStyle(PlainButtonStyle())
    }
}

// MARK: - 预设模板卡片
struct PresetTemplateCard: View {
    let template: FormulaTemplate
    let onTap: () -> Void
    
    @Environment(\.colorScheme) var colorScheme
    
    var body: some View {
        Button(action: onTap) {
            HStack(spacing: 16) {
                // 图标
                ZStack {
                    RoundedRectangle(cornerRadius: 12)
                        .fill(Theme.primaryColor.opacity(0.1))
                        .frame(width: 44, height: 44)
                    
                    Text(template.icon)
                        .font(.system(size: 20))
                }
                
                // 内容
                VStack(alignment: .leading, spacing: 4) {
                    Text(template.name)
                        .font(.system(size: 15, weight: .semibold))
                        .foregroundColor(Theme.primaryText(for: colorScheme))
                    
                    Text(template.expression)
                        .font(.system(size: 12))
                        .foregroundColor(Theme.secondaryText(for: colorScheme))
                        .lineLimit(1)
                }
                
                Spacer()
                
                Image(systemName: "chevron.right")
                    .font(.system(size: 12, weight: .medium))
                    .foregroundColor(Theme.secondaryText(for: colorScheme).opacity(0.5))
            }
            .padding(16)
            .cardStyle()
        }
        .buttonStyle(PlainButtonStyle())
    }
}

struct FormulaView_Previews: PreviewProvider {
    static var previews: some View {
        NavigationView {
            FormulaView()
                .environmentObject(AppState())
        }
    }
}
