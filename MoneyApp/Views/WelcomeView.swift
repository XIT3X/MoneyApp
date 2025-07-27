import SwiftUI

struct WelcomeView: View {
    @Binding var isPresented: Bool
    let onDismiss: () -> Void
    
    var body: some View {
        ZStack {
            // Background
            Colors.primaryBackground
                .ignoresSafeArea()
            
            VStack(spacing: 0) {
                Spacer()
                
                // Logo e nome app
                VStack(spacing: 16) {
                    // App Icon
                    Image("icon_app.png")
                        .resizable()
                        .aspectRatio(contentMode: .fit)
                        .frame(width: 80, height: 80)
                        .cornerRadius(20)
                    
                    // App Name
                    Text("Money Manager")
                        .font(.system(size: 32, weight: .bold, design: .rounded))
                        .foregroundColor(Colors.primaryText)
                    
                    // Version
                    Text("Versione 1.0")
                        .font(.system(size: 14, weight: .medium, design: .rounded))
                        .foregroundColor(Colors.secondaryText)
                }
                .padding(.bottom, 60)
                
                // Features
                VStack(spacing: 32) {
                    // Feature 1
                    HStack(spacing: 16) {
                        Image("ic_plus")
                            .resizable()
                            .aspectRatio(contentMode: .fit)
                            .frame(width: 40, height: 40)
                            .foregroundColor(Colors.primaryColor)
                            .frame(width: 48)
                        
                        VStack(alignment: .leading, spacing: 4) {
                            Text("Traccia le tue finanze")
                                .font(.system(size: 18, weight: .bold, design: .rounded))
                                .foregroundColor(Colors.primaryText)
                            Text("Aggiungi nuove transazioni in modo semplice e intuitivo")
                                .font(.system(size: 14, weight: .medium, design: .rounded))
                                .foregroundColor(Colors.secondaryText)
                                .multilineTextAlignment(.leading)
                        }
                        
                        Spacer()
                    }
                    
                    // Feature 2
                    HStack(spacing: 16) {
                        Image("ic_chart")
                            .resizable()
                            .aspectRatio(contentMode: .fit)
                            .frame(width: 40, height: 40)
                            .foregroundColor(Colors.primaryColor)
                            .frame(width: 48)
                        
                        VStack(alignment: .leading, spacing: 4) {
                            Text("Analizza le tue spese")
                                .font(.system(size: 18, weight: .bold, design: .rounded))
                                .foregroundColor(Colors.primaryText)
                            Text("Ottieni insights dalle tue spese in diversi periodi")
                                .font(.system(size: 14, weight: .medium, design: .rounded))
                                .foregroundColor(Colors.secondaryText)
                                .multilineTextAlignment(.leading)
                        }
                        
                        Spacer()
                    }
                    
                    // Feature 3
                    HStack(spacing: 16) {
                        Image("ic_target")
                            .resizable()
                            .aspectRatio(contentMode: .fit)
                            .frame(width: 40, height: 40)
                            .foregroundColor(Colors.primaryColor)
                            .frame(width: 48)
                        
                        VStack(alignment: .leading, spacing: 4) {
                            Text("Rispetta i budget")
                                .font(.system(size: 18, weight: .bold, design: .rounded))
                                .foregroundColor(Colors.primaryText)
                            Text("Imposta obiettivi per categoria e periodo per limitare le spese")
                                .font(.system(size: 14, weight: .medium, design: .rounded))
                                .foregroundColor(Colors.secondaryText)
                                .multilineTextAlignment(.leading)
                        }
                        
                        Spacer()
                    }
                }
                .padding(.horizontal, 32)
                
                Spacer()
                
                // Get Started Button
                Button(action: {
                    // Salva che l'app è stata aperta per la prima volta
                    UserDefaults.standard.set(true, forKey: "hasSeenWelcome")
                    
                    // Chiudi la welcome view
                    withAnimation(.easeInOut(duration: 0.3)) {
                        isPresented = false
                    }
                    
                    DispatchQueue.main.asyncAfter(deadline: .now() + 0.3) {
                        onDismiss()
                    }
                }) {
                    Text("Inizia")
                        .font(.system(size: 18, weight: .bold, design: .rounded))
                        .foregroundColor(Colors.primaryBackground)
                        .frame(maxWidth: .infinity)
                        .frame(height: 56)
                        .background(Colors.primaryColor)
                        .cornerRadius(16)
                }
                .padding(.horizontal, 32)
                .padding(.bottom, 50)
            }
        }
    }
}

#if DEBUG
#Preview {
    WelcomeView(isPresented: .constant(true), onDismiss: {})
}
#endif 
