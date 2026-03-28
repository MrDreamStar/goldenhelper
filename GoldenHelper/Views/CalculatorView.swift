//
//  CalculatorView.swift
//  GoldenHelper
//
//  投资收益计算器视图
//

import SwiftUI

struct CalculatorView: View {
    @EnvironmentObject var appState: AppState
    @Environment(\.colorScheme) var colorScheme
    @Environment(\.presentationMode) var presentationMode
    
    // 输入状态
    @State private var currentHolding: String = ""
    @State private var costPrice: String = ""
    @State private var currentPrice: String = ""
    @State private var operationType: OperationType = .none
    @State private var operationAmount: String = ""
    @State private var feeMode: FeeMode = .percent
    @State private var feePercent: String = "0.02"
    @State private var fixedFee: String = "3"
    
    var body: some View {
        ScrollView {
            VStack(spacing: 20) {
                // 持仓信息
                holdingSection
                
                // 操作类型
                operationSection
                
                // 手续费设置
                feeSection
                
                // 计算结果
                resultSection
            }
            .padding(.horizontal, 20)
            .padding(.top, 20)
            .padding(.bottom, 40)
        }
        .background(Theme.backgroundGradient(for: colorScheme).ignoresSafeArea())
        .navigationTitle("投资收益计算器")
        .navigationBarTitleDisplayMode(.inline)
        .onAppear {
            loadData()
        }
        .onTapGesture {
            hideKeyboard()
        }
    }
    
    // MARK: - 持仓信息
    private var holdingSection: some View {
        VStack(alignment: .leading, spacing: 12) {
            SectionHeader(title: "持仓信息")
            
            VStack(spacing: 16) {
                LabeledInput(
                    label: "当前持仓",
                    text: $currentHolding,
                    placeholder: "请输入持仓数量",
                    unit: appState.weightUnitLabel
                )
                .onChange(of: currentHolding) { _ in
                    appState.setCalculatorHolding(currentHolding)
                }
                
                LabeledInput(
                    label: "成本均价",
                    text: $costPrice,
                    placeholder: "请输入成本价格",
                    unit: appState.priceUnitLabel
                )
                .onChange(of: costPrice) { _ in
                    appState.setCalculatorCostPrice(costPrice)
                }
                
                LabeledInput(
                    label: "实时价格",
                    text: $currentPrice,
                    placeholder: "请输入当前价格",
                    unit: appState.priceUnitLabel
                )
            }
            .padding(16)
            .cardStyle()
        }
    }
    
    // MARK: - 操作类型
    private var operationSection: some View {
        VStack(alignment: .leading, spacing: 12) {
            SectionHeader(title: "操作类型")
            
            VStack(spacing: 16) {
                SegmentedPicker(
                    options: OperationType.allCases,
                    selection: $operationType,
                    titleForOption: { $0.displayName }
                )
                
                if operationType != .none {
                    LabeledInput(
                        label: operationType == .add ? "加仓数量" : "减仓数量",
                        text: $operationAmount,
                        placeholder: "请输入操作数量",
                        unit: appState.weightUnitLabel
                    )
                }
            }
            .padding(16)
            .cardStyle()
        }
    }
    
    // MARK: - 手续费设置
    private var feeSection: some View {
        VStack(alignment: .leading, spacing: 12) {
            SectionHeader(title: "手续费设置")
            
            VStack(spacing: 16) {
                SegmentedPicker(
                    options: FeeMode.allCases,
                    selection: $feeMode,
                    titleForOption: { $0.displayName }
                )
                .onChange(of: feeMode) { _ in
                    appState.setFeeMode(feeMode)
                }
                
                if feeMode == .percent {
                    LabeledInput(
                        label: "手续费率",
                        text: $feePercent,
                        placeholder: "请输入费率",
                        unit: "%"
                    )
                    .onChange(of: feePercent) { _ in
                        if let value = Double(feePercent) {
                            appState.setFeePercent(value / 100)
                        }
                    }
                } else {
                    LabeledInput(
                        label: "固定手续费",
                        text: $fixedFee,
                        placeholder: "请输入固定费用",
                        unit: "\(appState.currencySymbol)/\(appState.weightUnitLabel)"
                    )
                    .onChange(of: fixedFee) { _ in
                        if let value = Double(fixedFee) {
                            appState.setFixedFee(value)
                        }
                    }
                }
            }
            .padding(16)
            .cardStyle()
        }
    }
    
