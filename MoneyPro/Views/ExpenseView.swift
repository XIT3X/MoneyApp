import SwiftUI

struct ExpenseView: View {
    @Binding var isPresented: Bool
    
    var body: some View {
        NavigationView {
            VStack(spacing: 0) {
                // Header
                HStack {
                    Button(action: {
                        isPresented = false
                    }) {
                        Image(systemName: "xmark")
                            .font(.system(size: 18, weight: .medium))
                            .foregroundColor(Colors.primaryText)
                    }
                    
                    Spacer()
                    
                    Text("Spese")
                        .font(.system(size: 18, weight: .semibold, design: .rounded))
                        .foregroundColor(Colors.primaryText)
                    
                    Spacer()
                    
                    // Placeholder per bilanciare il layout
                    Color.clear
                        .frame(width: 24, height: 24)
                }
                .padding(.horizontal, 20)
                .padding(.vertical, 16)
                .background(Colors.primaryBackground)
                
                // Contenuto principale
                ScrollView {
                    VStack(spacing: 20) {
                        // Placeholder per il contenuto futuro
                        Text("Contenuto Spese")
                            .font(.system(size: 16, weight: .medium))
                            .foregroundColor(Colors.secondaryText)
                            .padding(.top, 100)
                    }
                    .padding(.horizontal, 20)
                }
                .background(Colors.primaryBackground)
            }
            .background(Colors.primaryBackground)
            .navigationBarHidden(true)
        }
    }
}

#Preview {
    ExpenseView(isPresented: .constant(true))
} 