//
//  AppState.swift
//  GoldenHelper
//
//  全局应用状态管理
//

import SwiftUI
import Combine

class AppState: ObservableObject {
    // MARK: - 存储键
    private enum StorageKeys {
        static let settings = "GOLDEN_HELPER_SETTINGS"
        static let formulas = "GOLDEN_HELPER_FORMULAS"
        static let calculator = "GOLDEN_HELPER_CALCULATOR"
    }
    
    // MARK: - 发布的属性
    @Published var weightUnit: WeightUnit = .gram
    @Published var currencyUnit: CurrencyUnit = .RMB
    @Published var feeMode: FeeMode = .percent
    @Published var feePercent: Double = 0.0002
    @Published var fixedFee: Double = 3
    @Published var isDarkMode: Bool? = nil
    @Published var formulas: [Formula] = []
    @Published var calculatorHolding: String = ""
    @Published var calculatorCostPrice: String = ""
    @Published var exchangeRate: Double = 7.2
    
    // MARK: - 常量
    let ozToGram: Double = 31.1035
    
    // MARK: - 计算属性
    var colorScheme: ColorScheme? {
        guard let isDark = isDarkMode else { return nil }
        return isDark ? .dark : .light
    }
    
    var currencySymbol: String {
        currencyUnit.symbol
    }
    
    var weightUnitLabel: String {
        weightUnit.shortName
    }
    
    var priceUnitLabel: String {
        "\(currencySymbol)/\(weightUnitLabel)"
    }
    
    // MARK: - 初始化
    init() {
        loadSettings()
        loadFormulas()
        loadCalculatorData()
    }
    
    // MARK: - 设置管理
    private func loadSettings() {
        guard let data = UserDefaults.standard.data(forKey: StorageKeys.settings),
              let settings = try? JSONDecoder().decode(AppSettings.self, from: data) else {
            return
        }
        
        weightUnit = settings.weightUnit
        currencyUnit = settings.currencyUnit
        feeMode = settings.feeMode
        feePercent = settings.feePercent
        fixedFee = settings.fixedFee
        isDarkMode = settings.isDarkMode
        exchangeRate = settings.exchangeRate ?? 7.2
    }
    
    private func saveSettings() {
        let settings = AppSettings(
            weightUnit: weightUnit,
            currencyUnit: currencyUnit,
            feeMode: feeMode,
            feePercent: feePercent,
            fixedFee: fixedFee,
            isDarkMode: isDarkMode,
            exchangeRate: exchangeRate
        )
        
        if let data = try? JSONEncoder().encode(settings) {
            UserDefaults.standard.set(data, forKey: StorageKeys.settings)
        }
    }
    
    // MARK: - 公式管理
    private func loadFormulas() {
        guard let data = UserDefaults.standard.data(forKey: StorageKeys.formulas),
              let formulas = try? JSONDecoder().decode([Formula].self, from: data) else {
            return
        }
        self.formulas = formulas
    }
    
    private func saveFormulas() {
        if let data = try? JSONEncoder().encode(formulas) {
            UserDefaults.standard.set(data, forKey: StorageKeys.formulas)
        }
    }
    
    func addFormula(_ formula: Formula) {
        formulas.append(formula)
        saveFormulas()
    }
    
    func updateFormula(_ formula: Formula) {
        if let index = formulas.firstIndex(where: { $0.id == formula.id }) {
            formulas[index] = formula
            saveFormulas()
        }
    }
    
    func deleteFormula(_ formula: Formula) {
        formulas.removeAll { $0.id == formula.id }
        saveFormulas()
    }
    
    func updateFormulaResult(id: String, result: Double, variables: [FormulaVariable]) {
        if let index = formulas.firstIndex(where: { $0.id == id }) {
            formulas[index].lastResult = result
            formulas[index].savedVariables = variables
            saveFormulas()
        }
    }
    
    // MARK: - 计算器数据管理
    private func loadCalculatorData() {
        guard let data = UserDefaults.standard.data(forKey: StorageKeys.calculator),
              let calcData = try? JSONDecoder().decode(CalculatorData.self, from: data) else {
            return
        }
        calculatorHolding = calcData.currentHolding
        calculatorCostPrice = calcData.costPrice
    }
    
    private func saveCalculatorData() {
        let calcData = CalculatorData(currentHolding: calculatorHolding, costPrice: calculatorCostPrice)
        if let data = try? JSONEncoder().encode(calcData) {
            UserDefaults.standard.set(data, forKey: StorageKeys.calculator)
        }
    }
    
    func setCalculatorHolding(_ value: String) {
        calculatorHolding = value
        saveCalculatorData()
    }
    
    func setCalculatorCostPrice(_ value: String) {
        calculatorCostPrice = value
        saveCalculatorData()
    }
    
    // MARK: - 设置更新方法
    func setWeightUnit(_ unit: WeightUnit) {
        weightUnit = unit
        saveSettings()
    }
    
    func setCurrencyUnit(_ unit: CurrencyUnit) {
        currencyUnit = unit
        saveSettings()
    }
    
    func setFeeMode(_ mode: FeeMode) {
        feeMode = mode
        saveSettings()
    }
    
    func setFeePercent(_ percent: Double) {
        feePercent = percent
        saveSettings()
    }
    
    func setFixedFee(_ fee: Double) {
        fixedFee = fee
        saveSettings()
    }
    
    func toggleDarkMode() {
        if isDarkMode == nil {
            isDarkMode = true
        } else {
            isDarkMode?.toggle()
        }
        saveSettings()
    }
    
    func setDarkMode(_ value: Bool?) {
        isDarkMode = value
        saveSettings()
    }
    
    func setExchangeRate(_ rate: Double) {
        exchangeRate = rate
        saveSettings()
    }
    
    // MARK: - 工具方法
    func formatCurrency(_ value: Double) -> String {
        return "\(currencySymbol)\(String(format: "%.2f", value))"
    }
    
    func formatPercent(_ value: Double) -> String {
        return String(format: "%.2f%%", value * 100)
    }
    
    func formatNumber(_ value: Double, decimals: Int = 2) -> String {
        return String(format: "%.\(decimals)f", value)
    }
    
    func convertWeight(_ value: Double, from: WeightUnit, to: WeightUnit) -> Double {
        if from == to { return value }
        if from == .gram && to == .ounce {
            return value / ozToGram
        }
        if from == .ounce && to == .gram {
            return value * ozToGram
        }
        return value
    }
    
    func convertCurrency(_ value: Double, from: CurrencyUnit, to: CurrencyUnit) -> Double {
        if from == to { return value }
        if from == .USD && to == .RMB {
            return value * exchangeRate
        }
        if from == .RMB && to == .USD {
            return value / exchangeRate
        }
        return value
    }
}