    // MARK: - 计算结果
    private var resultSection: some View {
        VStack(alignment: .leading, spacing: 12) {
            SectionHeader(title: "计算结果")
            
            VStack(spacing: 0) {
                if hasValidCurrentPrice {
                    // 主要指标 - 净盈利
                    VStack(spacing: 8) {
                        Text("净盈利")
                            .font(.system(size: 14))
                            .foregroundColor(Theme.secondaryText(for: colorScheme))
                        
                        Text(appState.formatCurrency(netProfit))
                            .font(.system(size: 36, weight: .bold))
                            .foregroundColor(netProfit >= 0 ? Theme.positiveColor : Theme.negativeColor)
                        
                        Text(profitPercentText)
                            .font(.system(size: 16, weight: .semibold))
                            .foregroundColor(profitPercent >= 0 ? Theme.positiveColor : Theme.negativeColor)
                            .padding(.horizontal, 12)
                            .padding(.vertical, 4)
                            .background(
                                Capsule()
                                    .fill((profitPercent >= 0 ? Theme.positiveColor : Theme.negativeColor).opacity(0.1))
                            )
                    }
                    .padding(.vertical, 24)
                    
                    Divider()
                        .background(Theme.dividerColor(for: colorScheme))
                    
                    // 详细数据
                    VStack(spacing: 0) {
                        InfoRow(label: operationType == .none ? "持仓" : "新持仓", value: "\(appState.formatNumber(newHolding)) \(appState.weightUnitLabel)")
                        
                        Divider().background(Theme.dividerColor(for: colorScheme).opacity(0.5))
                        
                        InfoRow(label: "原总成本", value: appState.formatCurrency(originalTotalCost))
                        
                        Divider().background(Theme.dividerColor(for: colorScheme).opacity(0.5))
                        
                        InfoRow(label: "新市值", value: appState.formatCurrency(newMarketValue))
                        
                        if calculatedFee > 0 {
                            Divider().background(Theme.dividerColor(for: colorScheme).opacity(0.5))
                            InfoRow(label: "手续费", value: appState.formatCurrency(calculatedFee))
                        }
                        
                        if operationType != .none {
                            Divider().background(Theme.dividerColor(for: colorScheme).opacity(0.5))
                            InfoRow(label: "新成本均价", value: "\(appState.formatCurrency(newAverageCost))/\(appState.weightUnitLabel)", isHighlighted: true)
                        }
                    }
                    .padding(.top, 16)
                } else {
                    VStack(spacing: 10) {
                        Image(systemName: "exclamationmark.circle")
                            .font(.system(size: 28))
                            .foregroundColor(Theme.warningColor)
                        
                        Text("待输入实时价格")
                            .font(.system(size: 18, weight: .semibold))
                            .foregroundColor(Theme.primaryText(for: colorScheme))
                        
                        Text("请输入实时价格后，再查看持仓盈亏和收益率。")
                            .font(.system(size: 14))
                            .foregroundColor(Theme.secondaryText(for: colorScheme))
                            .multilineTextAlignment(.center)
                    }
                    .frame(maxWidth: .infinity)
                    .padding(.vertical, 32)
                }
                
                // 操作按钮
                if operationType == .add && operationAmountValue > 0 {
                    PrimaryButton(title: "加仓完成", gradient: Theme.positiveGradient) {
                        confirmAddPosition()
                    }
                    .padding(.top, 20)
                }
                
                if operationType == .reduce && operationAmountValue > 0 {
                    PrimaryButton(title: "卖出完成", gradient: Theme.negativeGradient) {
                        confirmSellPosition()
                    }
                    .padding(.top, 20)
                }
            }
            .padding(16)
            .cardStyle()
        }
    }
    
    // MARK: - 计算属性
    private var holdingValue: Double {
        Double(currentHolding) ?? 0
    }
    
    private var costPriceValue: Double {
        Double(costPrice) ?? 0
    }
    
    private var currentPriceValue: Double {
        Double(currentPrice) ?? 0
    }
    
    private var hasValidCurrentPrice: Bool {
        let trimmedPrice = currentPrice.trimmingCharacters(in: .whitespacesAndNewlines)
        return !trimmedPrice.isEmpty && Double(trimmedPrice) != nil
    }
    
    private var operationAmountValue: Double {
        Double(operationAmount) ?? 0
    }
    
