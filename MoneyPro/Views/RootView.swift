import SwiftUI

struct RootView: View {
    @State private var showingSplash = true
    @State private var splashOpacity: Double = 1.0
    
    var body: some View {
        ZStack {
            // MainView sempre presente ma nascosta dietro lo splash
            MainView()
                .font(.system(size: 17, weight: .regular, design: .rounded))
                .lockOrientation(.portrait)
                .allowsHitTesting(!showingSplash) // Disabilita interazioni durante lo splash
            
            // Splash screen con fade out
            if showingSplash {
                SplashScreenView(opacity: splashOpacity)
                    .opacity(splashOpacity)
                    .onAppear {
                        // Mostra lo splash screen per 2 secondi
                        DispatchQueue.main.asyncAfter(deadline: .now() + 2.0) {
                            withAnimation(.easeOut(duration: 0.15)) {
                                splashOpacity = 0.0
                            }
                            
                            // Nascondi completamente lo splash dopo l'animazione
                            DispatchQueue.main.asyncAfter(deadline: .now() + 0.15) {
                                showingSplash = false
                            }
                        }
                    }
            }
        }
    }
}

#Preview {
    RootView()
} 
