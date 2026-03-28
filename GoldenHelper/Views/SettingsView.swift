//
//  SettingsView.swift
//  GoldenHelper
//
//  设置页面视图
//

import SwiftUI

struct SettingsView: View {
    @EnvironmentObject var appState: AppState
    @Environment(\.colorScheme) var colorScheme
    
    @State private var expandedHelp: String? = nil
    
    var body: some View {
        ScrollView {
            VStack(spacing: 20) {
                // 单位设置
                unitSettingsSection
                
                // 显示设置
                displaySettingsSection
                
                // 参考信息
                referenceInfoSection
                
                // 使用帮助
                helpSection
                
                // 隐私说明
                privacySection
                
                // 关于
                aboutSection
            }
            .padding(.horizontal, 20)
            .padding(.top, 20)
            .padding(.bottom, 40)
        }
        .background(Theme.backgroundGradient(for: colorScheme).ignoresSafeArea())
        .navigationTitle("设置")
        .navigationBarTitleDisplayMode(.inline)
    }
    
    // MARK: - 单位设置
    private var unitSettingsSection: some View {
        VStack(alignment: .leading, spacing: 12) {
            SectionHeader(title: "单位设置")
            
            VStack(spacing: 16) {
                // 重量单位
                VStack(alignment: .leading, spacing: 12) {
                    VStack(alignment: .leading, spacing: 4) {
                        Text("重量单位")
                            .font(.system(size: 16, weight: .semibold))
                            .foregroundColor(Theme.primaryText(for: colorScheme))
                        
                        Text("选择黄金重量计量单位")
                            .font(.system(size: 13))
                            .foregroundColor(Theme.secondaryText(for: colorScheme))
                    }
                    
                    SegmentedPicker(
                        options: WeightUnit.allCases,
                        selection: Binding(
                            get: { appState.weightUnit },
                            set: { appState.setWeightUnit($0) }
                        ),
                        titleForOption: { $0.displayName }
                    )
                }
                
                Divider()
                    .background(Theme.dividerColor(for: colorScheme))
                
                // 货币单位
                VStack(alignment: .leading, spacing: 12) {
                    VStack(alignment: .leading, spacing: 4) {
                        Text("货币单位")
                            .font(.system(size: 16, weight: .semibold))
                            .foregroundColor(Theme.primaryText(for: colorScheme))
                        
                        Text("选择价格显示货币")
                            .font(.system(size: 13))
                            .foregroundColor(Theme.secondaryText(for: colorScheme))
                    }
                    
                    SegmentedPicker(
                        options: CurrencyUnit.allCases,
                        selection: Binding(
                            get: { appState.currencyUnit },
                            set: { appState.setCurrencyUnit($0) }
                        ),
                        titleForOption: { $0.displayName }
                    )
                }
            }
            .padding(16)
            .cardStyle()
        }
    }
    
    // MARK: - 显示设置
    private var displaySettingsSection: some View {
        VStack(alignment: .leading, spacing: 12) {
            SectionHeader(title: "显示设置")
            
            HStack {
                VStack(alignment: .leading, spacing: 4) {
                    Text("深色模式")
                        .font(.system(size: 16, weight: .semibold))
                        .foregroundColor(Theme.primaryText(for: colorScheme))
                    
                    Text("切换应用主题颜色")
                        .font(.system(size: 13))
                        .foregroundColor(Theme.secondaryText(for: colorScheme))
                }
                
                Spacer()
                
                Toggle("", isOn: Binding(
                    get: { appState.isDarkMode ?? (colorScheme == .dark) },
                    set: { appState.setDarkMode($0) }
                ))
                .accentColor(Theme.primaryColor)
            }
            .padding(16)
            .cardStyle()
        }
    }
    