    private var feePercentValue: Double {
        (Double(feePercent) ?? 0) / 100
    }
    
    private var fixedFeeValue: Double {
        Double(fixedFee) ?? 0
    }
    
    private var originalTotalCost: Double {
        holdingValue * costPriceValue
    }
    
    private var newHolding: Double {
        switch operationType {
        case .add:
            return holdingValue + operationAmountValue
        case .reduce:
            return max(0, holdingValue - operationAmountValue)
        case .none:
            return holdingValue
        }
    }
    
    private var newTotalCost: Double {
        switch operationType {
        case .add:
            let addCost = operationAmountValue * currentPriceValue
            return originalTotalCost + addCost
        case .reduce:
            let reducedAmount = min(operationAmountValue, holdingValue)
            return originalTotalCost - reducedAmount * costPriceValue
        case .none:
            return originalTotalCost
        }
    }
    
    private var calculatedFee: Double {
        switch operationType {
        case .add:
            return estimatedFee(forHolding: newHolding, marketValue: newMarketValue)
        case .reduce:
            let reduceCost = operationAmountValue * currentPriceValue
            if feeMode == .percent {
                return reduceCost * feePercentValue
            } else {
                return operationAmountValue * fixedFeeValue
            }
        case .none:
            return estimatedFee(forHolding: newHolding, marketValue: newMarketValue)
        }
    }
    
    private var newMarketValue: Double {
        newHolding * currentPriceValue
    }
    
    private var netProfit: Double {
        newMarketValue - newTotalCost - calculatedFee
    }
    
    private var profitPercent: Double {
        guard newTotalCost != 0 else { return 0 }
        return netProfit / newTotalCost
    }
    
    private var profitPercentText: String {
        let sign = profitPercent >= 0 ? "+" : ""
        return "\(sign)\(appState.formatPercent(profitPercent))"
    }
    
    private var newAverageCost: Double {
        guard newHolding != 0 else { return 0 }
        return newTotalCost / newHolding
    }
    
    // MARK: - 方法
    private func loadData() {
        currentHolding = appState.calculatorHolding
        costPrice = appState.calculatorCostPrice
        feeMode = appState.feeMode
        feePercent = AppState.DecimalDisplayFormatter.string(from: appState.feePercent * 100, minimumFractionDigits: 2, maximumFractionDigits: 2)
        fixedFee = AppState.DecimalDisplayFormatter.string(from: appState.fixedFee, minimumFractionDigits: 0, maximumFractionDigits: 0)
    }
    
    private func confirmAddPosition() {
        guard operationType == .add && operationAmountValue > 0 else { return }
        
        let confirmedHolding = formatEditableNumber(newHolding)
        let confirmedAverageCost = formatEditableNumber(newAverageCost)
        
        currentHolding = confirmedHolding
        costPrice = confirmedAverageCost
        
        appState.setCalculatorHolding(currentHolding)
        appState.setCalculatorCostPrice(costPrice)
        
        operationType = .none
        operationAmount = ""
    }
    
    private func confirmSellPosition() {
        guard operationType == .reduce && operationAmountValue > 0 else { return }
        
        currentHolding = formatEditableNumber(newHolding)
        
        appState.setCalculatorHolding(currentHolding)
        
        operationType = .none
        operationAmount = ""
    }
    
    private func formatEditableNumber(_ value: Double, maxDecimals: Int = 6) -> String {
        let formatter = NumberFormatter()
        formatter.numberStyle = .decimal
        formatter.usesGroupingSeparator = false
        formatter.minimumFractionDigits = 0
        formatter.maximumFractionDigits = maxDecimals
        formatter.roundingMode = .halfUp
        formatter.decimalSeparator = "."
        
        return formatter.string(from: NSNumber(value: value)) ?? String(value)
    }
    
    private func estimatedFee(forHolding holding: Double, marketValue: Double) -> Double {
        if feeMode == .percent {
            return marketValue * feePercentValue
        } else {
            return holding * fixedFeeValue
        }
    }
    
    private func hideKeyboard() {
        UIApplication.shared.sendAction(#selector(UIResponder.resignFirstResponder), to: nil, from: nil, for: nil)
    }
}

struct CalculatorView_Previews: PreviewProvider {
    static var previews: some View {
        NavigationView {
            CalculatorView()
                .environmentObject(AppState())
        }
    }
}
