import SwiftUI

struct MainHeader: View {
    @Binding var selectedPeriod: Period
    let monthOffset: Int
    let netTotal: Double?
    let showTotalInHeader: Bool
    let showDivider: Bool
    let onSettingsTap: () -> Void
    let onPeriodSelected: () -> Void
    let onAddTransactionTap: () -> Void
    let onChartTap: () -> Void
    @Binding var isPeriodDropdownExpanded: Bool
    
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
            
            // Period dropdown with total display logic
            VStack(spacing: 2) {
                if showTotalInHeader {
                    // Show period description and total when needed
                    VStack(spacing: 2) {
                        Text(selectedPeriod.periodDescription(withMonthOffset: monthOffset))
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
                    // Show normal period dropdown
                    PeriodDropdown(
                        selectedPeriod: $selectedPeriod,
                        isExpanded: $isPeriodDropdownExpanded,
                        onPeriodSelected: onPeriodSelected
                    )
                    .transition(.asymmetric(
                        insertion: .move(edge: .top).combined(with: .opacity).combined(with: .scale(scale: 1.2)),
                        removal: .move(edge: .top).combined(with: .opacity).combined(with: .scale(scale: 0.8))
                    ))
                }
            }
            .animation(.easeInOut(duration: 0.15), value: showTotalInHeader)
            
            Spacer()
            ChartButton(
                onTap: onChartTap
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
                .frame(width: 26, height: 26)
                .foregroundColor(Colors.primaryColor.opacity(0.5))
                .frame(width: 44, height: 44)
                .cornerRadius(12)
        }
        .buttonStyle(PlainButtonStyle())
        .contentShape(Rectangle())
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



private struct AddTransactionButton: View {
    let onTap: () -> Void
    @State private var isPressed = false
    
    var body: some View {
        Button(action: handleTap) {
            PlusIcon()
                .frame(width: 44, height: 44)
        }
        .buttonStyle(PlainButtonStyle())
        .contentShape(Rectangle())
        .shadow(color: Colors.outlineColor.opacity(0.25), radius: 8, x: 0, y: 0)
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

private struct ChartButton: View {
    let onTap: () -> Void
    @State private var isPressed = false
    
    var body: some View {
        Button(action: handleTap) {
            PlusIcon()
                .frame(width: 44, height: 44)
        }
        .buttonStyle(PlainButtonStyle())
        .contentShape(Rectangle())
        .shadow(color: Colors.outlineColor.opacity(0.25), radius: 8, x: 0, y: 0)
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
            Image("ic_chart")
                .resizable()
                .aspectRatio(contentMode: .fit)
                .frame(width: 27, height: 27)
                .foregroundColor(Colors.primaryColor.opacity(0.5))
                .frame(width: 44, height: 44)
                .cornerRadius(12)
    }
}
