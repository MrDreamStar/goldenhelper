//
//  Models.swift
//  GoldenHelper
//
//  数据模型定义
//

import Foundation

// MARK: - 重量单位
enum WeightUnit: String, Codable, CaseIterable {
    case gram = "g"
    case ounce = "oz"
    
    var displayName: String {
        switch self {
        case .gram: return "克 (g)"
        case .ounce: return "盎司 (oz)"
        }
    }
    
    var shortName: String {
        return rawValue
    }
}

// MARK: - 货币单位
enum CurrencyUnit: String, Codable, CaseIterable {
    case RMB = "RMB"
    case USD = "USD"
    
    var displayName: String {
        switch self {
        case .RMB: return "人民币 (¥)"
        case .USD: return "美元 ($)"
        }
    }
    
    var symbol: String {
        switch self {
        case .RMB: return "¥"
        case .USD: return "$"
        }
    }
}

// MARK: - 操作类型
enum OperationType: String, CaseIterable {
    case none = "none"
    case add = "add"
    case reduce = "reduce"
    
    var displayName: String {
        switch self {
        case .none: return "不操作"
        case .add: return "加仓"
        case .reduce: return "减仓"
        }
    }
}

// MARK: - 手续费模式
enum FeeMode: String, Codable, CaseIterable {
    case percent = "percent"
    case fixed = "fixed"
    
    var displayName: String {
        switch self {
        case .percent: return "按比例"
        case .fixed: return "固定费用"
        }
    }
}

// MARK: - 公式变量
struct FormulaVariable: Codable, Identifiable, Equatable {
    var id: String = UUID().uuidString
    var name: String
    var label: String
    var value: Double
    var unit: String
    
    init(name: String, label: String = "", value: Double = 0, unit: String = "") {
        self.name = name
        self.label = label.isEmpty ? name : label
        self.value = value
        self.unit = unit
    }
}

// MARK: - 自定义公式
struct Formula: Codable, Identifiable, Equatable {
    var id: String
    var name: String
    var expression: String
    var description: String
    var variables: [FormulaVariable]
    var createdAt: Date
    var lastResult: Double?
    var savedVariables: [FormulaVariable]?
    
    init(id: String = UUID().uuidString, name: String, expression: String, description: String = "", variables: [FormulaVariable] = []) {
        self.id = id
        self.name = name
        self.expression = expression
        self.description = description
        self.variables = variables
        self.createdAt = Date()
        self.lastResult = nil
        self.savedVariables = nil
    }
    
    static func == (lhs: Formula, rhs: Formula) -> Bool {
        return lhs.id == rhs.id
    }
}

// MARK: - 预设公式模板
struct FormulaTemplate {
    let name: String
    let expression: String
    let description: String
    let variables: [FormulaVariable]
    let icon: String
    
    static let presets: [FormulaTemplate] = [
        FormulaTemplate(
            name: "净收益计算",
            expression: "(卖价 - 买价) * 数量 - 手续费",
            description: "计算投资净收益",
            variables: [
                FormulaVariable(name: "卖价", label: "卖价"),
                FormulaVariable(name: "买价", label: "买价"),
                FormulaVariable(name: "数量", label: "数量"),
                FormulaVariable(name: "手续费", label: "手续费")
            ],
            icon: "💰"
        ),
        FormulaTemplate(
            name: "投资回报率",
            expression: "(收益 / 成本) * 100",
            description: "计算投资回报率百分比",
            variables: [
                FormulaVariable(name: "收益", label: "收益"),
                FormulaVariable(name: "成本", label: "成本")
            ],
            icon: "📈"
        ),
        FormulaTemplate(
            name: "平均成本",
            expression: "总成本 / 总数量",
            description: "计算平均持仓成本",
            variables: [
                FormulaVariable(name: "总成本", label: "总成本"),
                FormulaVariable(name: "总数量", label: "总数量")
            ],
            icon: "⚖️"
        ),
        FormulaTemplate(
            name: "复利计算",
            expression: "本金 * (1 + 年化收益率 / 100) * 年数",
            description: "计算复利终值",
            variables: [
                FormulaVariable(name: "本金", label: "本金"),
                FormulaVariable(name: "年化收益率", label: "年化收益率(%)"),
                FormulaVariable(name: "年数", label: "年数")
            ],
            icon: "📊"
        ),
        FormulaTemplate(
            name: "保本价格",
            expression: "(买入价 * 数量 + 手续费) / 数量",
            description: "计算卖出保本价格",
            variables: [
                FormulaVariable(name: "买入价", label: "买入价"),
                FormulaVariable(name: "数量", label: "数量"),
                FormulaVariable(name: "手续费", label: "手续费")
            ],
            icon: "🎯"
        ),
        FormulaTemplate(
            name: "盎司转克价",
            expression: "盎司价格 / 31.1035",
            description: "国际金价盎司转人民币克价",
            variables: [
                FormulaVariable(name: "盎司价格", label: "盎司价格")
            ],
            icon: "🥇"
        )
    ]
}

// MARK: - 应用设置
struct AppSettings: Codable {
    var weightUnit: WeightUnit
    var currencyUnit: CurrencyUnit
    var feeMode: FeeMode
    var feePercent: Double
    var fixedFee: Double
    var isDarkMode: Bool?
    var exchangeRate: Double?
    
    static let `default` = AppSettings(
        weightUnit: .gram,
        currencyUnit: .RMB,
        feeMode: .percent,
        feePercent: 0.0002,
        fixedFee: 3,
        isDarkMode: nil,
        exchangeRate: 7.2
    )
}

// MARK: - 计算器数据
struct CalculatorData: Codable {
    var currentHolding: String
    var costPrice: String
    
    static let `default` = CalculatorData(currentHolding: "", costPrice: "")
}
