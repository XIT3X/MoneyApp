import SwiftUI

struct PeriodDropdown: View {
    @Binding var selectedPeriod: Period
    @Binding var isExpanded: Bool
    let onPeriodSelected: () -> Void
    
    var body: some View {
        VStack(spacing: 2) {
            // Label "Periodo"
            Text("Periodo")
                .font(.system(size: 12, weight: .medium, design: .rounded))
                .foregroundColor(Colors.secondaryText)
            
            // Main button that shows current selection
            Button(action: {
                withAnimation(.easeInOut(duration: 0.2)) {
                    isExpanded.toggle()
                }
            }) {
                HStack(spacing: 4) {
                    Text(selectedPeriod.displayName)
                        .font(AppFonts.headline)
                        .foregroundColor(Colors.primaryText)
                    Image(systemName: isExpanded ? "chevron.up" : "chevron.down")
                        .font(.system(size: 12, weight: .medium))
                        .foregroundColor(Colors.secondaryText)
                        .animation(.easeInOut(duration: 0.2), value: isExpanded)
                }
            }
            .buttonStyle(PlainButtonStyle())
        }
    }
}

// Separate dropdown overlay component
struct PeriodDropdownOverlay: View {
    @Binding var selectedPeriod: Period
    @Binding var isExpanded: Bool
    let onPeriodSelected: () -> Void
    
    var body: some View {
        if isExpanded {
            VStack(spacing: 0) {
                ForEach(Period.allCases, id: \.self) { period in
                    Button(action: {
                        selectedPeriod = period
                        onPeriodSelected()
                        withAnimation(.easeInOut(duration: 0.2)) {
                            isExpanded = false
                        }
                    }) {
                        HStack {
                            Text(period.displayName)
                                .font(.system(size: 16, weight: .medium))
                                .foregroundColor(Colors.primaryText)
                            
                            Spacer()
                        }
                        .padding(.horizontal, 16)
                        .padding(.vertical, 12)
                        .background(Colors.primaryBackground)
                    }
                    .buttonStyle(PlainButtonStyle())
                    
                    if period != Period.allCases.last {
                        Rectangle()
                            .fill(Colors.outlineColor)
                            .frame(height: 1)
                    }
                }
            }
            .background(Colors.primaryBackground)
            .cornerRadius(12)
            .overlay(
                RoundedRectangle(cornerRadius: 12)
                    .stroke(Colors.outlineColor, lineWidth: 1)
            )
            .shadow(color: Colors.outlineColor.opacity(0.5), radius: 10, x: 0, y: 0)
            .transition(.opacity.combined(with: .scale(scale: 0, anchor: .top)))
            .padding(.horizontal, 20)
        }
    }
}


#Preview {
    VStack {
        PeriodDropdown(
            selectedPeriod: .constant(.from1st),
            isExpanded: .constant(false)
        ) {
            print("Period selected")
        }
        .padding()
        
        Spacer()
    }
    .background(Colors.secondaryBackground)
} 
