//
//  HomeView.swift
//  GoldenHelper
//
//  首页视图
//

import SwiftUI

struct HomeView: View {
    @EnvironmentObject var appState: AppState
    @Environment(\.colorScheme) var colorScheme
    
    var body: some View {
        ScrollView {
            VStack(spacing: 0) {
                // 顶部标题区域
                headerSection
                
                // 功能卡片区域
                featureCardsSection
                
                // 当前设置信息
                currentSettingsSection
                
                // 底部版权
                footerSection
            }
            .padding(.horizontal, 20)
        }
        .background(Theme.backgroundGradient(for: colorScheme).ignoresSafeArea())
        .navigationBarHidden(true)
    }
    
    // MARK: - 顶部标题
    private var headerSection: some View {
        HStack {
            VStack(alignment: .leading, spacing: 4) {
                Text("黄金助手")
                    .font(.system(size: 28, weight: .bold))
                    .foregroundColor(Theme.primaryText(for: colorScheme))
                
                Text("投资收益计算工具")
                    .font(.system(size: 14))
                    .foregroundColor(Theme.secondaryText(for: colorScheme))
            }
            
            Spacer()
            
            // 主题切换按钮
            Button {
                withAnimation(.easeInOut(duration: 0.3)) {
                    appState.toggleDarkMode()
                }
            } label: {
                ZStack {
                    Circle()
                        .fill(Theme.inputBackground(for: colorScheme))
                        .frame(width: 44, height: 44)
                    
                    Image(systemName: colorScheme == .dark ? "sun.max.fill" : "moon.fill")
                        .font(.system(size: 20))
                        .foregroundColor(colorScheme == .dark ? .yellow : Theme.primaryColor)
                }
            }
        }
        .padding(.top, 60)
        .padding(.bottom, 15)
    }
    
    // MARK: - 功能卡片
    private var featureCardsSection: some View {
        VStack(spacing: 16) {
            // 投资收益计算器
            NavigationLink(destination: CalculatorView()) {
                FeatureCardView(
                    icon: "📊",
                    title: "投资收益计算器",
                    description: "计算黄金投资盈亏、加仓减仓影响",
                    gradient: Theme.goldGradient
                )
            }
            .buttonStyle(PlainButtonStyle())
            
            // 通用公式计算器
            NavigationLink(destination: FormulaView()) {
                FeatureCardView(
                    icon: "🧮",
                    title: "通用公式计算器",
                    description: "创建和管理自定义计算公式",
                    gradient: Theme.primaryGradient
                )
            }
            .buttonStyle(PlainButtonStyle())
            
            // 设置
            NavigationLink(destination: SettingsView()) {
                FeatureCardView(
                    icon: "⚙️",
                    title: "设置",
                    description: "单位切换、货币设置、帮助",
                    gradient: LinearGradient(
                        colors: [Color(red: 108/255, green: 117/255, blue: 125/255), Color(red: 73/255, green: 80/255, blue: 87/255)],
                        startPoint: .topLeading,
                        endPoint: .bottomTrailing
                    )
                )
            }
            .buttonStyle(PlainButtonStyle())
        }
        .padding(.top, 10)
    }
    
    // MARK: - 当前设置信息
    private var currentSettingsSection: some View {
        VStack(alignment: .leading, spacing: 12) {
            SectionHeader(title: "当前设置")
            
            HStack(spacing: 0) {
                // 重量单位
                VStack(spacing: 6) {
                    Text("重量单位")
                        .font(.system(size: 12))
                        .foregroundColor(Theme.secondaryText(for: colorScheme))
                    
                    Text(appState.weightUnit.displayName)
                        .font(.system(size: 15, weight: .semibold))
                        .foregroundColor(Theme.primaryText(for: colorScheme))
                }
                .frame(maxWidth: .infinity)
                
                // 分隔线
                Rectangle()
                    .fill(Theme.dividerColor(for: colorScheme))
                    .frame(width: 1, height: 40)
                
                // 货币单位
                VStack(spacing: 6) {
                    Text("货币单位")
                        .font(.system(size: 12))
                        .foregroundColor(Theme.secondaryText(for: colorScheme))
                    
                    Text(appState.currencyUnit.displayName)
                        .font(.system(size: 15, weight: .semibold))
                        .foregroundColor(Theme.primaryText(for: colorScheme))
                }
                .frame(maxWidth: .infinity)
            }
            .padding(20)
            .cardStyle()
        }
        .padding(.top, 30)
    }
    
    // MARK: - 底部版权
    private var footerSection: some View {
        Text("GoldenHelper v1.0.0")
            .font(.system(size: 12))
            .foregroundColor(Theme.secondaryText(for: colorScheme).opacity(0.6))
            .padding(.top, 40)
            .padding(.bottom, 20)
    }
}

// MARK: - 功能卡片视图
struct FeatureCardView: View {
    let icon: String
    let title: String
    let description: String
    let gradient: LinearGradient
    
    @Environment(\.colorScheme) var colorScheme
    
    var body: some View {
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
}

struct HomeView_Previews: PreviewProvider {
    static var previews: some View {
        NavigationView {
            HomeView()
                .environmentObject(AppState())
        }
    }
}
