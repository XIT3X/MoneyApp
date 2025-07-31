import SwiftUI

struct MainHeader: View {
    let selectedPeriod: Period
    let monthOffset: Int
    let showWaveAnimation: Bool
    let waveScale: [CGFloat]
    let waveOpacity: [Double]
    let netTotal: Double?
    let showTotalInHeader: Bool
    let showDivider: Bool
    let onSettingsTap: () -> Void
    let onPeriodTap: () -> Void
    let onAddTransactionTap: () -> Void
    
    var body: some View {
        VStack(spacing: 0) {
            headerContent
            hiddenDivider
        }
    }
    
    private var headerContent: some View {
        HStack {
            SettingsButton(onTap: onSettingsTap)
            Spacer()
            PeriodSelector(
                period: selectedPeriod,
                monthOffset: monthOffset,
                netTotal: netTotal,
                showTotalInHeader: showTotalInHeader,
                onTap: onPeriodTap
            )
            Spacer()
            AddTransactionButton(
                showWaveAnimation: showWaveAnimation,
                waveScale: waveScale,
                waveOpacity: waveOpacity,
                onTap: onAddTransactionTap
            )
        }
        .padding(.horizontal, 18)
        .padding(.vertical, 8)
        .background(Colors.primaryBackground)
    }
    
    private var hiddenDivider: some View {
        Rectangle()
            .fill(Colors.outlineColor)
            .frame(height: 1)
            .opacity(showDivider ? 1.0 : 0.0)
            .animation(.easeInOut(duration: 0.15), value: showDivider)
    }
}

// MARK: - Supporting Views
private struct SettingsButton: View {
    let onTap: () -> Void
    @State private var isPressed = false
    
    var body: some View {
        Button(action: handleTap) {
            Image("ic_options")
                .resizable()
                .aspectRatio(contentMode: .fit)
                .frame(width: 22, height: 22)
                .foregroundColor(Colors.secondaryText)
                .frame(width: 44, height: 44)
                .background(Colors.primaryBackground)
                .cornerRadius(12)
                .overlay(
                    RoundedRectangle(cornerRadius: 12)
                        .stroke(Colors.outlineColor, lineWidth: 1)
                )
        }
        .buttonStyle(PlainButtonStyle())
        .contentShape(Rectangle())
        .shadow(color: Colors.outlineColor.opacity(0.4), radius: 8, x: 0, y: 0)
        .scaleEffect(isPressed ? 0.95 : 1.0)
        .animation(.easeInOut(duration: 0.1), value: isPressed)
        .onLongPressGesture(minimumDuration: 0, maximumDistance: 0, pressing: { pressing in
            withAnimation(.easeInOut(duration: 0.1)) {
                isPressed = pressing
            }
        }, perform: {})
    }
    
    private func handleTap() {
        let impactFeedback = UIImpactFeedbackGenerator(style: .light)
        impactFeedback.impactOccurred()
        onTap()
    }
}

private struct PeriodSelector: View {
    let period: Period
    let monthOffset: Int
    let netTotal: Double?
    let showTotalInHeader: Bool
    let onTap: () -> Void
    @State private var isPeriodPressed = false
    
    private var periodDescription: String {
        period.periodDescription(withMonthOffset: monthOffset)
    }
    