    // MARK: - 参考信息
    private var referenceInfoSection: some View {
        VStack(alignment: .leading, spacing: 12) {
            SectionHeader(title: "参考信息")
            
            VStack(spacing: 16) {
                // 汇率设置
                VStack(alignment: .leading, spacing: 12) {
                    VStack(alignment: .leading, spacing: 4) {
                        Text("美元/人民币汇率")
                            .font(.system(size: 16, weight: .semibold))
                            .foregroundColor(Theme.primaryText(for: colorScheme))
                        
                        Text("参考汇率：1 USD = 7.20 RMB")
                            .font(.system(size: 13))
                            .foregroundColor(Theme.secondaryText(for: colorScheme))
                    }
                    
                    HStack(spacing: 8) {
                        Text("1 USD =")
                            .font(.system(size: 15))
                            .foregroundColor(Theme.primaryText(for: colorScheme))
                        
                        TextField("7.20", text: Binding(
                            get: {
                                AppState.DecimalDisplayFormatter.string(
                                    from: appState.exchangeRate,
                                    minimumFractionDigits: 2,
                                    maximumFractionDigits: 2,
                                    decimalSeparator: "."
                                )
                            },
                            set: { newValue in
                                let normalizedValue = NumericInputFormatter.normalized(newValue)
                                if let rate = Double(normalizedValue), rate > 0 {
                                    appState.setExchangeRate(rate)
                                }
                            }
                        ))
                        .keyboardType(.numbersAndPunctuation)
                        .font(.system(size: 15))
                        .foregroundColor(Theme.primaryText(for: colorScheme))
                        .autocapitalization(.none)
                        .disableAutocorrection(true)
                        .multilineTextAlignment(.trailing)
                        .frame(width: 80)
                        .padding(.horizontal, 12)
                        .frame(height: 40)
                        .background(Theme.inputBackground(for: colorScheme))
                        .cornerRadius(8)
                        
                        Text("RMB")
                            .font(.system(size: 15))
                            .foregroundColor(Theme.primaryText(for: colorScheme))
                    }
                }
                
                Divider()
                    .background(Theme.dividerColor(for: colorScheme))
                
                // 盎司克换算（只读）
                InfoRow(
                    label: "盎司/克换算",
                    value: "1 oz = \(AppState.DecimalDisplayFormatter.string(from: appState.ozToGram, minimumFractionDigits: 4, maximumFractionDigits: 4)) g"
                )
            }
            .padding(16)
            .cardStyle()
        }
    }
    
    // MARK: - 使用帮助
    private var helpSection: some View {
        VStack(alignment: .leading, spacing: 12) {
            SectionHeader(title: "使用帮助")
            
            VStack(spacing: 0) {
                // 投资收益计算器帮助
                helpItem(
                    icon: "📊",
                    title: "投资收益计算器",
                    key: "calculator",
                    content: [
                        "1. 输入当前持仓数量和成本均价",
                        "2. 输入实时价格",
                        "3. 选择操作类型（加仓/减仓/不操作）",
                        "4. 设置手续费模式和费率",
                        "5. 实时查看计算结果"
                    ]
                )
                
                Divider()
                    .background(Theme.dividerColor(for: colorScheme).opacity(0.5))
                
                // 通用公式计算器帮助
                helpItem(
                    icon: "🧮",
                    title: "通用公式计算器",
                    key: "formula",
                    content: [
                        "1. 点击\"+\"按钮创建新公式",
                        "2. 输入公式名称和表达式",
                        "3. 定义英文变量名，例如 cost、price、amount",
                        "4. 保存后点击公式卡片进行计算",
                        "5. 也可使用预设模板快速创建"
                    ]
                )
                
                Divider()
                    .background(Theme.dividerColor(for: colorScheme).opacity(0.5))
                
                // 术语说明
                helpItem(
                    icon: "📖",
                    title: "术语说明",
                    key: "terms",
                    content: [
                        "• 持仓：当前持有的黄金数量",
                        "• 成本均价：平均买入价格",
                        "• 市值：持仓 × 实时价格",
                        "• 净成本：总成本 + 手续费",
                        "• 净盈利：市值 - 净成本",
                        "• 涨幅：净盈利 / 净成本 × 100%"
                    ]
                )
            }
            .padding(16)
            .cardStyle()
        }
    }
    
