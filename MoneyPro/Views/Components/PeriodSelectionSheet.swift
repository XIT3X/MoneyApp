import SwiftUI

struct PeriodSelectionSheet: View {
    @Binding var selectedPeriod: Period
    @Binding var isPresented: Bool
    let onPeriodSelected: () -> Void
    
    var body: some View {
        ZStack {
            Colors.primaryBackground
                .ignoresSafeArea()
            
            VStack(spacing: 0) {
                DragIndicator()
                PeriodOptions(
                    selectedPeriod: $selectedPeriod,
                    isPresented: $isPresented,
                    onPeriodSelected: onPeriodSelected
                )
                Spacer()
            }
        }
        .presentationDetents([.height(470)])
        .presentationDragIndicator(.hidden)
        .presentationCornerRadius(16)
    }
}

// MARK: - Supporting Views
private struct DragIndicator: View {
    var body: some View {
        RoundedRectangle(cornerRadius: 2.5)
            .fill(Colors.secondaryText.opacity(0.3))
            .frame(width: 36, height: 5)
            .padding(.top, 8)
            .padding(.bottom, 16)
    }
}

private struct PeriodOptions: View {
    @Environment(\.dismiss) private var dismiss
    @Binding var selectedPeriod: Period
    @Binding var isPresented: Bool
    let onPeriodSelected: () -> Void
    
    init(
        selectedPeriod: Binding<Period>,
        isPresented: Binding<Bool>,
        onPeriodSelected: @escaping () -> Void
    ) {
        self._selectedPeriod = selectedPeriod
        self._isPresented = isPresented
        self.onPeriodSelected = onPeriodSelected
    }
    
    var body: some View {
        VStack(spacing: 0) {
            ForEach(Period.allCases, id: \.self) { period in
                PeriodOptionRow(
                    period: period,
                    isSelected: selectedPeriod == period,
                    onTap: { selectPeriod(period) }
                )
                
                if period != Period.allCases.last {
                    PeriodDivider()
                }
            }
        }
    }
    
    private func selectPeriod(_ period: Period) {
        selectedPeriod = period
        onPeriodSelected()
        isPresented = false
    }
}

private struct PeriodOptionRow: View {
    let period: Period
    let isSelected: Bool
    let onTap: () -> Void
    
    var body: some View {
        Button(action: onTap) {
            HStack {
                Text(period.displayName.capitalized)
                    .font(.system(size: 17, weight: .medium, design: .rounded))
                    .foregroundColor(Colors.primaryText)
                
                Spacer()
                
                SelectionIndicator(isSelected: isSelected)
            }
            .padding(.horizontal, 30)
            .padding(.vertical, 16)
            .background(Colors.primaryBackground)
        }
        .buttonStyle(PlainButtonStyle())
    }
}

private struct SelectionIndicator: View {
    let isSelected: Bool
    
    var body: some View {
        Circle()
            .fill(isSelected ? Colors.primaryColor : Colors.outlineColor)
            .frame(width: 12, height: 12)
    }
}

private struct PeriodDivider: View {
    var body: some View {
        Rectangle()
            .fill(Colors.outlineColor)
            .frame(height: 1)
            .padding(.horizontal, 30)
            .padding(.vertical, 8)
    }
}