import SwiftUI

struct EmptyStateView: View {
    var body: some View {
        VStack(spacing: 0) {
            Spacer()
            
            EmptyTitle()
            EmptyDescription()
            
            Spacer()
        }
        .padding(.horizontal, 50)
        .frame(minHeight: 300)
    }
}

// MARK: - Supporting Views


private struct EmptyTitle: View {
    var body: some View {
        Text("Non c'è nulla qui...")
            .font(.system(size: 18, weight: .medium, design: .rounded))
            .foregroundColor(Colors.secondaryText)
            .padding(.bottom, 10)
    }
}

private struct EmptyDescription: View {
    var body: some View {
        VStack(spacing: 0) {
            Text("Aggiungi la tua prima transazione")
                .font(.system(size: 16, weight: .regular, design: .rounded))
                .foregroundColor(Colors.secondaryText.opacity(0.8))
                .multilineTextAlignment(.center)
            
            InstructionRow()
        }
    }
}

private struct InstructionRow: View {
    var body: some View {
        HStack(spacing: 6) {
            Text("toccando il pulsante qui sopra.")
                .font(.system(size: 16, weight: .regular, design: .rounded))
            
            .foregroundColor(Colors.secondaryText.opacity(0.8))}
    }
}