    private func helpItem(icon: String, title: String, key: String, content: [String]) -> some View {
        VStack(alignment: .leading, spacing: 0) {
            Button {
                withAnimation(.easeInOut(duration: 0.2)) {
                    if expandedHelp == key {
                        expandedHelp = nil
                    } else {
                        expandedHelp = key
                    }
                }
            } label: {
                HStack {
                    Text("\(icon) \(title)")
                        .font(.system(size: 15, weight: .semibold))
                        .foregroundColor(Theme.primaryText(for: colorScheme))
                    
                    Spacer()
                    
                    Image(systemName: expandedHelp == key ? "chevron.down" : "chevron.right")
                        .font(.system(size: 12, weight: .medium))
                        .foregroundColor(Theme.secondaryText(for: colorScheme))
                }
                .padding(.vertical, 12)
            }
            .buttonStyle(PlainButtonStyle())
            
            if expandedHelp == key {
                VStack(alignment: .leading, spacing: 6) {
                    ForEach(content, id: \.self) { text in
                        Text(text)
                            .font(.system(size: 13))
                            .foregroundColor(Theme.secondaryText(for: colorScheme))
                    }
                }
                .padding(.leading, 8)
                .padding(.bottom, 12)
            }
        }
    }
    
    // MARK: - 隐私说明
    private var privacySection: some View {
        VStack(alignment: .leading, spacing: 12) {
            SectionHeader(title: "隐私说明")
            
            VStack(alignment: .leading, spacing: 12) {
                Text("黄金助手为纯本地计算工具。")
                    .font(.system(size: 15, weight: .semibold))
                    .foregroundColor(Theme.primaryText(for: colorScheme))
                
                privacyRow(title: "数据存储", detail: "公式、设置和计算器输入仅保存在当前设备的 UserDefaults 中。")
                privacyRow(title: "网络访问", detail: "当前版本不连接服务器、不上传数据，也不包含账号系统。")
                privacyRow(title: "权限使用", detail: "当前版本不申请相册、相机、麦克风、定位、通讯录等敏感权限。")
                privacyRow(title: "适用范围", detail: "应用提供计算结果和参考信息，不构成投资建议。")
            }
            .padding(16)
            .cardStyle()
        }
    }
    
    private func privacyRow(title: String, detail: String) -> some View {
        VStack(alignment: .leading, spacing: 4) {
            Text(title)
                .font(.system(size: 14, weight: .semibold))
                .foregroundColor(Theme.primaryText(for: colorScheme))
            
            Text(detail)
                .font(.system(size: 13))
                .foregroundColor(Theme.secondaryText(for: colorScheme))
                .fixedSize(horizontal: false, vertical: true)
        }
    }
    
    // MARK: - 关于
    private var aboutSection: some View {
        VStack(alignment: .leading, spacing: 12) {
            SectionHeader(title: "关于")
            
            VStack(spacing: 16) {
                // Logo
                ZStack {
                    RoundedRectangle(cornerRadius: 20)
                        .fill(Theme.goldGradient)
                        .frame(width: 72, height: 72)
                    
                    Text("💰")
                        .font(.system(size: 36))
                }
                
                // 应用名称
                Text("黄金助手")
                    .font(.system(size: 20, weight: .bold))
                    .foregroundColor(Theme.primaryText(for: colorScheme))
                
                // 版本号
                Text("版本 1.0.0")
                    .font(.system(size: 13))
                    .foregroundColor(Theme.secondaryText(for: colorScheme))
                
                // 描述
                Text("轻量级投资收益计算工具")
                    .font(.system(size: 14))
                    .foregroundColor(Theme.secondaryText(for: colorScheme))
                
                // 版权
                Text("© 2024 GoldenHelper")
                    .font(.system(size: 12))
                    .foregroundColor(Theme.secondaryText(for: colorScheme).opacity(0.6))
            }
            .frame(maxWidth: .infinity)
            .padding(32)
            .cardStyle()
        }
    }
}

struct SettingsView_Previews: PreviewProvider {
    static var previews: some View {
        NavigationView {
            SettingsView()
                .environmentObject(AppState())
        }
    }
}
