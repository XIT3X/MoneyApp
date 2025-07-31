import SwiftUI

struct EmptyStateView: View {
    var body: some View {
        VStack(spacing: 0) {
            Spacer()
            
            EmptyIcon()
            EmptyTitle()
            EmptyDescription()
            
            Spacer()
        }
        .padding(.horizontal, 40)
        .frame(minHeight: 300)
    }
}

// MARK: - Supporting Views
private struct EmptyIcon: View {
    var body: some View {
        Image("empty_icon")
            .resizable()
            .aspectRatio(contentMode: .fit)
            .frame(width: 80, height: 80)
            .foregroundColor(Colors.secondaryText.opacity(0.3))
            .padding(.bottom, 24)
            .padding(.leading, 8)
    }
}

private struct EmptyTitle: View {
    var body: some View {
        Text("Non c'è nulla qui...")
            .font(.system(size: 24, weight: .medium, design: .rounded))
            .foregroundColor(Colors.primaryText)
            .padding(.bottom, 12)
    }
}

private struct EmptyDescription: View {
    var body: some View {
        VStack(spacing: 0) {
            Text("Aggiungi la tua prima transazione")
                .font(.system(size: 16, weight: .regular, design: .rounded))
                .foregroundColor(Colors.secondaryText)
                .multilineTextAlignment(.center)
            
            InstructionRow()
        }
    }
}

private struct InstructionRow: View {
    var body: some View {
        HStack(spacing: 6) {
            Text("toccando il pulsante")
                .font(.system(size: 16, weight: .regular, design: .rounded))
                .foregroundColor(Colors.secondaryText)
            
            PlusButtonIcon()
            
            Text("in alto")
                .font(.system(size: 16, weight: .regular, design: .rounded))
                .foregroundColor(Colors.secondaryText)
        }
    }
}

private struct PlusButtonIcon: View {
    var body: some View {
        Image(systemName: "plus")
            .padding(.bottom, 0.5)
            .padding(.leading, 0.7)
            .font(.system(size: 14, weight: .bold))
            .foregroundColor(Colors.secondaryText)
            .frame(width: 22, height: 22)
            .background(Colors.primaryBackground)
            .cornerRadius(6)
            .overlay(
                RoundedRectangle(cornerRadius: 6)
                    .stroke(Colors.outlineColor, lineWidth: 1)
                    .opacity(5)
            )
            .padding(.top, 2)
    }
}