    var body: some View {
        VStack(spacing: 2) {
            if showTotalInHeader {
                // Mostra il periodo e il totale quando necessario
                VStack(spacing: 2) {
                    Text(periodDescription)
                        .font(.system(size: 12, weight: .medium, design: .rounded))
                        .foregroundColor(Colors.secondaryText)
                    
                    if let total = netTotal {
                        Text(total.formattedAmount + " €")
                            .font(AppFonts.headline)
                            .foregroundColor(Colors.primaryText)
                    }
                }
                .transition(.asymmetric(
                    insertion: .move(edge: .bottom).combined(with: .opacity).combined(with: .scale(scale: 0.4)),
                    removal: .move(edge: .bottom).combined(with: .opacity).combined(with: .scale(scale: 0.4))
                ))
            } else {
                // Mostra il periodo normalmente
                VStack(spacing: 2) {
                    Text("Periodo")
                        .font(.system(size: 12, weight: .medium, design: .rounded))
                        .foregroundColor(Colors.secondaryText)
                    
                    Button(action: onTap) {
                        HStack(spacing: 4) {
                            Text(period.displayName)
                                .font(AppFonts.headline)
                                .foregroundColor(Colors.primaryText)
                            Image(systemName: "chevron.down")
                                .font(.system(size: 12, weight: .medium))
                                .foregroundColor(Colors.secondaryText)
                        }
                    }
                }
                .scaleEffect(isPeriodPressed ? 0.95 : 1.0)
                .animation(.easeInOut(duration: 0.1), value: isPeriodPressed)
                .onLongPressGesture(minimumDuration: 0, maximumDistance: 0, pressing: { pressing in
                    withAnimation(.easeInOut(duration: 0.1)) {
                        isPeriodPressed = pressing
                    }
                }, perform: {})
                .transition(.asymmetric(
                    insertion: .move(edge: .top).combined(with: .opacity).combined(with: .scale(scale: 1.2)),
                    removal: .move(edge: .top).combined(with: .opacity).combined(with: .scale(scale: 0.8))
                ))
            }
        }
        .animation(.easeInOut(duration: 0.15), value: showTotalInHeader)
    }
}

private struct AddTransactionButton: View {
    let showWaveAnimation: Bool
    let waveScale: [CGFloat]
    let waveOpacity: [Double]
    let onTap: () -> Void
    @State private var isPressed = false
    
    var body: some View {
        Button(action: handleTap) {
            ZStack {
                WaveAnimationLayer(
                    showWaveAnimation: showWaveAnimation,
                    waveScale: waveScale,
                    waveOpacity: waveOpacity
                )
                
                PlusIcon()
            }
            .frame(width: 44, height: 44)
        }
        .buttonStyle(PlainButtonStyle())
        .contentShape(Rectangle())
        .shadow(color: Colors.outlineColor.opacity(0.4), radius: 8, x: 0, y: 0)
        .scaleEffect(isPressed ? 0.95 : 1.0)
        .animation(.easeInOut(duration: 0.1), value: isPressed)
        .onLongPressGesture(minimumDuration: 0, maximumDistance: 0, pressing: { pressing in
            withAnimation(.easeInOut(duration: 0.1)) {
                isPressed = pressing
            }
        }, perform: {})
    }
    
    private func handleTap() {
        let impactFeedback = UIImpactFeedbackGenerator(style: .light)
        impactFeedback.impactOccurred()
        onTap()
    }
}

private struct WaveAnimationLayer: View {
    let showWaveAnimation: Bool
    let waveScale: [CGFloat]
    let waveOpacity: [Double]
    
    var body: some View {
        if showWaveAnimation {
            ForEach(0..<1, id: \.self) { index in
                RoundedRectangle(cornerRadius: 12)
                    .stroke(Colors.outlineColor.opacity(0.8), lineWidth: 4)
                    .frame(
                        width: 44 + CGFloat(index * 10),
                        height: 44 + CGFloat(index * 10)
                    )
                    .scaleEffect(waveScale[index])
                    .opacity(waveOpacity[index])
            }
        }
    }
}

private struct PlusIcon: View {
    var body: some View {
        Image(systemName: "plus")
            .font(.system(size: 18, weight: .bold))
            .foregroundColor(Colors.secondaryText)
            .frame(width: 44, height: 44)
            .background(Colors.primaryBackground)
            .cornerRadius(12)
            .overlay(
                RoundedRectangle(cornerRadius: 12)
                    .stroke(Colors.outlineColor, lineWidth: 1)
            )
    }
}
